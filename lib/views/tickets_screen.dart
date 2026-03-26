import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/core_models.dart';
import '../services/database_service.dart';
import 'custom_navigation_bar.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({Key? key}) : super(key: key);

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  bool _showActive = true;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: const Text('My Tickets'),
        ),
        bottomNavigationBar: const CustomNavigationBar(selectedIndex: 1),
        body: Center(
          child: Text('Please log in to view your tickets.', style: Theme.of(context).textTheme.bodyLarge),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      bottomNavigationBar: const CustomNavigationBar(selectedIndex: 1),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Tickets'),
            Text('Your booking history', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
      body: StreamBuilder<List<Ticket>>(
        stream: DatabaseService().getUserTicketsStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading tickets: ${snapshot.error}', style: TextStyle(color: Theme.of(context).colorScheme.error)));
          }

          final tickets = snapshot.data ?? [];
          final now = DateTime.now().subtract(const Duration(hours: 3));
          final activeTickets = tickets.where((t) => t.date.isAfter(now)).toList();
          final pastTickets = tickets.where((t) => t.date.isBefore(now)).toList();

          final displayTickets = _showActive ? activeTickets : pastTickets;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
                    segments: [
                      ButtonSegment<bool>(value: true, label: Text('Active (${activeTickets.length})')),
                      ButtonSegment<bool>(value: false, label: Text('Past (${pastTickets.length})')),
                    ],
                    selected: {_showActive},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setState(() => _showActive = newSelection.first);
                    },
                  ),
                ),
              ),
              Expanded(
                child: displayTickets.isEmpty
                  ? Center(
                      child: Text(
                        _showActive ? 'No active tickets found. Book a movie now!' : 'No past booking history found.',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: displayTickets.length,
                      itemBuilder: (context, index) {
                        return _buildTicketCard(context, displayTickets[index]);
                      },
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, Ticket ticket) {
    final isPending = ticket.status == 'Pending Split Payment';
    final statusColor = isPending ? Colors.orange : Theme.of(context).colorScheme.secondary;
    final statusOnColor = isPending ? Colors.black : Theme.of(context).colorScheme.onSecondary;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          context.push('/ticket-details', extra: ticket);
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ticket.movie.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimaryContainer)),
                        const SizedBox(height: 4),
                        Text('${ticket.cinema.name} - Hall 1', style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8), fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Icon(isPending ? Icons.hourglass_top : Icons.qr_code, size: 16, color: statusOnColor),
                        const SizedBox(width: 6),
                        Text(isPending ? 'Pending' : 'Ready', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusOnColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text(
                            '${ticket.date.year}-${ticket.date.month.toString().padLeft(2, '0')}-${ticket.date.day.toString().padLeft(2, '0')}', 
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text(ticket.showtime.time, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Seats', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: ticket.seatNumbers.map((seat) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(6)
                              ),
                              child: Text(seat, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            )).toList(),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Total', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 8),
                          Text('LKR ${ticket.totalAmount.toInt()}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
