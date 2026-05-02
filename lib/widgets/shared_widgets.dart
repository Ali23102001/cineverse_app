import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../theme/app_theme.dart';

// ─── Cineverse AppBar ──────────────────────────────
class CineverseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  const CineverseAppBar({super.key, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26, height: 22,
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 15),
          ),
          const SizedBox(width: 8),
          const Text(
            'CINEVERSE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }
}

// ─── Trending Card (horizontal list) ───────────────
class TrendingCard extends StatefulWidget {
  final Movie movie;
  final void Function(Movie) onToggleFavorite;
  final void Function(Movie) onTap;

  const TrendingCard({
    super.key,
    required this.movie,
    required this.onToggleFavorite,
    required this.onTap,
  });

  @override
  State<TrendingCard> createState() => _TrendingCardState();
}

class _TrendingCardState extends State<TrendingCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onTap(widget.movie),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _NetImage(url: widget.movie.posterUrl),
              // gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.92)],
                    stops: const [0.4, 0.65, 1.0],
                  ),
                ),
              ),
              // fav button
              Positioned(
                top: 10, right: 10,
                child: _FavBtn(movie: widget.movie, onToggle: () {
                  widget.onToggleFavorite(widget.movie);
                  setState(() {});
                }),
              ),
              // info
              Positioned(
                bottom: 12, left: 12, right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.movie.title,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    _StarRating(rating: widget.movie.voteAverage),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Grid Card (2-column grid) ─────────────────────
class MovieGridCard extends StatefulWidget {
  final Movie movie;
  final void Function(Movie) onToggleFavorite;
  final void Function(Movie) onTap;

  const MovieGridCard({
    super.key,
    required this.movie,
    required this.onToggleFavorite,
    required this.onTap,
  });

  @override
  State<MovieGridCard> createState() => _MovieGridCardState();
}

class _MovieGridCardState extends State<MovieGridCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onTap(widget.movie),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _NetImage(url: widget.movie.posterUrl, width: double.infinity, height: double.infinity),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: _FavBtn(
                    movie: widget.movie,
                    size: 28,
                    iconSize: 14,
                    onToggle: () {
                      widget.onToggleFavorite(widget.movie);
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(widget.movie.title,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          _StarRating(rating: widget.movie.voteAverage, fontSize: 10),
        ],
      ),
    );
  }
}

// ─── Favorites Grid Card (with genre + year overlay) ─
class FavCard extends StatefulWidget {
  final Movie movie;
  final void Function(Movie) onToggleFavorite;
  final void Function(Movie) onTap;
  const FavCard({super.key, required this.movie, required this.onToggleFavorite, required this.onTap});

  @override
  State<FavCard> createState() => _FavCardState();
}

class _FavCardState extends State<FavCard> {
  @override
  Widget build(BuildContext context) {
    final genre = widget.movie.genreIds.isNotEmpty
        ? (MovieService_genres[widget.movie.genreIds.first] ?? 'Movie')
        : 'Movie';

    return GestureDetector(
      onTap: () => widget.onTap(widget.movie),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _NetImage(url: widget.movie.posterUrl),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 8, right: 8,
              child: _FavBtn(
                movie: widget.movie,
                onToggle: () { widget.onToggleFavorite(widget.movie); setState(() {}); },
              ),
            ),
            Positioned(
              bottom: 12, left: 10, right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$genre • ${widget.movie.year}',
                      style: const TextStyle(color: AppColors.red, fontSize: 9, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(widget.movie.title,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// keep a reference to genres for FavCard
const Map<int, String> MovieService_genres = {
  28: 'Action', 12: 'Adventure', 16: 'Animation',
  35: 'Comedy', 80: 'Crime', 99: 'Documentary',
  18: 'Drama', 10751: 'Family', 14: 'Fantasy',
  36: 'History', 27: 'Horror', 10402: 'Music',
  9648: 'Mystery', 10749: 'Romance', 878: 'Sci-Fi',
  53: 'Thriller', 10752: 'War', 37: 'Western',
};

// ─── Helper Widgets ────────────────────────────────
class _NetImage extends StatelessWidget {
  final String url;
  final double? width, height;
  const _NetImage({required this.url, this.width, this.height});

  @override
  Widget build(BuildContext context) => Image.network(
        url,
        width: width, height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.card,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : Container(color: AppColors.card, child: const Center(
                child: CircularProgressIndicator(color: AppColors.red, strokeWidth: 2))),
      );
}

class _FavBtn extends StatelessWidget {
  final Movie movie;
  final VoidCallback onToggle;
  final double size;
  final double iconSize;
  const _FavBtn({required this.movie, required this.onToggle, this.size = 30, this.iconSize = 15});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onToggle,
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            movie.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: movie.isFavorite ? AppColors.red : Colors.white,
            size: iconSize,
          ),
        ),
      );
}

class _StarRating extends StatelessWidget {
  final double rating;
  final double fontSize;
  const _StarRating({required this.rating, this.fontSize = 11});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Icon(Icons.star_rounded, color: AppColors.gold, size: 13),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(color: AppColors.textSecondary, fontSize: fontSize, fontWeight: FontWeight.w600),
          ),
        ],
      );
}

// ─── Red Button ─────────────────────────────────────
class RedButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;
  const RedButton({super.key, required this.label, required this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: loading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: loading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        ),
      );
}

// ─── Auth Text Field ────────────────────────────────
class AuthField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextEditingController controller;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: AppColors.textHint, size: 18),
              suffixIcon: suffix,
            ),
          ),
        ],
      );
}
