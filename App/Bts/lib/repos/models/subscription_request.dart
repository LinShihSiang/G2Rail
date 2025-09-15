import 'dart:math';

class SubscriptionRequest {
  final String email;
  final String name;

  const SubscriptionRequest({
    required this.email,
    required this.name,
  });

  String _generateGuid() {
    const chars = 'abcdef0123456789';
    final random = Random();

    String randomString(int length) {
      return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
    }

    return '${randomString(8)}-${randomString(4)}-${randomString(4)}-${randomString(4)}-${randomString(12)}';
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'id': _generateGuid(),
      'date': DateTime.now().toIso8601String(),
    };
  }
}