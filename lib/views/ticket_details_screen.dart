import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/core_models.dart';

class TicketDetailsScreen extends StatelessWidget {
  final Ticket ticket;
  const TicketDetailsScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Ticket Details', style: TextStyle(fontSize: 18)),
            Text(ticket.id, style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (ticket.isSplitPayment)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Split Payment Pending', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(
                            'Waiting for ${ticket.splitWithEmails.join(', ')} to pay their share of LKR ${(ticket.totalAmount / (ticket.splitWithEmails.length + 1)).toInt()}',
                            style: const TextStyle(color: Colors.orange, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            // QR Code Card
            Card(
              elevation: 0,
              color: colorScheme.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: colorScheme.primaryContainer, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ticket.isSplitPayment 
                        ? Padding(
                            padding: const EdgeInsets.all(60.0),
                            child: Icon(Icons.lock_outline, size: 80, color: colorScheme.primary),
                          )
                        : QrImageView(
                            data: ticket.id,
                            version: QrVersions.auto,
                            size: 200.0,
                          )
                    ),
                    const SizedBox(height: 16),
                    Text(ticket.isSplitPayment ? 'Ticket Locked' : 'Scan at entrance', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('Booking Ref: ${ticket.id}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colorScheme.onSurface)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Movie Details Card
            Card(
              elevation: 0,
              color: colorScheme.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ticket.movie.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildDetailRow(Icons.location_on_outlined, 'Cinema', '${ticket.cinema.name} - Hall 1', colorScheme),
                    const SizedBox(height: 16),
                    _buildDetailRow(Icons.calendar_today_outlined, 'Date & Time', 'Today, ${ticket.showtime.time}', colorScheme),
                    const SizedBox(height: 16),
                    _buildDetailRow(Icons.event_seat_outlined, 'Format & Seats',
                        '${ticket.showtime.format} | ${ticket.seatNumbers.join(", ")}', colorScheme),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: colorScheme.onSurface)),
                        Text('LKR ${ticket.totalAmount.toInt()}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            // Additional Information
            Card(
              elevation: 0,
              color: colorScheme.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Additional Information', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildInfoRow('Language', 'English', colorScheme),
                    const SizedBox(height: 12),
                    _buildInfoRow('Format', '2D, 3D, IMAX', colorScheme),
                    const SizedBox(height: 12),
                    _buildInfoRow('Rating', 'PG-13', colorScheme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: colorScheme.onSurface)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: colorScheme.onSurface)),
      ],
    );
  }
}
