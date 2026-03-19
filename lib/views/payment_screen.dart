import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_colors.dart';
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
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  Future<void> _processFinalPayment() async {
    // Show loading boundary while checking out
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

      // Fetch movie from database to complete Ticket model payload
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

      // 1. Process secure transaction through Mock Payment Gateway
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

      // 2. Insert ticket into Firebase database only on success!
      await DatabaseService().bookTicket(ticket);

      if (mounted) {
        Navigator.pop(context); // remove loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSplitPayment
                ? 'Invites sent! Ticket marked as pending payment.'
                : 'Payment Successful! Ticket generated.'),
            backgroundColor: Colors.green,
          ),
        );
        // Instantly transition to specific ticket detail view to show QR Code!
        context.pushReplacement('/ticket-details', extra: ticket);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // remove loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment transaction failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final showtime = widget.checkoutData['showtime'] as Showtime;
    final selectedSeats = widget.checkoutData['selectedSeats'] as List<String>;
    final totalAmount = selectedSeats.length * showtime.price;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Complete Payment', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
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
                      Expanded(flex: 3, child: _buildPaymentForm()),
                      const SizedBox(width: 48),
                      Expanded(flex: 2, child: _buildOrderSummary(totalAmount)),
                    ],
                  );
                }
                return Column(
                  children: [
                    _buildOrderSummary(totalAmount),
                    const SizedBox(height: 32),
                    _buildPaymentForm(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.fast_forward, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('CinePay Gateway', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 32),
        _buildTextField('Cardholder Name', 'Aduke Morewa', _nameController, icon: Icons.person_outline),
        const SizedBox(height: 20),
        _buildTextField('Card Number', '0000 0000 0000 0000', _cardNumberController, icon: Icons.credit_card),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildTextField('Expiry Date', 'MM/YY', _expiryController, icon: Icons.date_range)),
            const SizedBox(width: 20),
            Expanded(child: _buildTextField('CVV', '123', _cvvController, icon: Icons.security, obscureText: true)),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
            onPressed: _processFinalPayment,
            child: const Text('Pay Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {IconData? icon, bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,
            filled: true,
            fillColor: AppColors.cardColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(double totalAmount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVirtualCard(),
          const SizedBox(height: 32),
          const Divider(color: Colors.black12),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Company', style: TextStyle(color: AppColors.textSecondary)),
              Text('CineBook Cinemas', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Service Fee', style: TextStyle(color: AppColors.textSecondary)),
              Text('LKR 0.00', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('You have to Pay', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                Text(
                  'LKR ${totalAmount.toInt()}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVirtualCard() {
    return Container(
      width: double.infinity,
      height: 190,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // Purple sleek gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
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
              Icon(Icons.memory, color: Colors.yellow.shade600, size: 32),
              const Icon(Icons.wifi, color: Colors.white70),
            ],
          ),
          const Text(
            '****  ****  ****  3456',
            style: TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2, fontFamily: 'Courier'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Card Holder', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  Text('ADUKE MOREWA', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Expires', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  Text('09/24', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
