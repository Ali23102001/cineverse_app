import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'movie_detail_screen.dart';
import 'watchlist_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Movie> favorites;
  final List<Movie> watchlist;
  final void Function(Movie) onToggleFavorite;
  final void Function(Movie) onToggleWatchlist;

  const FavoritesScreen({
    super.key,
    required this.favorites,
    required this.watchlist,
    required this.onToggleFavorite,
    required this.onToggleWatchlist,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _openDetail(Movie m) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MovieDetailScreen(
            movie: m,
            onToggleFavorite: widget.onToggleFavorite,
            onToggleWatchlist: widget.onToggleWatchlist,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              Container(width: 24, height: 20,
                decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 13)),
              const SizedBox(width: 8),
              const Text('CINEVERSE',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const Spacer(),
              const Icon(Icons.search_rounded, color: Colors.white),
              const SizedBox(width: 12),
              const Icon(Icons.account_circle_outlined, color: Colors.white),
            ],
          ),
        ),

        // Tabs
        TabBar(
          controller: _tab,
          indicatorColor: AppColors.red,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: const [Tab(text: 'My Favorites'), Tab(text: 'My Watchlist')],
        ),

        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _FavGrid(
                movies: widget.favorites,
                onToggleFavorite: widget.onToggleFavorite,
                onTap: _openDetail,
              ),
              WatchlistContent(
                watchlist: widget.watchlist,
                onToggleWatchlist: widget.onToggleWatchlist,
                onTap: _openDetail,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FavGrid extends StatelessWidget {
  final List<Movie> movies;
  final void Function(Movie) onToggleFavorite;
  final void Function(Movie) onTap;
  const _FavGrid({required this.movies, required this.onToggleFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.favorite_border_rounded, color: Colors.grey[700], size: 60),
          const SizedBox(height: 12),
          const Text('No favorites yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
        ]),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('My Favorites',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              Text('You have ${movies.length} movies saved in your collection.',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.68),
            itemCount: movies.length,
            itemBuilder: (_, i) => FavCard(
              movie: movies[i],
              onToggleFavorite: onToggleFavorite,
              onTap: onTap,
            ),
          ),
        ),
      ],
    );
  }
}
