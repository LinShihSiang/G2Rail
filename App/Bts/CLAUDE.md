# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Flutter** cross-platform travel booking application (g2railsample) that integrates with G2Rail APIs and Stripe payment processing. The app focuses on European travel packages and train booking with integrated payment flows.

## Development Commands

### Basic Flutter Commands
- `flutter run` - Run the app in debug mode
- `flutter build apk` - Build Android APK
- `flutter build apk --release` - Build release Android APK
- `flutter build ios` - Build iOS app (macOS only)
- `flutter build ios --release` - Build release iOS app (macOS only)
- `flutter analyze` - Run static analysis/linting
- `flutter clean` - Clean build artifacts
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Update dependencies
- `flutter pub deps` - Show dependency tree

### Platform-Specific Testing
- `flutter run -d android` - Run on Android device/emulator
- `flutter run -d ios` - Run on iOS simulator (macOS only)
- `flutter devices` - List connected devices and emulators

## Architecture

The project implements a layered architecture with **MVVM pattern** for state management:

### Actual Project Structure
```
lib/
├── main.dart                    # App entry point with dependency injection
├── pages/                       # UI pages (Flutter Widgets)
│   ├── home_page.dart           # Product catalog listing
│   ├── product_page.dart        # Generic product details
│   ├── product_schloss_neuschwanstein_page.dart  # Specific product page
│   ├── germany_products_page.dart               # Germany packages page
│   ├── order_page.dart          # Booking form with passenger info
│   ├── payment_page.dart        # Payment processing page
│   └── confirmation_page.dart   # Order confirmation & receipt
├── services/                    # Business logic layer
│   ├── order_service.dart       # Order management and travel search
│   ├── payment_service.dart     # Payment processing logic
│   ├── email_service.dart       # Email confirmation handling
│   ├── station_service.dart     # Station/location services
│   └── price_formatter.dart     # Price formatting utilities
├── view_models/                 # MVVM ViewModels for state management
│   └── order_step1_view_model.dart  # Order form state management
├── repos/                       # Data access layer
│   ├── product_repo.dart        # Product catalog (in-memory)
│   ├── travel_repo.dart         # G2Rail API integration
│   ├── payment_repo.dart        # Stripe payment integration
│   ├── email_repo.dart          # Email service integration
│   ├── germany_tours_repo.dart  # Germany tour packages (JSON data)
│   └── order_draft_repo.dart    # Order draft persistence
├── models/                      # Data models and state objects
│   ├── order_draft.dart         # Order draft data model
│   └── order_step1_state.dart   # Order form state model
├── repos/models/                # Repository-specific models
│   ├── product.dart             # Product data model
│   ├── germany_tour_package.dart  # Germany tour package model
│   └── german_station.dart      # German station model
├── widgets/                     # Reusable UI components
│   └── germany_tour_card.dart   # Tour package card widget
└── example_germany_integration.dart  # Integration example
```

### Data Sources
- `data/` - JSON files containing tour packages and station data
  - `Italy_Germany_tours.json` - Tour package data
  - `80_Germany.json` - German station data
  - `tours.json` - Additional tour data

**Layer Responsibilities:**
- **pages**: UI layouts, display content, bind user actions
- **view_models**: MVVM pattern for state management, business logic for UI
- **services**: Application services, coordinate between repos and UI
- **repos**: Data access layer - APIs, local storage, JSON assets
- **models**: Data structures and state objects
- **widgets**: Reusable UI components

## Key Integrations

### G2Rail API (travel_repo.dart)
- Base URL: `http://alpha-api.g2rail.com`
- Requires API key and secret (placeholder values in order_service.dart)
- Uses MD5-based authorization with timestamp and parameter sorting
- Authorization: sorts parameters alphabetically, concatenates with secret, generates MD5 hash
- Methods: `getSolutions()`, `getAsyncResult(asyncKey)` for train search
- Returns JSON with train options and pricing by passenger type

### Stripe Payment Processing (payment_repo.dart)
- Test environment with hardcoded keys
- Payment sheets UI for seamless checkout
- Methods: `processPaymentWithSheet()`, `createPaymentIntent()`, `processPayment()`

### Local Data Sources
- **GermanyToursRepo**: Loads tour packages from `data/Italy_Germany_tours.json`
- **Station Services**: German station data from `data/80_Germany.json`
- **ProductRepo**: In-memory product catalog with Schloss Neuschwanstein and Germany packages

## Dependencies

### Core Dependencies
- `flutter_stripe: ^12.0.2` - Stripe payment integration (updated version)
- `http: ^1.5.0` - HTTP client for API calls
- `crypto: ^3.0.6` - Cryptographic functions for API auth
- `provider: ^6.1.5+1` - State management for MVVM pattern
- `flutter_typeahead: ^5.2.0` - Autocomplete input widgets
- `flutter_email_sender: ^8.0.0` - Email functionality
- `excel: ^4.0.6` - Excel file processing
- `intl: ^0.20.2` - Internationalization support

### Development
- `flutter_lints: ^5.0.0` - Linting rules using `package:flutter_lints/flutter.yaml`

## Architecture Patterns

### MVVM Pattern
- **View Models** extend `ChangeNotifier` for reactive state management
- **OrderStep1ViewModel** manages order form state with companion management
- State objects like `OrderStep1State` contain UI state data
- Views listen to ViewModel changes via `provider` package

### Repository Pattern
- Abstract base classes define contracts (e.g., `ProductRepo`)
- Concrete implementations handle specific data sources
- **InMemoryProductRepo** for catalog, **GermanyToursRepo** for JSON assets
- Clear separation between data access and business logic

### Dependency Injection
- Constructor injection in `main.dart`
- Services instantiate their own repo dependencies
- HTTP client configuration centralized in services

## Security Considerations

- API keys hardcoded in `order_service.dart` - move to environment variables
- SSL validation disabled via `badCertificateCallback` - fix for production
- Test Stripe keys - replace with production keys for deployment

## Development Notes

- Uses Material Design 3 (`useMaterial3: true`)
- Multi-language support (EN/ZH) planned but not implemented
- Flutter SDK requirement: ^3.9.0 (Dart SDK)
- Target platforms: Android 10+ / iOS 14+
- Assets include images and JSON data files

## Key Implementation Details

### G2Rail Authentication Flow
The `TravelRepo.getAuthorizationHeaders()` method implements the specific MD5-based auth:
1. Sort parameters alphabetically by key
2. Concatenate sorted params with secret key
3. Generate MD5 hash for authorization header

### State Management Pattern
- **OrderStep1ViewModel** manages companion lists, validation, derived counts
- **OrderDraft** models provide JSON serialization for persistence
- **ChangeNotifier** pattern enables reactive UI updates