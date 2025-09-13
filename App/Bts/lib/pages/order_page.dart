import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../view_models/order_step1_view_model.dart';
import '../repos/models/product.dart';
import '../repos/order_draft_repo.dart';
import '../models/order_step1_state.dart';
import '../services/payment_service.dart';
import '../services/email_service.dart';
import '../models/order_draft.dart';

class OrderPage extends StatelessWidget {
  final Product product;

  const OrderPage({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OrderStep1ViewModelImpl>(
      create: (_) => OrderStep1ViewModelImpl(
        product: product,
        orderDraftRepo: InMemoryOrderDraftRepo(),
      ),
      child: const _OrderPageContent(),
    );
  }
}

class _OrderPageContent extends StatefulWidget {
  const _OrderPageContent();

  @override
  State<_OrderPageContent> createState() => _OrderPageContentState();
}

class _OrderPageContentState extends State<_OrderPageContent> {
  final _scrollController = ScrollController();
  bool _isSubmitting = false;
  bool _isProcessingPayment = false;
  bool _isSendingEmail = false;
  String? _paymentError;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Your Trip - Step 1'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<OrderStep1ViewModelImpl>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMainBookerSection(viewModel),
                const SizedBox(height: 24),
                _buildCompanionsSection(viewModel),
                const SizedBox(height: 24),
                _buildSummarySection(viewModel),
                const SizedBox(height: 100), // Space for bottom button
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<OrderStep1ViewModelImpl>(
        builder: (context, viewModel, child) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: viewModel.isFormValid && !_isSubmitting
                    ? () => _submitForm(context, viewModel)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _getButtonText(viewModel),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainBookerSection(OrderStep1ViewModelImpl viewModel) {
    final errors = viewModel.errors;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Main Booker Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // English Name
            TextFormField(
              initialValue: viewModel.state.fullNameEn,
              decoration: InputDecoration(
                labelText: 'English Name *',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
                errorText: errors['fullNameEn'],
              ),
              onChanged: viewModel.setFullNameEn,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              initialValue: viewModel.state.email,
              decoration: InputDecoration(
                labelText: 'Email Address *',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email),
                errorText: errors['email'],
              ),
              onChanged: viewModel.setEmail,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Date Picker
            InkWell(
              onTap: () => _selectDate(context, viewModel),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                  errorText: errors['date'],
                ),
                child: Text(
                  viewModel.state.selectedDate != null
                      ? DateFormat('EEEE, MMMM d, y').format(viewModel.state.selectedDate!)
                      : 'Select date',
                  style: TextStyle(
                    color: viewModel.state.selectedDate != null
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : Theme.of(context).hintColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Time Picker
            InkWell(
              onTap: () => _selectTime(context, viewModel),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Time *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.access_time),
                  errorText: errors['time'],
                ),
                child: Text(
                  viewModel.state.selectedTime != null
                      ? viewModel.state.selectedTime!.format(context)
                      : 'Select time',
                  style: TextStyle(
                    color: viewModel.state.selectedTime != null
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : Theme.of(context).hintColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanionsSection(OrderStep1ViewModelImpl viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Companions (Optional)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${viewModel.state.companions.length}/10',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Companions List
            ...viewModel.state.companions.asMap().entries.map(
              (entry) => _buildCompanionCard(viewModel, entry.key, entry.value),
            ),

            // Add Companion Button
            if (viewModel.state.companions.length < 10)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _addCompanion(viewModel),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Companion'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanionCard(OrderStep1ViewModelImpl viewModel, int index, Companion companion) {
    final errors = viewModel.errors;
    final errorKey = 'companion_${index}_name';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: companion.fullNameEn,
                    decoration: InputDecoration(
                      labelText: 'English Name *',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      errorText: errors[errorKey],
                    ),
                    onChanged: (value) => viewModel.updateCompanionName(index, value),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => viewModel.removeCompanion(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Remove companion',
                ),
              ],
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('Child (under 18 years)'),
              value: companion.isChild,
              onChanged: (value) => viewModel.toggleCompanionIsChild(index, value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(OrderStep1ViewModelImpl viewModel) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Adults:', style: TextStyle(fontSize: 16)),
                Text('${viewModel.adultCount}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Children:', style: TextStyle(fontSize: 16)),
                Text('${viewModel.childCount}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total People:', style: TextStyle(fontSize: 16)),
                Text('${viewModel.totalPeople}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
            const Divider(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Unit Price (${viewModel.currency}/Adult):', style: const TextStyle(fontSize: 16)),
                Text('${viewModel.unitPrice}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${viewModel.totalAmount} ${viewModel.currency}',
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
    );
  }

  Future<void> _selectDate(BuildContext context, OrderStep1ViewModelImpl viewModel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.state.selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      viewModel.setDate(picked);
    }
  }

  Future<void> _selectTime(BuildContext context, OrderStep1ViewModelImpl viewModel) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: viewModel.state.selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      viewModel.setTime(picked);
    }
  }

  void _addCompanion(OrderStep1ViewModelImpl viewModel) {
    viewModel.addCompanion();
    // Auto-scroll to the new companion card
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String _getButtonText(OrderStep1ViewModelImpl viewModel) {
    if (_isProcessingPayment) {
      return 'Processing Payment...';
    } else if (_isSendingEmail) {
      return 'Sending Confirmation...';
    } else {
      return 'Proceed to Payment (${viewModel.totalAmount} ${viewModel.currency})';
    }
  }

  String _generateOrderId(String productId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'ORDER_${productId}_$timestamp';
  }

  Future<void> _submitForm(BuildContext context, OrderStep1ViewModelImpl viewModel) async {
    setState(() {
      _isSubmitting = true;
      _paymentError = null;
    });

    try {
      // Validate form first
      if (!viewModel.isFormValid) {
        return;
      }

      // Create OrderDraft
      final orderDraft = OrderDraft.fromState(
        product: viewModel.product,
        state: viewModel.state,
      );

      // Generate Order ID
      final orderId = _generateOrderId(viewModel.product.id);

      // Step 1: Process Payment
      setState(() {
        _isProcessingPayment = true;
      });

      bool paymentSuccess;
      try {
        paymentSuccess = await PaymentService.processTicketPayment(
          ticketPrice: viewModel.totalAmount.toDouble(),
          travelDescription: viewModel.product.name,
        );
      } catch (e) {
        setState(() {
          _paymentError = 'Payment failed: ${e.toString()}';
          _isProcessingPayment = false;
        });
        if (mounted) {
          _showErrorDialog(context, 'Payment Error', _paymentError!);
        }
        return;
      }

      setState(() {
        _isProcessingPayment = false;
      });

      if (!paymentSuccess) {
        setState(() {
          _paymentError = 'Payment was not completed successfully';
        });
        if (mounted) {
          _showErrorDialog(context, 'Payment Failed', _paymentError!);
        }
        return;
      }

      // Step 2: Send Email Confirmation
      setState(() {
        _isSendingEmail = true;
      });

      try {
        final emailService = EmailService(
          apiUrl: 'https://api.emailservice.com', // Replace with actual API URL
          apiKey: 'your-api-key', // Replace with actual API key
        );

        final bookingDetails = _createBookingDetails(orderDraft, orderId);
        final paymentInfo = _createPaymentInfo(orderDraft);

        final emailSuccess = await emailService.sendBookingConfirmation(
          customerEmail: orderDraft.email,
          customerName: orderDraft.mainFullNameEn,
          bookingDetails: bookingDetails,
          paymentInfo: paymentInfo,
        );

        setState(() {
          _isSendingEmail = false;
        });

        if (!emailSuccess) {
          // Continue to confirmation page but show warning
          if (mounted) {
            _showEmailWarning(context);
          }
        }
      } catch (e) {
        setState(() {
          _isSendingEmail = false;
        });
        // Continue to confirmation page but show warning
        if (mounted) {
          _showEmailWarning(context);
        }
      }

      // Save order draft with order ID
      final orderDraftRepo = InMemoryOrderDraftRepo();
      await orderDraftRepo.save(orderDraft);

      // Navigate to confirmation page
      if (context.mounted) {
        _showSuccessAndNavigate(context, orderId);
      }

    } catch (e) {
      setState(() {
        _paymentError = 'An unexpected error occurred: ${e.toString()}';
      });
      if (mounted) {
        _showErrorDialog(context, 'Error', _paymentError!);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isProcessingPayment = false;
          _isSendingEmail = false;
        });
      }
    }
  }

  Map<String, dynamic> _createBookingDetails(OrderDraft orderDraft, String orderId) {
    return {
      'orderId': orderId,
      'productName': orderDraft.productName,
      'mainBookerName': orderDraft.mainFullNameEn,
      'email': orderDraft.email,
      'dateTime': DateFormat('EEEE, MMMM d, y \'at\' HH:mm').format(orderDraft.dateTime),
      'companions': orderDraft.companions.map((companion) => {
        'name': companion.fullNameEn,
        'isChild': companion.isChild,
        'ageIndicator': companion.isChild ? ' (Under 18)' : '',
      }).toList(),
      'adultCount': orderDraft.adultCount,
      'childCount': orderDraft.childCount,
      'unitPrice': orderDraft.unitPrice,
      'currency': orderDraft.currency,
      'totalAmount': orderDraft.totalAmount,
    };
  }

  Map<String, dynamic> _createPaymentInfo(OrderDraft orderDraft) {
    return {
      'amount': orderDraft.totalAmount,
      'currency': orderDraft.currency,
      'method': 'Credit Card',
      'transactionId': 'TXN_${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showEmailWarning(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Payment successful! However, confirmation email could not be sent.'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessAndNavigate(BuildContext context, String orderId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment successful! Confirmation email sent.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate to confirmation page after a brief delay
    Future.delayed(const Duration(seconds: 1), () {
      if (context.mounted) {
        Navigator.of(context).pushNamed(
          '/confirmation',
          arguments: {'orderId': orderId},
        );
      }
    });
  }
}