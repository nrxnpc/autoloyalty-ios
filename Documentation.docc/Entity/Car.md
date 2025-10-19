# Car

Vehicle catalog entity for automotive marketplace functionality.

## Overview

The `Car` entity represents vehicles in the automotive catalog. It maintains detailed specifications and pricing information for customer browsing and price request functionality.

## Key Characteristics

- **Identity**: Unique `id` field for vehicle identification
- **Mutable State**: Pricing, availability, and specifications can be updated
- **Business Logic**: Brand/model hierarchy and specification validation
- **Lifecycle**: Created by dealers, maintained for inventory management

## Value Objects

### CarSpecifications
Technical details and features:
- `engine`: Engine type and specifications
- `transmission`: Transmission type (manual, automatic)
- `fuelType`: Fuel requirements (gasoline, diesel, electric)
- `bodyType`: Vehicle body style (sedan, SUV, hatchback)
- `drivetrain`: Drive system (FWD, RWD, AWD)
- `color`: Vehicle exterior color

## Business Rules

- All specification fields must be provided
- Price updates require dealer authorization
- Active status controls marketplace visibility
- Specifications cannot be empty or invalid