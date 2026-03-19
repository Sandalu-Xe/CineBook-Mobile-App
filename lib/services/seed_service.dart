import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/core_models.dart';

class SeedService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> seedDatabase() async {
    final movies = [
      Movie(
        id: '1',
        title: 'Velocity Strike',
        genre: 'Action / Thriller',
        duration: '2h 15min',
        rating: 8.5,
        posterUrl: 'assets/images/velocity.png',
        synopsis: 'When a former special ops agent discovers a conspiracy...',
        isNowShowing: true,
      ),
      Movie(
        id: '2',
        title: 'The Last...',
        genre: 'Drama / Mystery',
        duration: '2h 5min',
        rating: 9.1,
        posterUrl: 'assets/images/last.png',
        synopsis: 'A detective is forced to confront his past...',
        isNowShowing: true,
      ),
      Movie(
        id: '3',
        title: 'Ted 2',
        genre: 'Comedy',
        duration: '1h 55min',
        rating: 7.9,
        posterUrl: 'assets/images/ted.png',
        synopsis: 'Newlywed couple Ted and Tami-Lynn want to have a baby...',
        isNowShowing: true,
      ),
      Movie(
        id: '4',
        title: 'Upcoming Hit',
        genre: 'Sci-Fi',
        duration: '2h 30min',
        rating: 0.0,
        posterUrl: 'assets/images/upcoming.png',
        synopsis: 'An epic journey to the stars...',
        isNowShowing: false,
      ),
    ];

    final cinema = Cinema(
      id: 'cin1',
      name: 'PVR Cinemas',
      location: 'One Galle Face Mall',
      distanceKm: 2.5,
      latitude: 6.9271,
      longitude: 79.8436,
      showtimes: [
        Showtime(id: 's1', time: '10:00 AM', format: '2D', price: 1000, availableSeats: 50, isFillingFast: false),
        Showtime(id: 's2', time: '01:30 PM', format: '3D', price: 1500, availableSeats: 12, isFillingFast: true),
        Showtime(id: 's3', time: '06:00 PM', format: 'IMAX', price: 2000, availableSeats: 5, isFillingFast: true),
      ],
    );

    // Write movies
    for (var movie in movies) {
      await _db.collection('movies').doc(movie.id).set(movie.toMap());
    }

    // Write cinema
    await _db.collection('cinemas').doc(cinema.id).set(cinema.toMap());

    print('Database successfully seeded!');
  }
}
