import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/core_models.dart';
import '../services/database_service.dart';
import '../services/payment_gateway_service.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> checkoutData;
  const PaymentScreen({Key? key, required this.checkoutData}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  String _displayCardNumber = '****  ****  ****  3456';
  String _displayName = 'ADUKE MOREWA';
  String _displayExpiry = '09/24';

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(() {
      setState(() {
        _displayCardNumber = _cardNumberController.text.isNotEmpty 
            ? _cardNumberController.text 
            : '****  ****  ****  3456';
      });
    });
    
    _nameController.addListener(() {
      setState(() {
        _displayName = _nameController.text.isNotEmpty 
            ? _nameController.text.toUpperCase() 
            : 'ADUKE MOREWA';
      });
    });
    
    _expiryController.addListener(() {
      setState(() {
        _displayExpiry = _expiryController.text.isNotEmpty 
            ? _expiryController.text 
            : '09/24';
      });
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _processFinalPayment() async {
    if (!_formKey.currentState!.validate()) {
      return; 
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()));

    try {
      final showtime = widget.checkoutData['showtime'] as Showtime;
      final cinema = widget.checkoutData['cinema'] as Cinema;
      final movieId = widget.checkoutData['movieId'] as String;
      final selectedSeats = widget.checkoutData['selectedSeats'] as List<String>;
      final isSplitPayment = widget.checkoutData['isSplitPayment'] as bool;
      final splitEmail = widget.checkoutData['splitEmail'] as String;

      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

      final movieDoc = await FirebaseFirestore.instance.collection('movies').doc(movieId).get();
      if (!movieDoc.exists) throw Exception('Movie not found');
      final movie = Movie.fromFirestore(movieDoc);

      final totalPrice = selectedSeats.length * showtime.price;

      final ticketRef = FirebaseFirestore.instance.collection('tickets').doc();
      final ticket = Ticket(
        id: ticketRef.id,
        userId: userId,
        movie: movie,
        cinema: cinema,
        showtime: showtime,
        date: DateTime.now(),
        seatNumbers: selectedSeats,
        totalAmount: totalPrice.toDouble(),
        isActive: true,
        status: isSplitPayment ? 'Pending Split Payment' : 'Valid',
        isSplitPayment: isSplitPayment,
        splitWithEmails: isSplitPayment ? [splitEmail] : [],
      );

      final paymentService = PaymentGatewayService();
      await paymentService.processPayment(
        ticketId: ticketRef.id,
        userId: userId,
        cardNumber: _cardNumberController.text,
        expiry: _expiryController.text,
        cvv: _cvvController.text,
        name: _nameController.text,
        amount: totalPrice.toDouble(),
      );

      await DatabaseService().bookTicket(ticket);

      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSplitPayment
                ? 'Invites sent! Ticket marked as pending payment.'
                : 'Payment Successful! Ticket generated.'),
            backgroundColor: Colors.green,
          ),
        );
        context.pushReplacement('/ticket-details', extra: ticket);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bank Declined: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final showtime = widget.checkoutData['showtime'] as Showtime;
    final selectedSeats = widget.checkoutData['selectedSeats'] as List<String>;
    final totalAmount = selectedSeats.length * showtime.price;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Complete Payment'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildPaymentForm(colorScheme)),
                      const SizedBox(width: 48),
                      Expanded(flex: 2, child: _buildOrderSummary(totalAmount, colorScheme)),
                    ],
                  );
                }
                return Column(
                  children: [
                    _buildOrderSummary(totalAmount, colorScheme),
                    const SizedBox(height: 32),
                    _buildPaymentForm(colorScheme),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentForm(ColorScheme colorScheme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: colorScheme.primaryContainer, shape: BoxShape.circle),
                child: Icon(Icons.fast_forward, color: colorScheme.onPrimaryContainer, size: 20),
              ),
              const SizedBox(width: 12),
              Text('CinePay Gateway', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 32),
          _buildTextField(
            'Cardholder Name', 
            'Aduke Morewa', 
            _nameController, 
            icon: Icons.person_outline,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter the exact name on card';
              return null;
            }
          ),
          const SizedBox(height: 20),
          _buildTextField(
            'Card Number', 
            '0000 0000 0000 0000', 
            _cardNumberController, 
            icon: Icons.credit_card,
            keyboardType: TextInputType.number,
            validator: (val) {
              if (val == null || val.replaceAll(' ', '').length < 15) return 'Please enter a valid 16-digit card number';
              return null;
            }
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  'Expiry Date', 
                  'MM/YY', 
                  _expiryController, 
                  icon: Icons.date_range,
                  keyboardType: TextInputType.datetime,
                  validator: (val) {
                    if (val == null || !RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$').hasMatch(val)) return 'Invalid Expiry';
                    return null;
                  }
                )
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildTextField(
                  'CVV', 
                  '123', 
                  _cvvController, 
                  icon: Icons.security, 
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.length < 3) return 'Invalid CVV';
                    return null;
                  }
                )
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: _processFinalPayment,
              child: const Text('Pay Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    String hint, 
    TextEditingController controller, 
    {
      IconData? icon, 
      bool obscureText = false,
      String? Function(String?)? validator,
      TextInputType? keyboardType,
    }
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(double totalAmount, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVirtualCard(colorScheme),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Company', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                const Text('CineBook Cinemas', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Service Fee', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                const Text('LKR 0.00', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('You have to Pay', style: TextStyle(fontSize: 16, color: colorScheme.onSurface)),
                  Text(
                    'LKR ${totalAmount.toInt()}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVirtualCard(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      height: 190,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.tertiary], 
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.memory, color: Colors.yellow.shade300, size: 32),
              const Icon(Icons.wifi, color: Colors.white70),
            ],
          ),
          Text(
            _displayCardNumber,
            style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2, fontFamily: 'monospace'),
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Card Holder', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  Text(_displayName, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Expires', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  Text(_displayExpiry, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
