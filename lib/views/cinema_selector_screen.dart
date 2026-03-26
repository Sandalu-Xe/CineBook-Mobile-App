import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/core_models.dart';
import 'cinema_map_screen.dart';
import '../services/database_service.dart';

class CinemaSelectorScreen extends StatefulWidget {
  final String movieId;
  const CinemaSelectorScreen({Key? key, required this.movieId}) : super(key: key);

  @override
  State<CinemaSelectorScreen> createState() => _CinemaSelectorScreenState();
}

class _CinemaSelectorScreenState extends State<CinemaSelectorScreen> {
  final DatabaseService _db = DatabaseService();
  String _selectedDate = 'Today';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Velocity Strike', style: TextStyle(fontSize: 18)),
            Text('Action / Thriller', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: colorScheme.surfaceVariant,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildDateChip('Today', context),
                  const SizedBox(width: 8),
                  _buildDateChip('Tomorrow', context),
                  const SizedBox(width: 8),
                  _buildDateChip('Mar 19', context),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 20, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    const Text('Colombo, Sri Lanka'),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CinemaMapScreen()));
                  },
                  icon: const Icon(Icons.near_me, size: 16),
                  label: const Text('Near me'),
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Cinema>>(
              stream: _db.getCinemasStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading cinemas: ${snapshot.error}'));
                }
                final liveCinemas = snapshot.data ?? [];
                if (liveCinemas.isEmpty) {
                  return const Center(child: Text('No cinemas found. Please press the download button on the Home Screen.'));
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: liveCinemas.length,
                  itemBuilder: (context, index) {
                    return _buildCinemaCard(context, liveCinemas[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip(String label, BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedDate == label,
      onSelected: (bool selected) {
        setState(() {
          if (selected) _selectedDate = label;
        });
      },
    );
  }

  Widget _buildCinemaCard(BuildContext context, Cinema cinema) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                      Text(cinema.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CinemaMapScreen(targetCinema: cinema)));
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.map, size: 16, color: colorScheme.primary),
                            const SizedBox(width: 4),
                            Expanded(child: Text(cinema.location, style: TextStyle(color: colorScheme.primary, fontSize: 13, decoration: TextDecoration.underline))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: colorScheme.onSecondaryContainer),
                      const SizedBox(width: 4),
                      Text('${cinema.distanceKm} km', style: TextStyle(fontSize: 12, color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(),
            ),
            Text('Showtimes', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: cinema.showtimes.map((s) => _buildShowtimeCard(context, cinema, s)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowtimeCard(BuildContext context, Cinema cinema, Showtime showtime) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        context.push('/seat-selection', extra: {
          'movieId': widget.movieId,
          'cinema': cinema,
          'showtime': showtime,
        });
      },
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
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
                color: showtime.format == 'IMAX' ? colorScheme.tertiaryContainer : colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                showtime.format,
                style: TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.bold,
                  color: showtime.format == 'IMAX' ? colorScheme.onTertiaryContainer : colorScheme.onSurfaceVariant
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('LKR ${showtime.price.toInt()}', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${showtime.availableSeats} seats',
                  style: TextStyle(
                    fontSize: 10,
                    color: showtime.isFillingFast ? colorScheme.error : colorScheme.primary,
                  ),
                ),
                if (showtime.isFillingFast) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(color: colorScheme.errorContainer, borderRadius: BorderRadius.circular(4)),
                    child: Text('Filling Fast', style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 8, fontWeight: FontWeight.bold)),
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
