import 'dart:async';
import 'package:flutter/material.dart';
import '../models/core_models.dart';
import '../services/database_service.dart';
import '../services/seed_service.dart';

class HomeViewModel extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  bool _isLoading = false;
  bool _showNowShowing = true; // Toggle for 'Now Showing' vs 'Upcoming'
  
  List<Movie> _allMovies = [];
  StreamSubscription? _moviesSub;

  bool get isLoading => _isLoading;
  bool get showNowShowing => _showNowShowing;
  List<Movie> get currentMovies => _allMovies.where((m) => m.isNowShowing == _showNowShowing).toList();

  HomeViewModel() {
    _listenToMovies();
  }

  void toggleMovieType(bool isNowShowing) {
    _showNowShowing = isNowShowing;
    notifyListeners();
  }

  void _listenToMovies() {
    _isLoading = true;
    notifyListeners();

    _moviesSub = _db.getMoviesStream().listen((movies) async {
      if (movies.isEmpty) {
        // Automatically seed the empty database!
        try {
          await SeedService().seedDatabase();
        } catch(e) {
          print('Seed failed: $e');
        }
        return; // Stream will naturally trigger again once seeded
      }
      _allMovies = movies;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print('Error fetching movies: $error');
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _moviesSub?.cancel();
    super.dispose();
  }
}
