import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../theme/app_theme.dart';
import 'movie_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final List<Movie> favorites;
  final List<Movie> watchlist;
  final void Function(Movie) onToggleFavorite;
  final void Function(Movie) onToggleWatchlist;

  const SearchScreen({
    super.key,
    required this.favorites,
    required this.watchlist,
    required this.onToggleFavorite,
    required this.onToggleWatchlist,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _svc = MovieService();

  List<Movie> _results = [];
  List<Movie> _default = [];
  bool _loading = false;
  String _activeFilter = 'All';
  final _filters = ['All', 'Movies', 'TV Shows', 'Actors'];

  @override
  void initState() {
    super.initState();
    _loadDefault();
  }

  Future<void> _loadDefault() async {
    setState(() => _loading = true);
    try {
      final movies = await _svc.fetchPopular();
      setState(() { _default = movies; _results = movies; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() => _results = _default);
      return;
    }
    setState(() => _loading = true);
    try {
      final r = await _svc.searchMovies(q);
      setState(() { _results = r; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
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
        Container(
          color: AppColors.background,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Container(width: 24, height: 20,
                decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 13)),
              const SizedBox(width: 8),
              const Text('CINEVERSE',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const Spacer(),
              const Icon(Icons.account_circle_outlined, color: Colors.white),
            ],
          ),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _ctrl,
            onChanged: _search,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Interstellar',
              fillColor: Colors.white,
              filled: true,
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),

        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            children: _filters.map((f) {
              final active = f == _activeFilter;
              return GestureDetector(
                onTap: () => setState(() => _activeFilter = f),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? AppColors.red : AppColors.surface,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(f,
                      style: TextStyle(
                          color: active ? Colors.white : AppColors.textSecondary,
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              );
            }).toList(),
          ),
        ),

        // Results grid
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.red))
              : _results.isEmpty
                  ? const Center(child: Text('No results', style: TextStyle(color: AppColors.textSecondary)))
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75,
                      ),
                      itemCount: _results.length,
                      itemBuilder: (_, i) {
                        final m = _results[i];
                        return GestureDetector(
                          onTap: () => _openDetail(m),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              m.posterUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.card,
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
