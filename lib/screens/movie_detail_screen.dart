import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  final void Function(Movie) onToggleFavorite;
  final void Function(Movie) onToggleWatchlist;

  const MovieDetailScreen({
    super.key,
    required this.movie,
    required this.onToggleFavorite,
    required this.onToggleWatchlist,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final _svc = MovieService();
  List<Movie> _similar = [];

  @override
  void initState() {
    super.initState();
    _loadSimilar();
  }

  Future<void> _loadSimilar() async {
    try {
      final s = await _svc.fetchSimilar(widget.movie.id);
      setState(() => _similar = s.take(6).toList());
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.movie;
    final genreLabels = m.genreIds.take(3)
        .map((id) => MovieService_genres[id] ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero backdrop
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(m.backdropUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: AppColors.card)),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.background],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Genre chips
                  if (genreLabels.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: genreLabels.map((g) => _Chip(label: g)).toList(),
                    ),
                  const SizedBox(height: 10),

                  // Title
                  Text(m.title,
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, height: 1.2)),
                  const SizedBox(height: 12),

                  // Rating / Date / Runtime
                  Row(children: [
                    const Icon(Icons.star_rounded, color: AppColors.gold, size: 18),
                    const SizedBox(width: 4),
                    Text('${m.voteAverage.toStringAsFixed(1)}',
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 16),
                    const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 14),
                    const SizedBox(width: 4),
                    Text(m.releaseDate, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time_rounded, color: AppColors.textSecondary, size: 14),
                    const SizedBox(width: 4),
                    const Text('2h 14m', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ]),
                  const SizedBox(height: 20),

                  // Overview
                  const Text('Overview',
                      style: TextStyle(color: AppColors.red, fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    m.overview.isNotEmpty ? m.overview : 'No overview available.',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.65),
                  ),
                  const SizedBox(height: 24),

                  // Info grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: const [
                      _InfoTile(label: 'DIRECTOR', value: 'Elena Vance'),
                      _InfoTile(label: 'WRITER', value: 'Marcus Thorne'),
                      _InfoTile(label: 'BUDGET', value: '\$145M'),
                      _InfoTile(label: 'LANGUAGE', value: 'English (US)'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                      label: const Text('WATCH TRAILER',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  StatefulBuilder(builder: (_, setS) => _OutlineBtn(
                    icon: m.isFavorite ? Icons.favorite : Icons.favorite_border,
                    label: m.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                    iconColor: AppColors.red,
                    onTap: () { widget.onToggleFavorite(m); setS(() {}); },
                  )),
                  const SizedBox(height: 10),
                  StatefulBuilder(builder: (_, setS) => _OutlineBtn(
                    icon: m.inWatchlist ? Icons.bookmark : Icons.bookmark_border,
                    label: m.inWatchlist ? 'Remove from Watchlist' : 'Add to Watchlist',
                    iconColor: Colors.white,
                    onTap: () { widget.onToggleWatchlist(m); setS(() {}); },
                  )),
                  const SizedBox(height: 28),

                  // Related
                  if (_similar.isNotEmpty) ...[
                    const Text('Related Content',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.7),
                      itemCount: _similar.length,
                      itemBuilder: (_, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(_similar[i].posterUrl, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: AppColors.card)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
      );
}

class _InfoTile extends StatelessWidget {
  final String label, value;
  const _InfoTile({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 10, letterSpacing: 1)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

class _OutlineBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;
  const _OutlineBtn({required this.icon, required this.label, required this.iconColor, required this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: Icon(icon, color: iconColor, size: 18),
          label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      );
}
