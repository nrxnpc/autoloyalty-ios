# Order Management

Value objects for purchase transactions and pricing inquiries.

## Overview

Order management objects handle the complete purchase lifecycle from initial inquiry to final delivery. These value objects maintain transaction integrity and workflow state.

## Value Objects

### Order
Purchase transaction record with comprehensive status tracking:
- **Purpose**: Track complete purchase lifecycle
- **Workflow**: Pending → Confirmed → Processing → Shipped → Delivered
- **Integration**: Links user, product, and delivery information
- **Tracking**: Includes delivery address and tracking numbers

#### OrderStatus
Workflow states for order processing:
- `pending`: Awaiting confirmation
- `confirmed`: Order accepted and validated
- `processing`: Preparing for shipment
- `shipped`: In transit to customer
- `delivered`: Successfully completed
- `cancelled`: Order terminated

### PriceRequest
Customer inquiry system for vehicle pricing:
- **Purpose**: Enable customer-dealer communication for pricing
- **Workflow**: Pending → Responded → Expired
- **Integration**: Links customer, vehicle, and dealer response
- **Timeline**: Automatic expiration for timely responses

#### PriceRequestStatus
Communication workflow states:
- `pending`: Awaiting dealer response
- `responded`: Dealer has provided pricing
- `expired`: Request timed out without response

## Relationships

- **Order** ← **User**: Many-to-one via userId
- **Order** ← **Product**: Many-to-one via embedded product
- **Order** → **PointTransaction**: One-to-one for payment record
- **PriceRequest** ← **User**: Many-to-one via userId
- **PriceRequest** ← **Car**: Many-to-one via embedded car

## Usage Scenarios

### Order Creation Flow
1. User selects product in CatalogView
2. DataManager.addOrder() creates Order with status .pending
3. AuthViewModel.spendPoints() validates and deducts points
4. PointTransaction created to record payment
5. Order appears in ProfileView → MyOrdersView

### Price Request Flow
1. User swipes car in CarTinderView
2. User taps "Запросить цену"
3. DataManager.createPriceRequest() creates request
4. Request appears in ProfileView → PriceRequestsView
5. Dealer responds, updating status to .responded

## Implementation Details

- **Order Tracking**: Orders displayed in MyOrdersView with status colors
- **Delivery Options**: Integrated with Product.DeliveryOption enum
- **Address Handling**: Optional deliveryAddress for shipping orders
- **Demo Data**: Sample orders provided by DemoDataLoader
- **UI Components**: OrderRow and PriceRequestRow for list display

## Business Rules

- Orders cannot skip workflow states (pending → confirmed → processing → shipped → delivered)
- Price requests expire after defined period (handled by .expired status)
- All state changes are timestamped for audit trail
- Cancelled orders cannot be reactivated
- Order points must match product pointsCost
- Price requests require valid car and user references