
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-sensor (err u104))
(define-constant err-product-not-verified (err u105))
(define-constant err-already-verified (err u106))

(define-map products
  { product-id: (string-ascii 64) }
  {
    manufacturer: principal,
    name: (string-ascii 100),
    batch-id: (string-ascii 64),
    created-at: uint,
    verified: bool,
    verification-count: uint,
    last-verification: uint
  }
)

(define-map authorized-sensors
  { sensor-id: (string-ascii 64) }
  {
    owner: principal,
    location: (string-ascii 100),
    active: bool,
    created-at: uint,
    verification-count: uint
  }
)

(define-map verifications
  { verification-id: uint }
  {
    product-id: (string-ascii 64),
    sensor-id: (string-ascii 64),
    verifier: principal,
    timestamp: uint,
    authentic: bool,
    location: (string-ascii 100),
    confidence-score: uint
  }
)

(define-map product-history
  { product-id: (string-ascii 64), verification-index: uint }
  {
    sensor-id: (string-ascii 64),
    timestamp: uint,
    location: (string-ascii 100),
    authentic: bool,
    confidence-score: uint
  }
)

(define-data-var next-verification-id uint u1)
(define-data-var total-products uint u0)
(define-data-var total-sensors uint u0)
(define-data-var total-verifications uint u0)

(define-public (register-product (product-id (string-ascii 64)) (name (string-ascii 100)) (batch-id (string-ascii 64)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-none (map-get? products { product-id: product-id })) err-already-exists)
    (map-set products 
      { product-id: product-id }
      {
        manufacturer: tx-sender,
        name: name,
        batch-id: batch-id,
        created-at: stacks-block-height,
        verified: false,
        verification-count: u0,
        last-verification: u0
      }
    )
    (var-set total-products (+ (var-get total-products) u1))
    (ok product-id)
  )
)

(define-public (add-authorized-sensor (sensor-id (string-ascii 64)) (location (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-none (map-get? authorized-sensors { sensor-id: sensor-id })) err-already-exists)
    (map-set authorized-sensors
      { sensor-id: sensor-id }
      {
        owner: tx-sender,
        location: location,
        active: true,
        created-at: stacks-block-height,
        verification-count: u0
      }
    )
    (var-set total-sensors (+ (var-get total-sensors) u1))
    (ok sensor-id)
  )
)

(define-public (verify-product (product-id (string-ascii 64)) (sensor-id (string-ascii 64)) (location (string-ascii 100)) (authentic bool) (confidence-score uint))
  (let (
    (product (unwrap! (map-get? products { product-id: product-id }) err-not-found))
    (sensor (unwrap! (map-get? authorized-sensors { sensor-id: sensor-id }) err-invalid-sensor))
    (verification-id (var-get next-verification-id))
    (current-verification-count (get verification-count product))
  )
    (asserts! (get active sensor) err-invalid-sensor)
    (asserts! (<= confidence-score u100) err-unauthorized)
    
    (map-set verifications
      { verification-id: verification-id }
      {
        product-id: product-id,
        sensor-id: sensor-id,
        verifier: tx-sender,
        timestamp: stacks-block-height,
        authentic: authentic,
        location: location,
        confidence-score: confidence-score
      }
    )
    
    (map-set product-history
      { product-id: product-id, verification-index: current-verification-count }
      {
        sensor-id: sensor-id,
        timestamp: stacks-block-height,
        location: location,
        authentic: authentic,
        confidence-score: confidence-score
      }
    )
    
    (map-set products
      { product-id: product-id }
      (merge product {
        verified: authentic,
        verification-count: (+ current-verification-count u1),
        last-verification: stacks-block-height
      })
    )
    
    (map-set authorized-sensors
      { sensor-id: sensor-id }
      (merge sensor {
        verification-count: (+ (get verification-count sensor) u1)
      })
    )
    
    (var-set next-verification-id (+ verification-id u1))
    (var-set total-verifications (+ (var-get total-verifications) u1))
    (ok verification-id)
  )
)

(define-public (deactivate-sensor (sensor-id (string-ascii 64)))
  (let (
    (sensor (unwrap! (map-get? authorized-sensors { sensor-id: sensor-id }) err-invalid-sensor))
  )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set authorized-sensors
      { sensor-id: sensor-id }
      (merge sensor { active: false })
    )
    (ok true)
  )
)

(define-public (reactivate-sensor (sensor-id (string-ascii 64)))
  (let (
    (sensor (unwrap! (map-get? authorized-sensors { sensor-id: sensor-id }) err-invalid-sensor))
  )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set authorized-sensors
      { sensor-id: sensor-id }
      (merge sensor { active: true })
    )
    (ok true)
  )
)

(define-read-only (get-product (product-id (string-ascii 64)))
  (map-get? products { product-id: product-id })
)

(define-read-only (get-sensor (sensor-id (string-ascii 64)))
  (map-get? authorized-sensors { sensor-id: sensor-id })
)

(define-read-only (get-verification (verification-id uint))
  (map-get? verifications { verification-id: verification-id })
)

(define-read-only (get-product-history (product-id (string-ascii 64)) (verification-index uint))
  (map-get? product-history { product-id: product-id, verification-index: verification-index })
)

(define-read-only (is-product-authentic (product-id (string-ascii 64)))
  (match (map-get? products { product-id: product-id })
    product (ok (get verified product))
    err-not-found
  )
)

(define-read-only (get-product-verification-count (product-id (string-ascii 64)))
  (match (map-get? products { product-id: product-id })
    product (ok (get verification-count product))
    err-not-found
  )
)

(define-read-only (get-sensor-verification-count (sensor-id (string-ascii 64)))
  (match (map-get? authorized-sensors { sensor-id: sensor-id })
    sensor (ok (get verification-count sensor))
    err-not-found
  )
)

(define-read-only (is-sensor-active (sensor-id (string-ascii 64)))
  (match (map-get? authorized-sensors { sensor-id: sensor-id })
    sensor (ok (get active sensor))
    err-not-found
  )
)

(define-read-only (get-contract-stats)
  (ok {
    total-products: (var-get total-products),
    total-sensors: (var-get total-sensors),
    total-verifications: (var-get total-verifications),
    next-verification-id: (var-get next-verification-id)
  })
)

(define-read-only (get-contract-owner)
  (ok contract-owner)
)

