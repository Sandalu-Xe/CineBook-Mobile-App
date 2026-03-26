import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/core_models.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Map<String, dynamic>? bookingData;
  const SeatSelectionScreen({Key? key, this.bookingData}) : super(key: key);

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final Set<String> _selectedSeats = {};
  
  final int rows = 8;
  final int cols = 8;
  final Set<String> _bookedSeats = {'C4', 'C5', 'D4', 'E2'};

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Select Seats'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          CustomPaint(
            size: const Size(300, 30),
            painter: ScreenPainter(colorScheme.primary.withOpacity(0.3)),
          ),
          const SizedBox(height: 16),
          Text('SCREEN', style: TextStyle(color: colorScheme.onSurfaceVariant, letterSpacing: 4, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 2.5,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      childAspectRatio: 1,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: rows * cols,
                    itemBuilder: (context, index) {
                      final row = String.fromCharCode(65 + (index ~/ cols));
                      final col = (index % cols) + 1;
                      final seatId = '$row$col';

                      if (col == 4 || col == 5) {
                        return const SizedBox.shrink(); 
                      }

                      final isBooked = _bookedSeats.contains(seatId);
                      final isSelected = _selectedSeats.contains(seatId);

                      return GestureDetector(
                        onTap: () {
                          if (isBooked) return;
                          setState(() {
                            if (isSelected) {
                              _selectedSeats.remove(seatId);
                            } else {
                              _selectedSeats.add(seatId);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isBooked
                                ? colorScheme.surfaceVariant
                                : isSelected
                                    ? colorScheme.primary
                                    : colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isBooked ? Colors.transparent : colorScheme.primaryContainer,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              seatId,
                              style: TextStyle(
                                fontSize: 10,
                                color: isBooked
                                    ? colorScheme.onSurfaceVariant
                                    : isSelected
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(colorScheme.surface, 'Available', colorScheme, border: true),
                const SizedBox(width: 16),
                _buildLegendItem(colorScheme.primary, 'Selected', colorScheme),
                const SizedBox(width: 16),
                _buildLegendItem(colorScheme.surfaceVariant, 'Booked', colorScheme),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: FilledButton.tonalIcon(
              onPressed: () {
                context.push('/ar-view', extra: {
                  'selectedSeat': _selectedSeats.isNotEmpty
                      ? _selectedSeats.first
                      : 'D3',
                });
              },
              icon: const Icon(Icons.view_in_ar),
              label: const Text('AR View from My Seat'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total Price', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                  Text(
                    'LKR ${(_selectedSeats.length * (widget.bookingData?['showtime']?.price ?? 1000)).toInt()}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                ],
              ),
              FilledButton(
                onPressed: _selectedSeats.isEmpty
                    ? null
                    : () => _showPaymentOptions(context),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Proceed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, ColorScheme colorScheme, {bool border = false}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: border ? Border.all(color: colorScheme.primaryContainer, width: 2) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
      ],
    );
  }

  void _showPaymentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Payment Mode', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Choose how you want to pay for this booking.', style: TextStyle(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 32),
              
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showSplitPaymentDialog(context);
                },
                icon: const Icon(Icons.group),
                label: const Text('Group Split-Payment'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _processBooking(isSplitPayment: false);
                },
                icon: const Icon(Icons.payment),
                label: const Text('Pay Full Amount'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showSplitPaymentDialog(BuildContext context) {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Split Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the email of the friend you want to split this booking with.', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Friend's Email",
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final email = emailController.text.trim();
                if (email.isEmpty || !email.contains('@')) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid email')));
                  return;
                }
                Navigator.pop(context);
                _processBooking(isSplitPayment: true, splitEmail: email);
              },
              child: const Text('Send Invite'),
            ),
          ],
        );
      }
    );
  }

  void _processBooking({required bool isSplitPayment, String splitEmail = ''}) {
    if (widget.bookingData == null) return;
    if (_selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one seat!')));
      return;
    }

    final checkoutData = {
      ...widget.bookingData!,
      'selectedSeats': _selectedSeats.toList(),
      'isSplitPayment': isSplitPayment,
      'splitEmail': splitEmail,
    };

    context.push('/payment', extra: checkoutData);
  }
}

class ScreenPainter extends CustomPainter {
  final Color curveColor;
  ScreenPainter(this.curveColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = curveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
