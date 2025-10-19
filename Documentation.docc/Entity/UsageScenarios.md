# Usage Scenarios

Real-world usage patterns and business flows in the AutoLoyalty application.

## Overview

This document describes how domain objects interact in actual business scenarios, based on the implemented codebase. Each scenario shows the flow of data and relationships between entities.

## Core Business Scenarios

### 1. QR Code Scanning Flow

**Actors**: User, QRScannerService, DataManager, AuthViewModel

**Flow**:
1. User opens QRScannerMainView and taps "Сканировать QR-код"
2. QRCodeScannerView captures QR code using AVFoundation
3. DataManager.processQRScan() processes the code:
   - Creates QRScanResult with points earned and product info
   - If network available, validates with API
   - Falls back to local processing if offline
4. AuthViewModel.addPoints() updates user's point balance
5. DataManager creates PointTransaction record for audit trail
6. User sees success alert with points earned

**Objects Created**:
- `QRScanResult`: Immutable record of scanning event
- `PointTransaction`: Audit trail of points earned
- User points balance updated

### 2. Marketplace Purchase Flow

**Actors**: User, Product, DataManager, AuthViewModel

**Flow**:
1. User browses products in CatalogView
2. User selects product and delivery option
3. AuthViewModel.spendPoints() validates sufficient balance
4. DataManager.addOrder() creates Order with status .pending
5. DataManager.addPointTransaction() records points spent
6. Order progresses through workflow states
7. User can track order in ProfileView → MyOrdersView

**Objects Created**:
- `Order`: Purchase transaction record
- `PointTransaction`: Record of points spent
- User points balance decreased

### 3. Vehicle Price Request Flow

**Actors**: User, Car, DataManager

**Flow**:
1. User swipes through cars in CarTinderView
2. User taps "Запросить цену" on interesting vehicle
3. DataManager.createPriceRequest() creates request with status .pending
4. Dealer receives notification and responds
5. PriceRequest status changes to .responded
6. User views response in ProfileView → PriceRequestsView

**Objects Created**:
- `PriceRequest`: Customer inquiry record
- Links User and Car entities

### 4. Achievement Unlock Flow

**Actors**: User, Achievement, AchievementService

**Flow**:
1. User performs activities (QR scans, purchases, logins)
2. AchievementService.checkAchievements() evaluates progress
3. Achievement progress updated based on user statistics
4. When requirement met, achievement unlocks automatically
5. User receives notification and haptic feedback
6. Achievement appears in user's collection

**Objects Updated**:
- `Achievement`: Progress and unlock status
- `User`: Statistics that trigger achievements

### 5. Support Ticket Flow

**Actors**: User, SupportTicket, SupportMessage

**Flow**:
1. User creates support ticket in SupportChatView
2. SupportTicket created with status .open
3. User and support exchange SupportMessage objects
4. Ticket progresses through workflow: .open → .inProgress → .resolved → .closed
5. Message history preserved for reference

**Objects Created**:
- `SupportTicket`: Support case container
- `SupportMessage`: Individual communications

## Data Management Patterns

### Lazy Loading Strategy

DataManager implements lazy loading for performance:
```swift
enum DataType: CaseIterable {
    case cars, products, users, orders, priceRequests, news, lotteries, pointTransactions, supportTickets, qrScans
}
```

Data loaded only when needed:
- QR scans loaded when QRScannerMainView appears
- Orders loaded when MyOrdersView appears
- Point transactions loaded when PointsHistoryView appears

### Network Synchronization

Objects sync between local and remote storage:
- **Online**: API calls with fallback to local processing
- **Offline**: Local processing with sync queue for later upload
- **Hybrid**: Local-first with background synchronization

### State Management

CollectionState pattern manages object collections:
- Loading states for UI feedback
- Error handling for network failures
- Optimistic updates for better UX

## Authentication Integration

AuthViewModel serves as central user context:
- Manages current user session
- Handles point balance operations
- Provides user ID for data filtering
- Triggers data cleanup on logout

## Notification Patterns

System uses NotificationCenter for decoupled communication:
- `.userLoggedOut`: Triggers data cleanup
- `.userRegistered`: Adds new user to DataManager
- Achievement unlocks trigger haptic feedback and toasts

## Error Handling Strategies

1. **Network Errors**: Graceful fallback to local processing
2. **Validation Errors**: User-friendly error messages
3. **State Errors**: Optimistic updates with rollback capability
4. **Resource Errors**: Lazy loading and memory management

## Performance Optimizations

1. **Image Caching**: Local imageData storage for offline access
2. **Lazy Loading**: Data loaded on-demand per screen
3. **Background Processing**: Heavy operations on utility queues
4. **Memory Management**: Weak references and proper cleanup