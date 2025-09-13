# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Flutter** cross-platform travel booking application (g2railsample) that integrates with G2Rail APIs and Stripe payment processing. The app focuses on train travel booking between European cities with integrated payment flows.

## Development Commands

### Basic Flutter Commands
- `flutter run` - Run the app in debug mode
- `flutter build apk` - Build Android APK
- `flutter build apk --release` - Build release Android APK
- `flutter build ios` - Build iOS app (macOS only)
- `flutter build ios --release` - Build release iOS app (macOS only)
- `flutter test` - Run all tests
- `flutter test test/widget_test.dart` - Run specific test file
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

The current codebase follows a basic Flutter structure but is planned to evolve into a layered architecture as defined in the Product Requirements Document:

### Project Structure (per PRD)
```
lib/
├── pages/              # UI pages (Flutter Widgets)
│   ├── home_page.dart           # Travel products listing
│   ├── product_page.dart        # Product details (e.g., Schloss Neuschwanstein)
│   ├── order_page.dart          # Booking form with passenger info
│   ├── payment_page.dart        # Payment processing page
│   └── confirmation_page.dart   # Order confirmation & receipt
├── services/           # Handle interaction events / call repos
│   ├── order_service.dart       # Order management and travel search
│   ├── payment_service.dart     # Payment processing logic
│   └── email_service.dart       # Email confirmation handling
├── repos/              # API integration logic
│   ├── travel_repo.dart         # G2Rail API integration
│   ├── payment_repo.dart        # Stripe payment integration
│   └── email_repo.dart          # Email service integration
├── models/             # Data Objects (per PRD - not yet implemented)
│   └── product_model.dart       # Product data models
└── main.dart           # App entry point
```

**Layer Responsibilities:**
- **pages**: UI layouts, display content, bind user actions
- **services**: Handle UI interaction logic, button events, call repos, manage state
- **repos**: Third-party API integration (travel products, payments, email, train schedules)
- **models**: Data objects and model classes for type safety and data structure

## Key Integrations

### G2Rail API (travel_repo.dart)
- Base URL: `http://alpha-api.g2rail.com`
- Requires API key and secret (currently placeholder values in order_service.dart)
- Uses MD5-based authorization with timestamp and parameter sorting
- Authorization process: sorts parameters alphabetically, concatenates with secret, generates MD5 hash
- Supports train search between European cities with passenger type breakdowns
- Methods: `getSolutions(from, to, date, time, adult, child, junior, senior, infant)`, `getAsyncResult(asyncKey)`
- Returns JSON with solutions array containing train options and pricing

### Stripe Payment Processing (payment_repo.dart)
- Test environment with hardcoded keys
- Supports payment sheets UI for seamless checkout
- Methods: `processPaymentWithSheet()`, `createPaymentIntent()`, `processPayment()`

### Email Notifications (email_repo.dart)
- Placeholder implementation for booking confirmations
- Configurable email service provider (SendGrid, AWS SES, etc.)
- Method: `sendConfirmationEmail()`

## Dependencies

### Core Dependencies
- `http: ^1.5.0` - HTTP client for API calls
- `flutter_stripe: ^11.1.0` - Stripe payment integration
- `crypto: ^3.0.6` - Cryptographic functions for API auth
- `intl: ^0.20.2` - Internationalization support

### Development
- `flutter_lints: ^5.0.0` - Linting rules
- Uses `package:flutter_lints/flutter.yaml` for recommended lint rules

## Security Considerations

- API keys and secrets are currently hardcoded in source files - these should be moved to environment variables or secure configuration
- SSL certificate validation is disabled in HTTP client (`badCertificateCallback`)
- Stripe keys are test keys and should be replaced with production keys for deployment

## Environment Requirements

- **Flutter SDK**: 3.5.0+ (current pubspec: ^3.9.0 Dart SDK)
- **Android**: API level 30+ (Android 10+)
- **iOS**: 14.0+ (macOS development only)
- **Development**: Uses `package:flutter_lints/flutter.yaml` for linting rules

## Development Notes

- Uses Material Design for UI components
- Multi-language support (EN/ZH) planned but not yet implemented
- Currently in prototype phase with basic payment flow working
- SSL certificate validation is currently disabled for development (`badCertificateCallback`)
- No models layer implemented yet (mentioned in PRD but not in current structure)

## Important Implementation Details

### Project Structure Deviation from PRD
The actual implementation matches the documented structure in this file, but the PRD mentions a `models/` directory that doesn't exist yet. Future development should consider adding data models for better type safety and code organization.

### Authentication Flow
The G2Rail API uses a specific authentication pattern where parameters are sorted alphabetically, concatenated with the secret key, and then MD5 hashed. The `TravelRepo.getAuthorizationHeaders()` method handles this complexity.