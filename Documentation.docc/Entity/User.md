# User

Core business entity representing system users with different roles and capabilities.

## Overview

The `User` entity is the central domain object that represents all system participants. It maintains identity through a unique ID and encapsulates user-specific business logic including role-based permissions and loyalty calculations.

## Key Characteristics

- **Identity**: Unique `id` field ensures entity persistence
- **Mutable State**: Points, preferences, and statistics evolve over time
- **Business Logic**: Role-based access control and loyalty tier management
- **Lifecycle**: Created at registration, persists throughout user journey

## Value Objects

### UserPreferences
Encapsulates notification settings and category preferences:
- `notificationsEnabled`: Global notification toggle
- `emailNotifications`: Email communication preference  
- `pushNotifications`: Mobile notification preference
- `preferredCategories`: User's interested automotive categories (autoparts, oils, tires, accessories, tools, electronics)

### UserStatistics
Performance metrics and activity tracking:
- `totalPurchases`: Number of completed QR scan transactions
- `totalSpent`: Cumulative spending amount in rubles
- `averageOrderValue`: Average transaction value
- `loyaltyTier`: Current loyalty level ("Бронза", "Серебро", "Золото")
- `joinedPromotions`: Number of lottery participations
- `createdContent`: Content created by suppliers
- `totalPointsEarned`: Lifetime points accumulation
- `lastActivityDate`: Most recent user activity timestamp

### UserType
Classification system:
- `individual`: Personal account ("Физическое лицо")
- `business`: Corporate account ("Юридическое лицо")

### UserRole
Permission-based roles:
- `customer`: Standard user with QR scanning and purchasing capabilities
- `supplier`: Product provider with inventory management and content creation
- `platformAdmin`: System administrator with full access to all features

## Relationships

- **User** → **PointTransaction**: One-to-many relationship for point history
- **User** → **QRScanResult**: One-to-many relationship for scanning activity
- **User** → **Order**: One-to-many relationship for marketplace purchases
- **User** → **PriceRequest**: One-to-many relationship for vehicle inquiries
- **User** → **SupportTicket**: One-to-many relationship for customer service
- **User** → **Achievement**: Many-to-many relationship through progress tracking

## Usage Scenarios

1. **Authentication Flow**: AuthViewModel manages user login/registration and token persistence
2. **Profile Management**: Users can update personal information, view statistics, and manage preferences
3. **Point Operations**: AuthViewModel handles point addition/spending with server synchronization
4. **Data Synchronization**: User data syncs between local storage and remote API

## Business Rules

- Points balance cannot be negative (validated in AuthViewModel.spendPoints)
- Role determines available system features and UI access
- Statistics update automatically on user actions (QR scans, purchases)
- Preferences control notification delivery and content filtering
- Suppliers have additional supplierID field for business operations