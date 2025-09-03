# Product

Marketplace items available for purchase with loyalty points.

## Overview

The `Product` entity represents items in the loyalty marketplace. Products are created by suppliers and managed through an approval workflow before becoming available to customers.

## Key Characteristics

- **Identity**: Unique `id` field for product identification
- **Mutable State**: Stock quantity, pricing, and availability change over time
- **Business Logic**: Category-based organization and delivery option management
- **Lifecycle**: Created by suppliers, approved by admins, purchased by customers

## Value Objects

### ProductCategory
Classification system for marketplace organization:
- `merchandise`: Branded items and promotional materials ("Мерч")
- `discounts`: Coupon codes and special offers ("Скидки")
- `accessories`: Vehicle-related accessories and parts ("Аксессуары")
- `services`: Professional services and consultations ("Услуги")

### DeliveryOption
Fulfillment methods available for products:
- `pickup`: Customer collection from designated locations ("Самовывоз")
- `delivery`: Direct shipping to customer address ("Доставка")
- `digital`: Electronic delivery for codes and vouchers ("Цифровая доставка")

### ProductStatus
Approval workflow states:
- `pending`: Awaiting admin review ("На модерации")
- `approved`: Available for purchase ("Одобрен")
- `rejected`: Not approved for marketplace ("Отклонен")

## Relationships

- **Product** → **Order**: One-to-many relationship for purchase history
- **Product** ← **User** (Supplier): Many-to-one relationship via supplierId
- **Product** → **APIProduct**: Conversion for network synchronization

## Usage Scenarios

1. **Marketplace Display**: Products filtered by category and approval status
2. **Purchase Flow**: Users exchange points for products through Order creation
3. **Supplier Management**: Suppliers create and manage their product inventory
4. **Admin Moderation**: Platform admins approve/reject supplier products
5. **Network Sync**: Products sync between local DataManager and remote API

## Implementation Details

- **DataManager Integration**: Products managed through `productsState` CollectionState
- **Network Mapping**: APIProduct.toProduct() converts API responses to domain objects
- **Demo Data**: DemoDataLoader provides sample products for development
- **Image Handling**: Supports both URL-based and local imageData storage

## Business Rules

- Stock quantity must be non-negative
- Only approved products appear in customer marketplace
- Category determines available delivery options
- Suppliers can only modify their own products (via supplierId)
- Products require approval workflow before becoming active
- Image data cached locally for offline access