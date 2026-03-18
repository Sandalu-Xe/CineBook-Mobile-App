import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';
import '../models/core_models.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock tickets
    final List<Ticket> tickets = [
      Ticket(
        id: 'CB2026031701',
        movie: Movie(id: '1', title: 'Velocity Strike', genre: '', duration: '', rating: 0, posterUrl: '', synopsis: '', isNowShowing: true),
        cinema: Cinema(id: 'c1', name: 'Liberty Cinema', location: '', distanceKm: 0, showtimes: []),
        showtime: Showtime(id: 's1', time: '07:15 PM', format: '3D', price: 1200, availableSeats: 0),
        date: DateTime.now(),
        seatNumbers: ['D5', 'D6'],
        totalAmount: 2400,
        isActive: true,
      ),
      Ticket(
        id: 'CB2026031702',
        movie: Movie(id: '2', title: 'The Perfect Alibi', genre: '', duration: '', rating: 0, posterUrl: '', synopsis: '', isNowShowing: true),
        cinema: Cinema(id: 'c2', name: 'Scope Cinemas', location: '', distanceKm: 0, showtimes: []),
        showtime: Showtime(id: 's2', time: '02:15 PM', format: '2D', price: 900, availableSeats: 0),
        date: DateTime.now().add(const Duration(days: 1)),
        seatNumbers: ['F8', 'F9', 'F10'],
        totalAmount: 2700,
        isActive: true,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          children: const [
            Text('My Tickets', style: TextStyle(fontSize: 18)),
            Text('Your booking history', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white70)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: const Center(child: Text('Active (2)', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20)),
                    child: const Center(child: Text('Past (1)', style: TextStyle(color: Colors.white))),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                return _buildTicketCard(context, tickets[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, Ticket ticket) {
    return GestureDetector(
      onTap: () {
        context.push('/ticket-details', extra: ticket);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.primary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ticket.movie.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('${ticket.cinema.name} - Hall 1', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.qr_code, size: 14, color: Colors.black),
                        SizedBox(width: 4),
                        Text('Ready', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                          const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          const Text('Today', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(ticket.showtime.time, style: const TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Seats', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Row(
                            children: ticket.seatNumbers.map((seat) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                                child: Text(seat, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Total', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text('LKR ${ticket.totalAmount.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ref: ${ticket.id}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                        child: Text(ticket.showtime.format, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
