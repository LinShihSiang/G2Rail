import 'order_step1_state.dart';
import '../repos/models/product.dart';

class CompanionDraft {
  final String fullNameEn;
  final bool isChild;

  const CompanionDraft({
    required this.fullNameEn,
    required this.isChild,
  });

  factory CompanionDraft.fromCompanion(Companion companion) {
    return CompanionDraft(
      fullNameEn: companion.fullNameEn,
      isChild: companion.isChild,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullNameEn': fullNameEn,
      'isChild': isChild,
    };
  }

  factory CompanionDraft.fromJson(Map<String, dynamic> json) {
    return CompanionDraft(
      fullNameEn: json['fullNameEn'],
      isChild: json['isChild'],
    );
  }
}

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

  const OrderDraft({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.currency,
    required this.mainFullNameEn,
    required this.email,
    required this.dateTime,
    required this.companions,
    required this.adultCount,
    required this.childCount,
    required this.totalAmount,
  });

  factory OrderDraft.fromState({
    required Product product,
    required OrderStep1State state,
  }) {
    final companions = state.companions
        .map((c) => CompanionDraft.fromCompanion(c))
        .toList();

    final adultCount = 1 + companions.where((c) => !c.isChild).length;
    final childCount = companions.where((c) => c.isChild).length;
    final totalAmount = product.price * adultCount;

    final dateTime = DateTime(
      state.selectedDate!.year,
      state.selectedDate!.month,
      state.selectedDate!.day,
      state.selectedTime!.hour,
      state.selectedTime!.minute,
    );

    return OrderDraft(
      productId: product.id,
      productName: product.name,
      unitPrice: product.price,
      currency: product.currency,
      mainFullNameEn: state.fullNameEn,
      email: state.email,
      dateTime: dateTime,
      companions: companions,
      adultCount: adultCount,
      childCount: childCount,
      totalAmount: totalAmount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'unitPrice': unitPrice,
      'currency': currency,
      'mainFullNameEn': mainFullNameEn,
      'email': email,
      'dateTime': dateTime.toIso8601String(),
      'companions': companions.map((c) => c.toJson()).toList(),
      'adultCount': adultCount,
      'childCount': childCount,
      'totalAmount': totalAmount,
    };
  }

  factory OrderDraft.fromJson(Map<String, dynamic> json) {
    return OrderDraft(
      productId: json['productId'],
      productName: json['productName'],
      unitPrice: json['unitPrice'],
      currency: json['currency'],
      mainFullNameEn: json['mainFullNameEn'],
      email: json['email'],
      dateTime: DateTime.parse(json['dateTime']),
      companions: (json['companions'] as List)
          .map((c) => CompanionDraft.fromJson(c))
          .toList(),
      adultCount: json['adultCount'],
      childCount: json['childCount'],
      totalAmount: json['totalAmount'],
    );
  }
}