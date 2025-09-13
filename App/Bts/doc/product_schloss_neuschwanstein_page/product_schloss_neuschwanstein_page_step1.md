# Product — Schloss Neuschwanstein — Step 1: Order Page (Implementation Doc for Claude)

> **Platform:** Flutter (iOS/Android)  
> **Route name:** `product_schloss_neuschwanstein_order_step1`  
> **Price source:** `ProductRepo` (`price = 21`, `currency = 'EUR'`)  
> **Total formula:** `Product.price × AdultCount` (main booker is always counted as an adult)

---

## 1) Page Goals & Scope
- Collect main booker information (English Name, Email, Date, Time).  
- Allow up to **10 companions**, each requiring: English Name and Child status (< 18 years).  
- Display real-time calculations: **Adults / Children / Total People / Total Amount**.  
- This step only saves a local draft and navigates to Step 2 (Payment).  
  > No payment, email, or confirmation logic at this stage.

---

## 2) UI Specifications
- **Main Booker Card**: English Name, Email, Date Picker, Time Picker (with validation).  
- **Companion Card**: List view (Name + Child toggle + Delete button), Add button (limit 10).  
- **Summary Section**: Adult/Child counts, total people, **Unit Price (EUR/Adult)**, **Total Amount**, and Next Step button.

---

## 3) State Management
- Suggested: `ChangeNotifier + Provider` or `Riverpod`.  
- **ViewModel**: `OrderStep1ViewModel` to handle state, counters, and submission logic.

---

## 4) Validation Rules
- **English Name**: Required; uppercase letters, spaces, hyphen, apostrophe; min length 2.  
  Example Regex: `^[A-Z][A-Z\s'-]{1,49}$`  
- **Email**: Required; simplified RFC5322 format.  
- **Date/Time**: Required; Date cannot be earlier than today.  
- **Companions**: Each requires English Name and Child flag.  
- **Count Limits**: Max 10 companions; main booker is always adult.

---

## 5) Data Model (Local State)
```dart
class Companion {
  String fullNameEn; // required
  bool isChild;      // required
  Companion({required this.fullNameEn, required this.isChild});
}

class OrderStep1State {
  String fullNameEn;
  String email;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  List<Companion> companions;

  OrderStep1State({
    this.fullNameEn = '',
    this.email = '',
    this.selectedDate,
    this.selectedTime,
    List<Companion>? companions,
  }) : companions = companions ?? [];
}
```
> Calculation logic (counts and amount) lives in the ViewModel, referencing the `Product` price.

---

## 6) ViewModel API
```dart
abstract class OrderStep1ViewModel extends ChangeNotifier {
  // Product (from ProductRepo)
  Product get product;

  // State
  OrderStep1State get state;

  // Main booker
  void setFullNameEn(String value);
  void setEmail(String value);
  void setDate(DateTime date);
  void setTime(TimeOfDay time);

  // Companions
  void addCompanion(); // default isChild = false
  void updateCompanionName(int index, String name);
  void toggleCompanionIsChild(int index, bool isChild);
  void removeCompanion(int index);

  // Derived values
  int get adultCount;     // 1 (main booker) + non-child companions
  int get childCount;     // child companions
  int get totalPeople;    // adultCount + childCount
  num get unitPrice;      // product.price
  String get currency;    // product.currency
  num get totalAmount;    // unitPrice × adultCount

  // Validation & Navigation
  bool get isFormValid;
  Map<String, String?> get errors;
  Future<void> submitAndGoNext(BuildContext context);
}
```

---

## 7) DTO / Repo Interface (Revised)

**Existing**  
```dart
class Product {
  final String id;
  final String name;
  final String imageUrl;
  final String propaganda;
  final num price;
  final String currency;
  const Product({...});
}

abstract class ProductRepo {
  Future<List<Product>> getAll();
}
```

### 7.1 Order Draft DTO  
**New file: `order_draft.dart`**

Captures a **snapshot** of the product’s price and currency at booking time, preventing draft orders from being affected by later price changes.  

```dart
class OrderDraft {
  final String productId;
  final String productName;
  final num unitPrice;
  final String currency;

  // Booker
  final String mainFullNameEn;
  final String email;

  // When
  final DateTime dateTime;

  // Companions
  final List<CompanionDraft> companions;

  // Derived values
  final int adultCount;
  final int childCount;
  final num totalAmount;

  const OrderDraft({...});

  factory OrderDraft.fromState({...});
}

class CompanionDraft {
  final String fullNameEn;
  final bool isChild;
  const CompanionDraft({required this.fullNameEn, required this.isChild});
}
```

---

### 7.2 Order Draft Storage  
**New file: `order_draft_repo.dart`**

Stores the draft locally (e.g., via `SharedPreferences`).  

```dart
abstract class OrderDraftRepo {
  Future<void> save(OrderDraft draft);
  Future<OrderDraft?> getLatest();
  Future<void> clear();
}
```

---

## 9) Interaction Details (UX)
- Adding a companion auto-focuses the name field and scrolls to the new entry.  
- Deleting a companion requires no confirmation.  
- Errors display in real time; Next button disabled until `isFormValid`.  
- Next button shows short loading state to prevent duplicate submission.

---

## 10) Accessibility
- Provide `semanticsLabel` for fields and actions.  
- Error messages should be screen-reader friendly.

---

## 11) Telemetry (if enabled)
- `order_step1_add_companion`  
- `order_step1_remove_companion`  
- `order_step1_submit_click` (with adultCount, childCount, totalAmount)  
- `order_step1_validation_error` (firstErrorKey)

---

## 13) Logic Notes
- Main booker is always counted as an adult.  
- Price and currency are snapshotted into `OrderDraft`.  
- Amount is always displayed in EUR (no currency conversion).

---

## 14) Out of Scope
- Payment integration (Step 2)  
- Email confirmation (Step 3)  
- Order confirmation page (Step 4)  
- Backend API calls

---

## 15) Deliverables Checklist
- [ ] `OrderStep1ViewModel` (validation, calculations, submission)  
- [ ] `OrderStep1Page` (UI & interactions)  
- [ ] `order_draft.dart`, `order_draft_repo.dart` (local draft storage)  
- [ ] Navigation to Step 2 (Payment)
