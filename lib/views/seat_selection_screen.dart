import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';
import '../models/core_models.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Showtime? showtime; // Getting showtime passed via route state
  const SeatSelectionScreen({Key? key, this.showtime}) : super(key: key);

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final Set<String> _selectedSeats = {};
  
  // Mock seat generation
  final int rows = 8;
  final int cols = 8;
  final Set<String> _bookedSeats = {'C4', 'C5', 'D4', 'E2'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Seats'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          // Screen Curve Marker
          CustomPaint(
            size: const Size(300, 30),
            painter: ScreenPainter(),
          ),
          const SizedBox(height: 16),
          const Text('SCREEN', style: TextStyle(color: AppColors.textSecondary, letterSpacing: 4)),
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

                      // Create a gap in the middle
                      if (col == 4 || col == 5) {
                        return const SizedBox.shrink(); // Aisle
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
                        child: Container(
                          decoration: BoxDecoration(
                            color: isBooked
                                ? Colors.grey.shade400
                                : isSelected
                                    ? AppColors.primary
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isBooked ? Colors.transparent : AppColors.primary,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              seatId,
                              style: TextStyle(
                                fontSize: 10,
                                color: isBooked
                                    ? Colors.white
                                    : isSelected
                                        ? Colors.white
                                        : AppColors.primary,
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
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.white, 'Available', border: true),
              const SizedBox(width: 16),
              _buildLegendItem(AppColors.primary, 'Selected'),
              const SizedBox(width: 16),
              _buildLegendItem(Colors.grey.shade400, 'Booked'),
            ],
          ),
          const SizedBox(height: 16),
          
          // AR Entry Point
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: InkWell(
              onTap: () {
                // Show AR preview
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening AR View... (Mock)')),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.view_in_ar, color: Colors.white),
                    SizedBox(width: 8),
                    Text('AR View from My Seat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Price', style: TextStyle(color: AppColors.textSecondary)),
                          Text(
                            'LKR ${(_selectedSeats.length * (widget.showtime?.price ?? 1000)).toInt()}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _selectedSeats.isEmpty
                            ? null
                            : () => _showPaymentOptions(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Proceed', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool border = false}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: border ? Border.all(color: AppColors.primary) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  void _showPaymentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Payment Mode', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Choose how you want to pay for this booking.', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              
              // Group Split-Payment Option
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/tickets'); // Navigate to tickets to complete flow
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invites sent for Group Split-Payment!')));
                },
                icon: const Icon(Icons.group, color: AppColors.primary),
                label: const Text('Group Split-Payment', style: TextStyle(color: AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              
              // Pay Now
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/tickets');
                },
                icon: const Icon(Icons.payment, color: Colors.white),
                label: const Text('Pay Full Amount', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ScreenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.3)
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
