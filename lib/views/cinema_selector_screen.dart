import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';
import '../models/core_models.dart';

class CinemaSelectorScreen extends StatelessWidget {
  final String movieId;
  const CinemaSelectorScreen({Key? key, required this.movieId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data for cinemas
    final mockCinemas = [
      Cinema(
        id: 'c1',
        name: 'Liberty Cinema',
        location: 'Colombo 03, Dharmapala Mawatha',
        distanceKm: 2.5,
        latitude: 6.9099,
        longitude: 79.8510,
        showtimes: [
          Showtime(id: 's1', time: '10:30 AM', format: '2D', price: 850, availableSeats: 45),
          Showtime(id: 's2', time: '01:45 PM', format: '3D', price: 1200, availableSeats: 32),
          Showtime(id: 's3', time: '04:30 PM', format: 'IMAX', price: 1500, availableSeats: 18, isFillingFast: true),
          Showtime(id: 's4', time: '07:15 PM', format: '3D', price: 1200, availableSeats: 12, isFillingFast: true),
          Showtime(id: 's5', time: '10:00 PM', format: '2D', price: 850, availableSeats: 56),
        ],
      ),
      Cinema(
        id: 'c2',
        name: 'Scope Cinemas',
        location: 'Colombo City Centre',
        distanceKm: 4.2,
        latitude: 6.9150,
        longitude: 79.8580,
        showtimes: [
          Showtime(id: 's6', time: '11:00 AM', format: '2D', price: 1000, availableSeats: 60),
          Showtime(id: 's7', time: '02:30 PM', format: 'ATMOS', price: 1300, availableSeats: 20, isFillingFast: true),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          children: const [
            Text('Velocity Strike', style: TextStyle(fontSize: 18)),
            Text('Action / Thriller', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDateChip('Today', true),
                _buildDateChip('Tomorrow', false),
                _buildDateChip('Mar 19', false),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.location_on_outlined, size: 20, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text('Colombo, Sri Lanka'),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.near_me, size: 16),
                  label: const Text('Near me'),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: mockCinemas.length,
              itemBuilder: (context, index) {
                return _buildCinemaCard(context, mockCinemas[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? Colors.white : Colors.white54),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 16, color: isSelected ? AppColors.primary : Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCinemaCard(BuildContext context, Cinema cinema) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cinema.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(cinema.location, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('${cinema.distanceKm} km', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(),
            ),
            const Text('Showtimes', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: cinema.showtimes.map((s) => _buildShowtimeCard(context, s)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowtimeCard(BuildContext context, Showtime showtime) {
    return GestureDetector(
      onTap: () {
        context.push('/seat-selection', extra: showtime);
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(showtime.time.split(' ')[0], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 4),
                Text(showtime.time.split(' ')[1], style: const TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: showtime.format == 'IMAX' ? AppColors.secondary : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                showtime.format,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Text('LKR ${showtime.price.toInt()}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${showtime.availableSeats} seats',
                  style: TextStyle(
                    fontSize: 10,
                    color: showtime.isFillingFast ? AppColors.error : AppColors.success,
                  ),
                ),
                if (showtime.isFillingFast) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(4)),
                    child: const Text('Filling Fast', style: TextStyle(color: Colors.white, fontSize: 8)),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}
