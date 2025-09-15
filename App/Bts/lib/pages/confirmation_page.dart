import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:g2railsample/pages/home_page.dart';
import '../repos/product_repo.dart';
import '../services/subscription_service.dart';

class ConfirmationPage extends StatelessWidget {
  final Map<String, dynamic> orderDetails;
  final bool paymentSuccess;

  const ConfirmationPage({
    super.key,
    required this.orderDetails,
    required this.paymentSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final product = orderDetails['product'] as Map<String, dynamic>;
    final quantity = orderDetails['quantity'] as int;
    final totalPrice = orderDetails['totalPrice'] as double;
    final travelDate = orderDetails['travelDate'] as DateTime;
    final passengerInfo = orderDetails['passengerInfo'] as Map<String, dynamic>;
    final bookingReference = 'G2R-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
        backgroundColor: paymentSuccess ? Colors.green : Colors.red,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Success/Failure Icon and Message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: paymentSuccess ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: paymentSuccess ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    paymentSuccess ? Icons.check_circle : Icons.error,
                    size: 80,
                    color: paymentSuccess ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    paymentSuccess ? 'Booking Confirmed!' : 'Booking Failed',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: paymentSuccess ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    paymentSuccess
                        ? 'Your travel booking has been successfully confirmed. A confirmation email has been sent to ${passengerInfo['email']}.'
                        : 'We were unable to process your booking. Please try again or contact customer support.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            if (paymentSuccess) ...[
              const SizedBox(height: 24),

              // Booking Reference
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.confirmation_number, color: Colors.blue),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Booking Reference',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            bookingReference,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Trip Details
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Trip Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow('Travel Date', DateFormat('EEEE, MMMM d, y').format(travelDate)),
                      _buildDetailRow('Duration', product['duration']),
                      _buildDetailRow('Travelers', '$quantity person${quantity > 1 ? 's' : ''}'),
                      _buildDetailRow('Departure', 'Frankfurt Central Station - 08:00'),
                      const SizedBox(height: 12),
                      const Divider(),
                      _buildDetailRow('Total Paid', '\$${totalPrice.toStringAsFixed(2)}', isHighlight: true),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Passenger Information
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Lead Passenger',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Name', passengerInfo['name']),
                      _buildDetailRow('Email', passengerInfo['email']),
                      _buildDetailRow('Phone', passengerInfo['phone']),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Important Information
              Card(
                color: Colors.amber[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info, color: Colors.amber),
                          const SizedBox(width: 8),
                          const Text(
                            'Important Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '• Please arrive at Frankfurt Central Station 30 minutes before departure\n'
                        '• Bring a valid ID/passport for identification\n'
                        '• Check your email for detailed itinerary and meeting instructions\n'
                        '• Free cancellation up to 48 hours before travel date\n'
                        '• For any changes, contact us with your booking reference',
                        style: TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 30),

            // Action Buttons
            Column(
              children: [
                if (paymentSuccess) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _goHome(context),
                      icon: const Icon(Icons.home),
                      label: const Text('Return to Home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement view ticket functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ticket details sent to your email')),
                        );
                      },
                      icon: const Icon(Icons.receipt),
                      label: const Text('View Ticket Details'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _goHome(context),
                      icon: const Icon(Icons.home),
                      label: const Text('Return to Home'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                color: isHighlight ? Colors.green : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goHome(BuildContext context) {
    final repo = InMemoryProductRepo();
    final subscriptionService = SubscriptionService(
      baseUrl: 'https://api.dodoman-travel.com',
      httpClient: http.Client(),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomePage(
        repo: repo,
        subscriptionService: subscriptionService,
      )),
      (route) => false,
    );
  }
}