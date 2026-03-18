import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/welcome_screen.dart';
import '../views/login_screen.dart';
import '../views/home_screen.dart';
import '../views/movie_details_screen.dart';
import '../views/cinema_selector_screen.dart';
import '../views/seat_selection_screen.dart';
import '../views/tickets_screen.dart';
import '../views/ticket_details_screen.dart';
import '../models/core_models.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String home = '/home';

  static final GoRouter router = GoRouter(
    initialLocation: welcome,
    routes: [
      GoRoute(
        path: welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/movie/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '1';
          return MovieDetailsScreen(id: id);
        },
      ),
      GoRoute(
        path: '/cinemas/:movieId',
        builder: (context, state) {
          final movieId = state.pathParameters['movieId'] ?? '1';
          return CinemaSelectorScreen(movieId: movieId);
        },
      ),
      GoRoute(
        path: '/seat-selection',
        builder: (context, state) {
          final showtime = state.extra as Showtime?;
          return SeatSelectionScreen(showtime: showtime);
        },
      ),
      GoRoute(
        path: '/tickets',
        builder: (context, state) {
          return const TicketsScreen();
        },
      ),
      GoRoute(
        path: '/ticket-details',
        builder: (context, state) {
          final ticket = state.extra as Ticket;
          return TicketDetailsScreen(ticket: ticket);
        },
      ),
    ],
  );
}
