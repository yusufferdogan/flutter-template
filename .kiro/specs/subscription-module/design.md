# Design Document - Subscription Module

## Overview

Manages subscription plans, pricing display, and in-app purchase processing.

## Architecture

```
lib/features/subscription/
├── data/ (datasources, models, repositories)
├── domain/ (entities, repositories, usecases)
└── presentation/ (bloc, screens, widgets)
```

## Entities

```dart
enum PlanDuration { monthly, yearly }

@freezed
class SubscriptionPlan with _$SubscriptionPlan {
  const factory SubscriptionPlan({
    required String id,
    required String name,
    required double price,
    required double originalPrice,
    required PlanDuration duration,
    required List<String> features,
    required int discountPercentage,
  }) = _SubscriptionPlan;
}
```

## Key Components

- **SubscriptionBloc**: Manages plan selection and payment
- **PlanCard**: Displays plan details with pricing
- **FeatureList**: Shows premium features
- **PricingScreen**: Main subscription view

## Payment Integration

- Uses in_app_purchase package
- Supports iOS and Android payment systems
- Handles free trial period

_Requirements: 1, 2_
