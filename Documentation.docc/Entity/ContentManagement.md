# Content Management

Value objects for news articles and promotional campaigns.

## Overview

Content management objects handle editorial workflows and promotional campaigns. These value objects ensure content quality and campaign effectiveness through structured workflows.

## Value Objects

### NewsArticle
Content publication system with editorial workflow:
- **Purpose**: Manage news content from creation to publication
- **Workflow**: Draft → Pending → Approved/Rejected
- **Features**: Importance flagging, tagging, and scheduling
- **Integration**: Author tracking and publication management

#### NewsStatus
Editorial workflow states:
- `draft`: Work in progress, not submitted
- `pending`: Submitted for editorial review
- `approved`: Ready for publication
- `rejected`: Not approved for publication

### Lottery
Promotional campaign management system:
- **Purpose**: Manage time-bound promotional events
- **Features**: Participant tracking, winner selection, prize management
- **Timeline**: Start and end date enforcement
- **Requirements**: Minimum points for participation

## Business Rules

- News articles require approval before publication
- Important articles receive priority display
- Lotteries must have valid date ranges
- Participants must meet minimum point requirements
- Winners are selected randomly from eligible participants