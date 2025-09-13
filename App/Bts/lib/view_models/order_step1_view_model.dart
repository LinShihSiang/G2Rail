import 'package:flutter/material.dart';
import '../models/order_step1_state.dart';
import '../models/order_draft.dart';
import '../repos/models/product.dart';
import '../repos/order_draft_repo.dart';

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

class OrderStep1ViewModelImpl extends OrderStep1ViewModel {
  final Product _product;
  final OrderDraftRepo _orderDraftRepo;
  OrderStep1State _state;

  OrderStep1ViewModelImpl({
    required Product product,
    required OrderDraftRepo orderDraftRepo,
  }) : _product = product,
       _orderDraftRepo = orderDraftRepo,
       _state = OrderStep1State();

  @override
  Product get product => _product;

  @override
  OrderStep1State get state => _state;

  // Main booker methods
  @override
  void setFullNameEn(String value) {
    _state = _state.copyWith(fullNameEn: value);
    notifyListeners();
  }

  @override
  void setEmail(String value) {
    _state = _state.copyWith(email: value);
    notifyListeners();
  }

  @override
  void setDate(DateTime date) {
    _state = _state.copyWith(selectedDate: date);
    notifyListeners();
  }

  @override
  void setTime(TimeOfDay time) {
    _state = _state.copyWith(selectedTime: time);
    notifyListeners();
  }

  // Companion methods
  @override
  void addCompanion() {
    if (_state.companions.length < 10) {
      final companions = List<Companion>.from(_state.companions);
      companions.add(Companion(fullNameEn: '', isChild: false));
      _state = _state.copyWith(companions: companions);
      notifyListeners();
    }
  }

  @override
  void updateCompanionName(int index, String name) {
    if (index < _state.companions.length) {
      final companions = List<Companion>.from(_state.companions);
      companions[index] = companions[index].copyWith(fullNameEn: name);
      _state = _state.copyWith(companions: companions);
      notifyListeners();
    }
  }

  @override
  void toggleCompanionIsChild(int index, bool isChild) {
    if (index < _state.companions.length) {
      final companions = List<Companion>.from(_state.companions);
      companions[index] = companions[index].copyWith(isChild: isChild);
      _state = _state.copyWith(companions: companions);
      notifyListeners();
    }
  }

  @override
  void removeCompanion(int index) {
    if (index < _state.companions.length) {
      final companions = List<Companion>.from(_state.companions);
      companions.removeAt(index);
      _state = _state.copyWith(companions: companions);
      notifyListeners();
    }
  }

  // Derived values
  @override
  int get adultCount => 1 + _state.companions.where((c) => !c.isChild).length;

  @override
  int get childCount => _state.companions.where((c) => c.isChild).length;

  @override
  int get totalPeople => adultCount + childCount;

  @override
  num get unitPrice => _product.price;

  @override
  String get currency => _product.currency;

  @override
  num get totalAmount => unitPrice * adultCount;

  // Validation
  @override
  bool get isFormValid {
    final validationErrors = errors;
    return validationErrors.values.every((error) => error == null);
  }

  @override
  Map<String, String?> get errors {
    final Map<String, String?> errors = {};

    // Validate main booker name
    if (_state.fullNameEn.isEmpty) {
      errors['fullNameEn'] = 'English name is required';
    } else if (_state.fullNameEn.length < 2) {
      errors['fullNameEn'] = 'English name must be at least 2 characters long';
    }

    // Validate email
    if (_state.email.isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(_state.email)) {
      errors['email'] = 'Please enter a valid email address';
    }

    // Validate date
    if (_state.selectedDate == null) {
      errors['date'] = 'Date is required';
    } else if (_state.selectedDate!.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      errors['date'] = 'Date cannot be earlier than today';
    }

    // Validate time
    if (_state.selectedTime == null) {
      errors['time'] = 'Time is required';
    }

    // Validate companions
    for (int i = 0; i < _state.companions.length; i++) {
      final companion = _state.companions[i];
      if (companion.fullNameEn.isEmpty) {
        errors['companion_${i}_name'] = 'Companion name is required';
      } else if (companion.fullNameEn.length < 2) {
        errors['companion_${i}_name'] = 'Companion name must be at least 2 characters long';
      }
    }

    return errors;
  }

  // Navigation
  @override
  Future<void> submitAndGoNext(BuildContext context) async {
    if (!isFormValid) return;

    try {
      // Create and save order draft
      final draft = OrderDraft.fromState(
        product: _product,
        state: _state,
      );

      await _orderDraftRepo.save(draft);

      // Navigate to Step 2 (Payment)
      if (context.mounted) {
        Navigator.of(context).pushNamed(
          '/product_schloss_neuschwanstein_order_step2',
          arguments: draft,
        );
      }
    } catch (e) {
      // Handle error - could show a snackbar or dialog
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving order: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}