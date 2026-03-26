import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/home_viewmodel.dart';
import '../models/core_models.dart';
import 'trailer_screen.dart';

class MovieDetailsScreen extends StatelessWidget {
  final String id;
  const MovieDetailsScreen({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);
    final allMovies = viewModel.currentMovies.isNotEmpty 
        ? viewModel.currentMovies 
        : [Movie(id: '1', title: 'Loading...', genre: '', duration: '', rating: 0.0, posterUrl: '', synopsis: '', isNowShowing: true)];
    final movie = allMovies.firstWhere((m) => m.id == id, orElse: () => allMovies.first);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 320,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: colorScheme.surfaceVariant,
                    child: Image.asset(
                      movie.posterUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(Icons.movie, size: 64, color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          colorScheme.background.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: FilledButton.icon(
                      onPressed: () {
                        if (movie.trailerUrl.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TrailerScreen(
                                videoId: movie.trailerUrl,
                                movieTitle: movie.title,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No trailer available for this movie.')),
                          );
                        }
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Watch Trailer'),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: colorScheme.onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              transform: Matrix4.translationValues(0, -32, 0),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie.title,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                movie.genre,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 16, color: colorScheme.onTertiaryContainer),
                              const SizedBox(width: 4),
                              Text('${movie.rating}/10', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onTertiaryContainer)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(movie.duration, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        const SizedBox(width: 16),
                        Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text('Releasing Today', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () {
                        context.push('/cinemas/${movie.id}');
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Book Tickets'),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Synopsis',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      movie.synopsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Cast & Crew',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    // Mock cast
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: colorScheme.secondaryContainer,
                                  child: Text('A${index + 1}', style: TextStyle(color: colorScheme.onSecondaryContainer)),
                                ),
                                const SizedBox(height: 8),
                                Text('Actor Name', style: Theme.of(context).textTheme.labelMedium),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
