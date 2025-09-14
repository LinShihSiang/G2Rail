import 'package:flutter/material.dart';
import 'package:g2railsample/services/payment_service.dart';
import 'package:g2railsample/services/email_service.dart';
import 'package:g2railsample/pages/confirmation_page.dart';
import 'package:intl/intl.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> orderDetails;

  const PaymentPage({
    super.key,
    required this.orderDetails,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isProcessingPayment = false;
  late final EmailService _emailService;

  @override
  void initState() {
    super.initState();
    _emailService = EmailService();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.orderDetails['product'] as Map<String, dynamic>;
    final quantity = widget.orderDetails['quantity'] as int;
    final totalPrice = widget.orderDetails['totalPrice'] as double;
    final travelDate = widget.orderDetails['travelDate'] as DateTime;
    final passengerInfo = widget.orderDetails['passengerInfo'] as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

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
                    const SizedBox(height: 8),
                    Text(
                      'Travel Date: ${DateFormat('EEEE, MMMM d, y').format(travelDate)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Travelers: $quantity',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Price per person: \$${product['price'].toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text('x $quantity'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Passenger Information
            const Text(
              'Passenger Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Name', passengerInfo['name']),
                    _buildInfoRow('Email', passengerInfo['email']),
                    _buildInfoRow('Phone', passengerInfo['phone']),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Payment Method
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.credit_card, color: Colors.blue),
                      title: const Text('Credit Card'),
                      subtitle: const Text('Pay securely with Stripe'),
                      trailing: const Icon(Icons.security),
                      onTap: () {}, // Payment method is already selected
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Payment Terms
            Card(
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Payment Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Secure payment processing with Stripe\n'
                      '• Full refund available up to 48 hours before travel date\n'
                      '• Confirmation email will be sent after successful payment\n'
                      '• Your booking is protected by our travel guarantee',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isProcessingPayment ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isProcessingPayment ? Colors.grey : Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isProcessingPayment
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Processing Payment...',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  )
                : Text(
                    'Pay \$${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final product = widget.orderDetails['product'] as Map<String, dynamic>;
      final totalPrice = widget.orderDetails['totalPrice'] as double;
      final passengerInfo = widget.orderDetails['passengerInfo'] as Map<String, dynamic>;

      final success = await PaymentService.processTicketPayment(
        ticketPrice: totalPrice,
        travelDescription: 'G2Rail Travel: ${product['title']}',
      );

      if (success) {
        // Send confirmation email
        await _sendConfirmationEmail();

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ConfirmationPage(
                orderDetails: widget.orderDetails,
                paymentSuccess: true,
              ),
            ),
          );
        }
      } else {
        _showErrorMessage('Payment failed. Please try again.');
      }
    } catch (e) {
      _showErrorMessage('Payment error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  Future<void> _sendConfirmationEmail() async {
    try {
      final product = widget.orderDetails['product'] as Map<String, dynamic>;
      final quantity = widget.orderDetails['quantity'] as int;
      final totalPrice = widget.orderDetails['totalPrice'] as double;
      final travelDate = widget.orderDetails['travelDate'] as DateTime;
      final passengerInfo = widget.orderDetails['passengerInfo'] as Map<String, dynamic>;

      await _emailService.sendBookingConfirmation(
        customerEmail: passengerInfo['email'],
        customerName: passengerInfo['name'],
        bookingDetails: {
          'from': 'Frankfurt',
          'to': product['title'],
          'date': DateFormat('EEEE, MMMM d, y').format(travelDate),
          'time': '08:00',
          'passengers': '$quantity',
          'ticketType': product['duration'],
        },
        paymentInfo: {
          'amount': totalPrice,
          'currency': 'USD',
          'method': 'Credit Card',
          'transactionId': 'TXN_${DateTime.now().millisecondsSinceEpoch}',
        },
      );
    } catch (e) {
      debugPrint('Failed to send confirmation email: $e');
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}