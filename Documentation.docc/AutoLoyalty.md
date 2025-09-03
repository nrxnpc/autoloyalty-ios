# AutoLoyalty

A comprehensive loyalty program platform for automotive parts and services.

## Overview

AutoLoyalty is an iOS application that implements a points-based loyalty system for the automotive industry. Users earn points by scanning QR codes on automotive products and can exchange these points for merchandise, discounts, and services in the integrated marketplace.

## Key Features

- **QR Code Scanning**: Earn loyalty points by scanning product QR codes
- **Points Marketplace**: Exchange points for automotive products and services  
- **Vehicle Catalog**: Browse cars and request pricing from dealers
- **Achievement System**: Unlock rewards through gamified user engagement
- **Content Management**: News articles and promotional campaigns
- **Customer Support**: Integrated ticketing and messaging system

## Core Business Objects

### Domain Entities
- **<doc:User>**: Central user entity with roles, points, and preferences
- **<doc:Product>**: Marketplace items with approval workflow
- **<doc:Car>**: Vehicle catalog for price requests
- **<doc:Achievement>**: Gamification system with progress tracking

### Value Objects
- **<doc:TransactionObjects>**: Point transactions and QR scan results
- **<doc:OrderManagement>**: Orders and price requests
- **<doc:ContentManagement>**: News articles and lottery campaigns
- **<doc:SupportSystem>**: Support tickets and messaging

## Architecture

The application follows Domain-Driven Design principles with clear separation between:
- **Entities**: Objects with unique identity and mutable state
- **Value Objects**: Immutable objects defined by their attributes
- **Services**: Business logic and external integrations

For detailed architectural patterns, see <doc:DesignPatterns>.

## User Flows

1. **Loyalty Earning**: Scan QR codes → Earn points → Track in profile
2. **Marketplace Shopping**: Browse products → Exchange points → Track orders
3. **Vehicle Inquiry**: Browse cars → Request pricing → Receive dealer quotes
4. **Achievement Progress**: Complete activities → Unlock achievements → Earn rewards

For comprehensive usage scenarios, see <doc:UsageScenarios>.

## Technical Implementation

- **Data Management**: Centralized DataManager with lazy loading
- **Authentication**: JWT-based auth with offline capability
- **Network Sync**: Hybrid online/offline data synchronization
- **UI Architecture**: SwiftUI with MVVM pattern

## Getting Started

To understand the domain model structure:
1. Start with <doc:DomainModel> for overall architecture
2. Review <doc:User> as the central entity
3. Explore <doc:UsageScenarios> for real-world flows
4. Reference <doc:DesignPatterns> for implementation details

## Topics

### Domain Model
- <doc:DomainModel>
- <doc:User>
- <doc:Product>
- <doc:Car>
- <doc:Achievement>

### Value Objects
- <doc:TransactionObjects>
- <doc:OrderManagement>
- <doc:ContentManagement>
- <doc:SupportSystem>

### Architecture
- <doc:DesignPatterns>
- <doc:UsageScenarios>