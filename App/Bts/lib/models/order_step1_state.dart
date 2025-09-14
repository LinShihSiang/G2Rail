import 'package:flutter/material.dart';

class Companion {
  String fullNameEn;
  bool isChild;

  Companion({
    required this.fullNameEn,
    required this.isChild,
  });

  Companion copyWith({
    String? fullNameEn,
    bool? isChild,
  }) {
    return Companion(
      fullNameEn: fullNameEn ?? this.fullNameEn,
      isChild: isChild ?? this.isChild,
    );
  }
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

  OrderStep1State copyWith({
    String? fullNameEn,
    String? email,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    List<Companion>? companions,
  }) {
    return OrderStep1State(
      fullNameEn: fullNameEn ?? this.fullNameEn,
      email: email ?? this.email,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      companions: companions ?? this.companions,
    );
  }
}