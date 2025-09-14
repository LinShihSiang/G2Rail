# Product Requirement Document (PRD)

## 1. Init

This project is a **cross-platform (Android/iOS)** application developed
using **Flutter**.\
Product positioning: Integrated travel agency service app.\
Main features include:\
- Display and booking of popular group travel packages\
- International flight and ticket booking\
- Foreign train schedule query\
- Order processing and payment workflow

------------------------------------------------------------------------

## 2. Project Structure

    project-root/
    ├── android/         # Android platform-specific files
    ├── ios/             # iOS platform-specific files
    ├── lib/
    │   ├── pages/       # UI pages (Flutter Widgets)
    │   │   ├── order_page.dart
    │   │   ├── payment_page.dart
    │   │   ├── confirmation_page.dart
    │   │   └── ...
    │   ├── services/    # Handle interaction events / call repos
    │   │   ├── order_service.dart
    │   │   ├── payment_service.dart
    │   │   └── email_service.dart
    │   ├── repos/       # API integration logic
    │   │   ├── travel_repo.dart
    │   │   ├── payment_repo.dart
    │   │   ├── email_repo.dart
    │   ├── models/       # Data Object
    │   │   ├── product_model.dart
    │   └── main.dart    # App entry point

-   **pages**:
    -   Contain UI layouts, responsible for displaying content and
        binding user actions.\
-   **services**:
    -   Handle UI interaction logic, such as button event handling,
        calling `repos` to access APIs, and managing state.\
-   **repos**:
    -   Handle third-party API integration (travel products, payments,
        email, train schedule queries).

------------------------------------------------------------------------

## 3. Feature Requirements

### Home Page

-   Step 1: List all available travel products\
-   Step 2: Navigate to product detail page

### Product Page - Schloss Neuschwanstein

-   Step 1: Order page (display selected product, input quantity, date,
    passenger info)\
-   Step 2: Payment flow (integrate with third-party payment APIs such
    as Stripe/PayPal)\
-   Step 3: After successful payment, send confirmation email\
-   Step 4: Display order confirmation page with payment details

------------------------------------------------------------------------

## 4. Non-functional Requirements (Optional)

-   Support Android 10+ / iOS 14+\
-   UI based on Flutter Material Design\
-   API communication via HTTPS (REST/JSON)\
-   Multi-language support (EN/ZH)
