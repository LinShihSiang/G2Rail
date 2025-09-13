# Implementation Document: Product Schloss Neuschwanstein - Step 2: Payment Flow Integration

## Overview

This document outlines the implementation plan for integrating payment processing and email confirmation functionality into the Schloss Neuschwanstein product booking flow. The implementation will modify the existing `order_page.dart` to handle payment processing and automated email notifications upon successful payment completion.

## Current System Analysis

### Existing Architecture
- **order_page.dart**: Currently handles step 1 (booking information collection)
- **payment_service.dart**: Provides Stripe-based payment processing with `processTicketPayment()` method
- **email_service.dart**: Provides email functionality with `sendBookingConfirmation()` method
- **OrderDraft**: Data model containing complete booking information
- **Product**: Model containing product details (id, name, price, currency)

### Current Payment Button Flow
The current "Proceed to Payment" button calls `submitAndGoNext()` which:
1. Validates form data
2. Creates OrderDraft from current state
3. Saves draft to repository
4. Navigates to step 2 route (`/product_schloss_neuschwanstein_order_step2`)

## Implementation Requirements

### 1. Payment Processing Integration

**Target**: Modify the payment button functionality to process payment directly instead of navigation.

**Key Components**:
- **ticketPrice**: `viewModel.totalAmount` (calculated as `unitPrice * adultCount`)
- **travelDescription**: `product.name` (e.g., "Schloss Neuschwanstein")
- **Payment Method**: Credit card only (as supported by `payment_service`)

### 2. Email Confirmation Integration

**Target**: Send order confirmation email after successful payment.

**Required Dependencies**:
- Need to add Flutter email sender dependency to `pubspec.yaml`
- Current dependencies include provider, intl, crypto, http, flutter_stripe

**Email Content Structure**:
- **Subject**: `{Product.Name} + {purchaser's name} + (DoDoMan)`
  - Example: "Schloss Neuschwanstein MikeLin (DoDoMan)"
- **Body**: Complete order information including:
  - Generated Order ID
  - Main purchaser details
  - Companions list with age indicators
  - Total amount and currency

## Detailed Implementation Plan

### 1. OrderPage.dart Modifications

#### 1.1 Import Dependencies
```dart
import '../services/payment_service.dart';
import '../services/email_service.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
```

#### 1.2 Payment Button Logic Update
**Current**: `_submitForm()` calls `viewModel.submitAndGoNext(context)`
**New**: `_submitForm()` will:
1. Validate form (existing)
2. Create OrderDraft (existing)
3. Process payment via `PaymentService.processTicketPayment()`
4. Generate Order ID
5. Send confirmation email via `EmailService`
6. Navigate to confirmation page

#### 1.3 Enhanced State Management
Add payment processing state:
```dart
bool _isProcessingPayment = false;
String? _paymentError;
```

### 2. Payment Integration Details

#### 2.1 Payment Service Call
```dart
final paymentSuccess = await PaymentService.processTicketPayment(
  ticketPrice: viewModel.totalAmount.toDouble(),
  travelDescription: viewModel.product.name,
);
```

#### 2.2 Error Handling
- Payment failure: Show error message, maintain current state
- Payment success: Proceed to email confirmation
- Network issues: Show retry option

### 3. Email Service Integration

#### 3.1 Order ID Generation
Create unique order ID using timestamp and product ID:
```dart
String generateOrderId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return 'ORDER_${product.id}_$timestamp';
}
```

#### 3.2 Email Content Construction
**Subject Format**: `"{product.name} {mainBookerName}"`

**Body Content**:
```
Order Confirmation - [Product Name]

Order ID: [Generated Order ID]
Date: [Current Date/Time]

PURCHASER DETAILS:
Name: [Main Booker Full Name]
Email: [Email Address]

COMPANIONS:
[For each companion:]
- [Companion Name] [Age Indicator: "(Under 18)" if child]

BOOKING DETAILS:
Product: [Product Name]
Date: [Selected Date]
Time: [Selected Time]
Adults: [Adult Count]
Children: [Child Count]
Unit Price: [Unit Price] [Currency]
Total Amount: [Total Amount] [Currency]
```

#### 3.3 Email Service Configuration
Utilize existing `EmailService` with required parameters:
- `customerEmail`: From OrderDraft.email
- `customerName`: From OrderDraft.mainFullNameEn
- `bookingDetails`: Formatted order information
- `paymentInfo`: Payment confirmation details

### 4. UI/UX Enhancements

#### 4.1 Payment Processing States
**Loading State**:
- Show spinner on payment button
- Disable form interactions
- Display "Processing Payment..." text

**Success State**:
- Show success message
- Display "Sending confirmation email..."
- Navigate to confirmation page

**Error State**:
- Show error message with retry option
- Re-enable form for corrections

#### 4.2 Button Text Updates
- **Initial**: "Proceed to Payment ({totalAmount} {currency})"
- **Processing**: "Processing Payment..."
- **Email Sending**: "Sending Confirmation..."

### 5. Data Model Updates

#### 5.1 Enhanced OrderDraft
Add payment-related fields if needed:
```dart
final String? orderId;
final DateTime? paymentCompletedAt;
final String? paymentTransactionId;
```

#### 5.2 Companion Age Indication
Utilize existing `CompanionDraft.isChild` boolean for age indicators in email.

### 6. Error Handling Strategy

#### 6.1 Payment Errors
- Network failures: Retry mechanism
- Invalid card: User-friendly error messages
- Processing errors: Contact support information

#### 6.2 Email Errors
- Email sending failures: Continue to confirmation page but show warning
- Invalid email format: Validate during form input (already implemented)

## Dependencies Required

### pubspec.yaml Addition
```yaml
dependencies:
  flutter_email_sender: ^6.0.3  # For email functionality
```

## File Modifications Summary

1. **lib/pages/order_page.dart**: Major modifications to payment flow
2. **pubspec.yaml**: Add email sender dependency
3. **lib/services/email_service.dart**: Potentially enhance for order-specific formatting
4. **lib/models/order_draft.dart**: Possibly add payment-related fields

## Success Criteria

1. **Payment Integration**: Successfully process payments using existing PaymentService
2. **Email Delivery**: Automatically send formatted confirmation emails
3. **Error Handling**: Graceful handling of payment and email failures
4. **User Experience**: Smooth transition from order entry to payment completion
5. **Data Integrity**: Accurate order information in both payment and email systems

## Implementation Priority

1. **High Priority**: Payment processing integration
2. **High Priority**: Basic email confirmation
3. **Medium Priority**: Enhanced error handling
4. **Low Priority**: Advanced email formatting and templating

This implementation maintains consistency with the existing Flutter architecture while adding the required payment and email functionality as specified in the requirements.