import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../theme/app_theme.dart';

class WatchlistContent extends StatelessWidget {
  final List<Movie> watchlist;
  final void Function(Movie) onToggleWatchlist;
  final void Function(Movie) onTap;

  const WatchlistContent({
    super.key,
    required this.watchlist,
    required this.onToggleWatchlist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        const Text('My Watchlist',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
        Text('You have ${watchlist.length} movies saved to explore.',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 16),

        if (watchlist.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 60),
              child: Text('No movies in watchlist', style: TextStyle(color: AppColors.textSecondary)),
            ),
          )
        else
          ...watchlist.map((m) => _WatchlistCard(
                movie: m,
                onRemove: () => onToggleWatchlist(m),
                onTap: () => onTap(m),
              )),

        // Discover more footer
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            const Icon(Icons.movie_filter_outlined, color: AppColors.textSecondary, size: 36),
            const SizedBox(height: 10),
            const Text('Discover More',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Need Inspiration? Explore our curated recommendations.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ]),
        ),
      ],
    );
  }
}

class _WatchlistCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _WatchlistCard({required this.movie, required this.onRemove, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final genre = movie.genreIds.isNotEmpty
        ? (_genres[movie.genreIds.first] ?? 'Movie')
        : 'Movie';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backdrop
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                movie.backdropUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 160,
                  color: AppColors.card,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Genre chips
                  Row(children: [
                    _SmallChip(label: genre.toUpperCase()),
                    const SizedBox(width: 8),
                    if (movie.genreIds.length > 1)
                      _SmallChip(label: (_genres[movie.genreIds[1]] ?? '').toUpperCase()),
                  ]),
                  const SizedBox(height: 8),
                  Text(movie.title,
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                    movie.overview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  // EDIT / DELETE buttons
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 14, color: Colors.white),
                        label: const Text('EDIT', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onRemove,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(Icons.delete_outline, size: 14, color: AppColors.red),
                        label: const Text('DELETE', style: TextStyle(color: AppColors.red, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  final String label;
  const _SmallChip({required this.label});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      );
}

const _genres = {
  28: 'Action', 12: 'Adventure', 16: 'Animation',
  35: 'Comedy', 80: 'Crime', 99: 'Documentary',
  18: 'Drama', 10751: 'Family', 14: 'Fantasy',
  36: 'History', 27: 'Horror', 10402: 'Music',
  9648: 'Mystery', 10749: 'Romance', 878: 'Sci-Fi',
  53: 'Thriller', 10752: 'War', 37: 'Western',
};
