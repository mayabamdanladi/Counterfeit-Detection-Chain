# 🔐 Counterfeit Detection Chain

A blockchain-based counterfeit detection system that uses IoT sensors to verify product authenticity upon arrival. Built on Stacks with Clarity smart contracts.

## 🚀 Overview

The Counterfeit Detection Chain provides a decentralized solution for product authentication using IoT sensors. When products arrive at their destination, authorized sensors automatically verify their authenticity and record the results on the blockchain, creating an immutable record of verification history.

## ✨ Key Features

- 📦 **Product Registration**: Manufacturers can register products with unique IDs, names, and batch information
- 🔍 **IoT Sensor Integration**: Authorized sensors verify product authenticity with confidence scores
- 📊 **Verification History**: Complete audit trail of all verification attempts
- 🏭 **Sensor Management**: Add, deactivate, and reactivate authorized sensors
- 📈 **Analytics**: Track total products, sensors, and verifications
- 🔒 **Access Control**: Owner-only functions for critical operations

## 🛠️ Contract Functions

### Public Functions

#### `register-product`
Register a new product in the system.
```clarity
(register-product "PROD-001" "Luxury Watch" "BATCH-2024-001")
```

#### `add-authorized-sensor`
Add a new authorized IoT sensor.
```clarity
(add-authorized-sensor "SENSOR-NYC-001" "New York Warehouse")
```

#### `verify-product`
Verify a product using an authorized sensor.
```clarity
(verify-product "PROD-001" "SENSOR-NYC-001" "Distribution Center" true u95)
```

#### `deactivate-sensor` / `reactivate-sensor`
Manage sensor status.
```clarity
(deactivate-sensor "SENSOR-NYC-001")
(reactivate-sensor "SENSOR-NYC-001")
```

### Read-Only Functions

#### `get-product`
Retrieve product information.
```clarity
(get-product "PROD-001")
```

#### `is-product-authentic`
Check if a product is verified as authentic.
```clarity
(is-product-authentic "PROD-001")
```

#### `get-contract-stats`
Get overall system statistics.
```clarity
(get-contract-stats)
```

## 🏗️ Setup & Development

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- [Node.js](https://nodejs.org/) v16+
- [Git](https://git-scm.com/)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/Counterfeit-Detection-Chain.git
   cd Counterfeit-Detection-Chain
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Run tests**
   ```bash
   clarinet test
   ```

4. **Start development console**
   ```bash
   clarinet console
   ```

## 🧪 Testing

Run the test suite to ensure everything works correctly:

```bash
# Run all tests
clarinet test

# Run specific test file
clarinet test tests/counterfeit-detection-chain.test.ts
```

## 📋 Usage Examples

### 1. Register a Product
```clarity
;; Register a new luxury watch
(contract-call? .counterfeit-detection-chain register-product 
  "WATCH-LX-001" 
  "Luxury Swiss Watch" 
  "BATCH-2024-Q1")
```

### 2. Add IoT Sensor
```clarity
;; Add sensor at distribution center
(contract-call? .counterfeit-detection-chain add-authorized-sensor 
  "SENSOR-DC-MIAMI" 
  "Miami Distribution Center")
```

### 3. Verify Product Authenticity
```clarity
;; Sensor verifies product with 98% confidence
(contract-call? .counterfeit-detection-chain verify-product 
  "WATCH-LX-001" 
  "SENSOR-DC-MIAMI" 
  "Final Inspection" 
  true 
  u98)
```

### 4. Check Product Status
```clarity
;; Check if product is authentic
(contract-call? .counterfeit-detection-chain is-product-authentic "WATCH-LX-001")

;; Get complete product information
(contract-call? .counterfeit-detection-chain get-product "WATCH-LX-001")
```

## 📊 Data Structure

### Products
```clarity
{
  manufacturer: principal,
  name: (string-ascii 100),
  batch-id: (string-ascii 64),
  created-at: uint,
  verified: bool,
  verification-count: uint,
  last-verification: uint
}
```

### Sensors
```clarity
{
  owner: principal,
  location: (string-ascii 100),
  active: bool,
  created-at: uint,
  verification-count: uint
}
```

### Verifications
```clarity
{
  product-id: (string-ascii 64),
  sensor-id: (string-ascii 64),
  verifier: principal,
  timestamp: uint,
  authentic: bool,
  location: (string-ascii 100),
  confidence-score: uint
}
```

## 🔒 Security Features

- **Owner-only functions**: Critical operations restricted to contract owner
- **Sensor authorization**: Only authorized sensors can perform verifications
- **Input validation**: All inputs validated for correctness and security
- **Immutable records**: Verification history cannot be altered once recorded
- **Confidence scoring**: Each verification includes a confidence score (0-100)

## 🌐 Integration

### IoT Sensor Integration
Sensors should:
1. Be registered as authorized sensors by the contract owner
2. Have the capability to call the `verify-product` function
3. Provide accurate location and confidence score data
4. Include proper authentication mechanisms

### Frontend Integration
Use Stacks.js to interact with the contract:

```javascript
import { callReadOnlyFunction, contractPrincipalCV, stringAsciiCV } from '@stacks/transactions';

// Check if product is authentic
const result = await callReadOnlyFunction({
  contractAddress: 'YOUR_CONTRACT_ADDRESS',
  contractName: 'counterfeit-detection-chain',
  functionName: 'is-product-authentic',
  functionArgs: [stringAsciiCV('PROD-001')],
  network: 'testnet'
});
```

## 📈 Roadmap

- 🔮 **Phase 1**: MVP with basic product registration and verification
- 🚀 **Phase 2**: Advanced sensor management and batch operations
- 🌍 **Phase 3**: Multi-chain support and cross-platform integration
- 🤖 **Phase 4**: AI-powered authenticity scoring and anomaly detection



## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For questions and support:
- 📧 Email: support@counterfeitchain.io
- 💬 Discord: [Join our community](https://discord.gg/counterfeitchain)
- 🐛 Issues: [GitHub Issues](https://github.com/your-username/Counterfeit-Detection-Chain/issues)

---

**Built with ❤️ using Stacks and Clarity**
