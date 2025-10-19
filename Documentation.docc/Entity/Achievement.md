# Achievement

Gamification system for user engagement and retention.

## Overview

The `Achievement` entity implements a comprehensive gamification system that tracks user progress and rewards engagement. Achievements are system-defined with automatic progress tracking and unlock mechanisms.

## Key Characteristics

- **Identity**: Unique `id` field for achievement identification
- **Mutable State**: Progress tracking and unlock status change over time
- **Business Logic**: Requirement validation and reward calculation
- **Lifecycle**: System-defined, user progress automatically tracked

## Value Objects

### AchievementCategory
Classification system for achievement organization:
- `scanning`: QR code scanning related achievements
- `loyalty`: Point accumulation and tier-based achievements
- `social`: Community interaction and sharing achievements
- `special`: Time-based and unique event achievements

### AchievementRarity
Tier system indicating achievement difficulty:
- `common`: Basic achievements for new users
- `rare`: Moderate difficulty achievements
- `epic`: Challenging long-term achievements
- `legendary`: Extremely rare and difficult achievements

### AchievementReward
Rewards granted upon achievement unlock:
- `points`: Loyalty points awarded
- `title`: Special title or badge name
- `badge`: Visual badge identifier

## Business Rules

- Progress cannot exceed requirement value
- Achievements unlock automatically when requirements are met
- Rarity determines visual effects and reward scaling
- Categories group related achievements for better organization