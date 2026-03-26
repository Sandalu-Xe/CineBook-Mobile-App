import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';
import '../viewmodels/home_viewmodel.dart';
import '../models/core_models.dart';
import '../services/seed_service.dart';
import 'cinema_map_screen.dart';
import 'custom_navigation_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Seeding database... Please wait.')),
          );
          try {
            await SeedService().seedDatabase();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Database seeded! Pull to refresh.')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Database seeding failed!')),
            );
          }
        },
        icon: const Icon(Icons.sync),
        label: const Text('Sync Cinema data'),
      ),
      bottomNavigationBar: const CustomNavigationBar(selectedIndex: 0),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () async {
              // mock refresh
            },
            child: CustomScrollView(
              slivers: [
                SliverAppBar.large(
                  title: const Text('CineBook'),
                  floating: true,
                  pinned: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.map_outlined),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CinemaMapScreen()));
                      },
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: SearchBar(
                      hintText: 'Search movies, genres...',
                      leading: const Icon(Icons.search),
                      elevation: MaterialStateProperty.all(1.0),
                      padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 16.0)),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            const Text('Colombo, Sri Lanka', style: TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(value: true, label: Text('Now Showing')),
                          ButtonSegment<bool>(value: false, label: Text('Upcoming')),
                        ],
                        selected: {viewModel.showNowShowing},
                        onSelectionChanged: (Set<bool> newSelection) {
                          viewModel.toggleMovieType(newSelection.first);
                        },
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.55,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildMovieCard(context, viewModel.currentMovies[index]);
                      },
                      childCount: viewModel.currentMovies.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMovieCard(BuildContext context, Movie movie) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/movie/${movie.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      image: DecorationImage(
                        image: AssetImage(movie.posterUrl),
                        fit: BoxFit.cover,
                        onError: (_, __) {},
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Theme.of(context).colorScheme.onSecondaryContainer),
                          const SizedBox(width: 4),
                          Text(
                            movie.rating.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).colorScheme.onSecondaryContainer),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movie.genre,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        movie.duration,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
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

