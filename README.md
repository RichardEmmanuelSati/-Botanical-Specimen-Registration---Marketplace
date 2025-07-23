> A decentralized registry and marketplace for tokenizing botanical specimens and licensing their use 🌱

## 🚀 Overview

The Botanical Specimen Registration & Marketplace is a blockchain-based platform that enables botanists, researchers, and labs to protect, share, and monetize plant discoveries through a decentralized attribution system.

## ✨ Key Features

### 🔬 NFT Registration
- **Specimen Tokenization**: Register plant species as unique NFTs with comprehensive metadata
- **Scientific Documentation**: Include location, genetic information, and potential benefits
- **Discovery Attribution**: Permanent record of discoverer and ownership

### 📜 Smart Contract Licensing  
- **Research Licensing**: License specimens for academic and commercial research
- **Flexible Terms**: Set custom licensing prices and duration
- **Automated Payments**: Smart contract handles payments and royalty distribution

### 💰 Royalty System
- **Discoverer Royalties**: Original discoverers earn royalties on all commercial uses
- **Revenue Sharing**: Automatic distribution between current owners and discoverers
- **Platform Fees**: Configurable platform fee for marketplace sustainability

### 🗳️ Conservation DAO Voting
- **Status Proposals**: Community can propose conservation status changes
- **Democratic Voting**: Token holders vote on conservation proposals
- **Status Updates**: Automated execution of approved conservation changes

### 🎯 Crowdfunded Bounties
- **Preservation Incentives**: Create bounties for specimen preservation efforts
- **Community Funding**: Multiple contributors can fund preservation initiatives
- **Achievement Rewards**: Discoverers can claim bounties upon meeting targets

## 🛠️ Technical Implementation

### Smart Contract Functions

#### Registration & Management
- `register-specimen()` - Register a new botanical specimen NFT
- `transfer-specimen()` - Transfer specimen ownership 
- `update-license-price()` - Update licensing price for owned specimens

#### Licensing System
- `purchase-license()` - Purchase a license for specimen use
- `get-license()` - View license details and status

#### Conservation Governance
- `create-conservation-proposal()` - Propose conservation status changes
- `vote-conservation()` - Vote on conservation proposals
- `execute-conservation-proposal()` - Execute approved proposals

#### Bounty System
- `create-bounty()` - Create preservation bounties
- `contribute-to-bounty()` - Contribute funds to bounties
- `claim-bounty()` - Claim completed bounty rewards

## 🚀 Getting Started

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet with STX tokens

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/botanical-specimen-marketplace
   cd botanical-specimen-marketplace
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Run tests**
   ```bash
   clarinet test
   ```

4. **Deploy locally**
   ```bash
   clarinet console
   ```

### 📖 Usage Examples

#### Register a New Specimen
```clarity
(contract-call? .botanical-specimen-marketplace register-specimen
  "Botanicus rareus"           ;; scientific-name
  "Rare Botanical Wonder"      ;; common-name  
  "Amazon Rainforest, Brazil"  ;; location
  "Unique genetic markers..."   ;; genetic-info
  "Anti-inflammatory properties" ;; benefits
  u1000000                     ;; license-price (in microSTX)
  u10)                         ;; royalty-percent (10%)
```

#### Purchase Research License
```clarity
(contract-call? .botanical-specimen-marketplace purchase-license
  u1                    ;; specimen-id
  "research-academic"   ;; license-type
  u144)                 ;; duration (blocks)
```

#### Create Conservation Proposal
```clarity
(contract-call? .botanical-specimen-marketplace create-conservation-proposal
  u1                ;; specimen-id  
  "endangered")     ;; proposed-status
```

#### Create Preservation Bounty
```clarity
(contract-call? .botanical-specimen-marketplace create-bounty
  u1                                    ;; specimen-id
  u5000000                             ;; target-amount (in microSTX)
  "Fund preservation research study"    ;; description
  u1008)                               ;; duration (1 week in blocks)
```

## 🔧 Configuration

### Platform Settings
- **Platform Fee**: Configurable fee percentage (default: 5%)
- **Voting Duration**: Conservation proposals expire after 144 blocks (~24 hours)
- **Bounty Duration**: Customizable bounty expiration periods

### Error Codes
- `u1001` - Not authorized
- `u1002` - Not found  
- `u1003` - Already exists
- `u1004` - Invalid amount
- `u1005` - Expired
- `u1006` - Insufficient funds

## 🌱 Use Cases

### 🔬 Academic Research
- Universities license specimens for botanical studies
- Researchers access authenticated genetic data
- Automated royalty payments to discoverers

### 🏭 Commercial Applications  
- Pharmaceutical companies license for drug development
- Agricultural firms access crop improvement data
- Cosmetic companies source natural ingredients

### 🌍 Conservation Efforts
- Community votes on endangered species status
- Crowdfunded preservation initiatives
- Incentivized botanical discovery missions

## 🤝 Contributing

We welcome contributions from botanists, developers, and conservationists!

1. Fork the repository
2. Create a feature branch
3. Add comprehensive tests
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🌟 Roadmap

- [ ] Multi-chain deployment support
- [ ] Integration with botanical databases
- [ ] Mobile app for field researchers  
- [ ] AI-powered species identification
- [ ] Carbon credit integration
- [ ] Seed bank partnerships

## 🆘 Support

For questions and support:
- 📧 Email: support@botanical-nft.org  
- 💬 Discord: [Botanical DAO Community](https://discord.gg/botanical-dao)
- 🐦 Twitter: [@BotanicalNFT](https://twitter.com/botanicalnft)

---

*Protecting biodiversity through blockchain technology* 🌿✨
