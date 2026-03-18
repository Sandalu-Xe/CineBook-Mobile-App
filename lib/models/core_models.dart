class Movie {
  final String id;
  final String title;
  final String genre;
  final String duration;
  final double rating;
  final String posterUrl;
  final String synopsis;
  final bool isNowShowing;

  Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.duration,
    required this.rating,
    required this.posterUrl,
    required this.synopsis,
    required this.isNowShowing,
  });
}

class Cinema {
  final String id;
  final String name;
  final String location;
  final double distanceKm;
  final List<Showtime> showtimes;

  Cinema({
    required this.id,
    required this.name,
    required this.location,
    required this.distanceKm,
    required this.showtimes,
  });
}

class Showtime {
  final String id;
  final String time;
  final String format; // 2D, 3D, IMAX
  final double price;
  final int availableSeats;
  final bool isFillingFast;

  Showtime({
    required this.id,
    required this.time,
    required this.format,
    required this.price,
    required this.availableSeats,
    this.isFillingFast = false,
  });
}

class Ticket {
  final String id;
  final Movie movie;
  final Cinema cinema;
  final Showtime showtime;
  final DateTime date;
  final List<String> seatNumbers;
  final double totalAmount;
  final bool isActive;

  Ticket({
    required this.id,
    required this.movie,
    required this.cinema,
    required this.showtime,
    required this.date,
    required this.seatNumbers,
    required this.totalAmount,
    this.isActive = true,
  });
}
