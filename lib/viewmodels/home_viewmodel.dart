import 'package:flutter/material.dart';
import '../models/core_models.dart';

class HomeViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _showNowShowing = true; // Toggle for 'Now Showing' vs 'Upcoming'
  
  List<Movie> _allMovies = [];

  bool get isLoading => _isLoading;
  bool get showNowShowing => _showNowShowing;
  List<Movie> get currentMovies => _allMovies.where((m) => m.isNowShowing == _showNowShowing).toList();

  HomeViewModel() {
    _loadMockData();
  }

  void toggleMovieType(bool isNowShowing) {
    _showNowShowing = isNowShowing;
    notifyListeners();
  }

  void _loadMockData() {
    _isLoading = true;
    notifyListeners();

    // Mock data based on wireframes
    _allMovies = [
      Movie(
        id: '1',
        title: 'Velocity Strike',
        genre: 'Action / Thriller',
        duration: '2h 15min',
        rating: 8.5,
        posterUrl: 'assets/images/velocity.png', // We'll add a generic color fallback in UI
        synopsis: 'When a former special ops agent discovers a conspiracy threatening national security...',
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

    _isLoading = false;
    notifyListeners();
  }
}
