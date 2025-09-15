class SubscriptionRequest {
  final String email;
  final String name;

  const SubscriptionRequest({
    required this.email,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
    };
  }
}