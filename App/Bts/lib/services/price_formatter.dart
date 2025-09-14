import 'package:intl/intl.dart';

String formatPrice(num? amount, String currency) {
  if (amount == null) return '';
  final f = NumberFormat.simpleCurrency(name: currency);
  return f.format(amount);
}