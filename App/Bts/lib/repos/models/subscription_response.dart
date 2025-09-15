class SubscriptionResponse {
  final bool success;
  final String message;

  const SubscriptionResponse({
    required this.success,
    required this.message,
  });

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}