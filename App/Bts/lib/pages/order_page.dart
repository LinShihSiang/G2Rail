import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:g2railsample/pages/payment_page.dart';

class OrderPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const OrderPage({
    super.key,
    required this.product,
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  int _quantity = 1;
  double get _totalPrice => widget.product['price'] * _quantity;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Your Trip'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected Product Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Trip',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.product['title'],
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        widget.product['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Price per person: \$${widget.product['price'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Travel Date Selection
              const Text(
                'Travel Date',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(DateFormat('EEEE, MMMM d, y').format(_selectedDate)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _selectDate,
                ),
              ),

              const SizedBox(height: 20),

              // Quantity Selection
              const Text(
                'Number of Travelers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text('Quantity:', style: TextStyle(fontSize: 16)),
                      const Spacer(),
                      IconButton(
                        onPressed: _quantity > 1 ? _decrementQuantity : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        '$_quantity',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: _incrementQuantity,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Passenger Information
              const Text(
                'Lead Passenger Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // Total Price Summary
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Price per person: \$${widget.product['price'].toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text('x $_quantity'),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${_totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
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

              const SizedBox(height: 30),
            ],
          ),
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
            onPressed: _proceedToPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Proceed to Payment (\$${_totalPrice.toStringAsFixed(2)})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _proceedToPayment() {
    if (_formKey.currentState!.validate()) {
      final orderDetails = {
        'product': widget.product,
        'quantity': _quantity,
        'totalPrice': _totalPrice,
        'travelDate': _selectedDate,
        'passengerInfo': {
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
        },
      };

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaymentPage(orderDetails: orderDetails),
        ),
      );
    }
  }
}