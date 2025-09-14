import 'package:intl/intl.dart';

String formatPrice(num amount, String currency) {
  final f = NumberFormat.simpleCurrency(name: currency);
  return f.format(amount);
}