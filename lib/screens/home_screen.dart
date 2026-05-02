import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<Movie> favorites;
  final List<Movie> watchlist;
  final void Function(Movie) onToggleFavorite;
  final void Function(Movie) onToggleWatchlist;
  final void Function(int)? onTabSwitch;

  const HomeScreen({
    super.key,
    required this.favorites,
    required this.watchlist,
    required this.onToggleFavorite,
    required this.onToggleWatchlist,
    this.onTabSwitch,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _svc = MovieService();
  List<Movie> _popular = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final movies = await _svc.fetchPopular();
      // Sync fav/watchlist state
      for (var m in movies) {
        m.isFavorite = widget.favorites.any((f) => f.id == m.id);
        m.inWatchlist = widget.watchlist.any((w) => w.id == m.id);
      }
      setState(() { _popular = movies; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
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
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.red));
    if (_error != null) return Center(child: Text(_error!, style: const TextStyle(color: AppColors.red)));

    final trending = _popular.take(10).toList();
    final all = _popular;

    return CustomScrollView(
      slivers: [
        // App bar
        SliverAppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          floating: true,
          title: _logo(),
          actions: [
            IconButton(icon: const Icon(Icons.search_rounded, color: Colors.white),
              onPressed: () => widget.onTabSwitch?.call(1)),
            IconButton(icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
              onPressed: () => widget.onTabSwitch?.call(4)),
          ],
        ),

        // Editor's Choice label + Trending
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("EDITOR'S CHOICE",
                        style: TextStyle(color: AppColors.red, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Trending Movies',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                        GestureDetector(
                          onTap: () {},
                          child: const Text('View All', style: TextStyle(color: AppColors.red, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 260,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: trending.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: TrendingCard(
                      movie: trending[i],
                      onToggleFavorite: widget.onToggleFavorite,
                      onTap: _openDetail,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Text('All Movies', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),

        // Grid
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) => MovieGridCard(
                movie: all[i],
                onToggleFavorite: widget.onToggleFavorite,
                onTap: _openDetail,
              ),
              childCount: all.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 20, childAspectRatio: 0.58,
            ),
          ),
        ),
      ],
    );
  }

  Widget _logo() => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 26, height: 22,
          decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(5)),
          child: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 15),
        ),
        const SizedBox(width: 8),
        const Text('CINEVERSE',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      ]);
}
