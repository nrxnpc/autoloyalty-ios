# Transaction Objects

Immutable value objects for tracking financial and activity transactions.

## Overview

Transaction objects provide immutable records of user activities and point-based transactions. These value objects ensure audit trail integrity and support analytics functionality.

## Value Objects

### PointTransaction
Immutable record of point-based transactions:
- **Purpose**: Track all point movements (earned, spent, bonus, penalty)
- **Immutability**: Cannot be modified after creation
- **Audit Trail**: Maintains complete transaction history
- **Analytics**: Supports user behavior analysis

#### TransactionType
- `earned`: Points gained through QR scanning ("Начислено")
- `spent`: Points used for marketplace purchases ("Потрачено")
- `bonus`: Special promotional points ("Бонус")
- `penalty`: Points deducted for violations ("Списано")

### QRScanResult
Immutable record of QR code scanning events:
- **Purpose**: Track scanning activities and point rewards
- **Data**: Points earned, product information, location, timestamp
- **Analytics**: User engagement and product interaction tracking
- **Audit**: Complete scanning history for verification

## Relationships

- **PointTransaction** ← **User**: Many-to-one via userId
- **PointTransaction** ← **QRScanResult**: One-to-one via relatedId
- **PointTransaction** ← **Order**: One-to-one via relatedId
- **QRScanResult** ← **User**: Many-to-one (implicit through processing)

## Usage Scenarios

### QR Scanning Transaction Flow
1. User scans QR code in QRScannerMainView
2. DataManager.processQRScan() creates QRScanResult
3. AuthViewModel.addPoints() updates user balance
4. DataManager.addPointTransaction() creates audit record with type .earned
5. Both objects stored in respective CollectionState containers

### Purchase Transaction Flow
1. User purchases product in marketplace
2. DataManager.addOrder() creates Order
3. AuthViewModel.spendPoints() validates and deducts balance
4. DataManager.addPointTransaction() creates audit record with type .spent
5. Transaction links to Order via relatedId

## Implementation Details

- **Network Sync**: APIPointTransaction and APIQRScan handle server communication
- **Local Processing**: QR codes processed locally when offline
- **Demo Data**: DemoDataLoader provides sample transactions
- **UI Integration**: Displayed in PointsHistoryView and QRScanHistoryView

## Business Rules

- All transactions are immutable once created
- Transaction amounts must be positive
- Each transaction links to related entities via relatedId
- QR scan results include location data for analytics
- Timestamps use system Date() for consistency
- Failed network operations queue for later synchronization