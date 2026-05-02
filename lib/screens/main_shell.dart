import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'dashboard_screen.dart';

class MainShell extends StatefulWidget {
  final User firebaseUser;
  const MainShell({super.key, required this.firebaseUser});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;
  final List<Movie> _favorites = [];
  final List<Movie> _watchlist = [];

  void _toggleFavorite(Movie movie) {
    setState(() {
      movie.isFavorite = !movie.isFavorite;
      if (movie.isFavorite) {
        if (!_favorites.any((m) => m.id == movie.id)) _favorites.add(movie);
      } else {
        _favorites.removeWhere((m) => m.id == movie.id);
      }
    });
  }

  void _toggleWatchlist(Movie movie) {
    setState(() {
      movie.inWatchlist = !movie.inWatchlist;
      if (movie.inWatchlist) {
        if (!_watchlist.any((m) => m.id == movie.id)) _watchlist.add(movie);
      } else {
        _watchlist.removeWhere((m) => m.id == movie.id);
      }
    });
  }

  static const _navItems = [
    _NavItem(icon: Icons.home_rounded,       label: 'HOME'),
    _NavItem(icon: Icons.search_rounded,     label: 'SEARCH'),
    _NavItem(icon: Icons.movie_outlined,     label: 'MOVIES'),
    _NavItem(icon: Icons.favorite_border,    label: 'FAVORITES'),
    _NavItem(icon: Icons.person_outline,     label: 'PROFILE'),
    _NavItem(icon: Icons.dashboard_outlined, label: 'DASHBOARD'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        favorites: _favorites, watchlist: _watchlist,
        onToggleFavorite: _toggleFavorite, onToggleWatchlist: _toggleWatchlist,
        onTabSwitch: (i) => setState(() => _tab = i),
      ),
      SearchScreen(
        favorites: _favorites, watchlist: _watchlist,
        onToggleFavorite: _toggleFavorite, onToggleWatchlist: _toggleWatchlist,
      ),
      HomeScreen(
        favorites: _favorites, watchlist: _watchlist,
        onToggleFavorite: _toggleFavorite, onToggleWatchlist: _toggleWatchlist,
        onTabSwitch: (i) => setState(() => _tab = i),
      ),
      FavoritesScreen(
        favorites: _favorites, watchlist: _watchlist,
        onToggleFavorite: _toggleFavorite, onToggleWatchlist: _toggleWatchlist,
      ),
      ProfileScreen(
        firebaseUser: widget.firebaseUser,
        favorites: _favorites,
        watchlist: _watchlist,
      ),
      const DashboardScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: pages[_tab]),
      bottomNavigationBar: _buildNav(),
    );
  }

  Widget _buildNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.07))),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 58,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (i) {
              final selected = _tab == i;
              final item = _navItems[i];
              return GestureDetector(
                onTap: () => setState(() => _tab = i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _filledIcon(item.icon, selected),
                        color: selected ? AppColors.red : Colors.grey[600],
                        size: 21,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: selected ? AppColors.red : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: selected ? 16 : 0,
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ✅ الحل: بدل const map، استخدم if/else عشان IconData مش بينفع key في const map
  IconData _filledIcon(IconData outline, bool selected) {
    if (!selected) return outline;
    if (outline == Icons.home_rounded)       return Icons.home_rounded;
    if (outline == Icons.search_rounded)     return Icons.search_rounded;
    if (outline == Icons.movie_outlined)     return Icons.movie_rounded;
    if (outline == Icons.favorite_border)    return Icons.favorite;
    if (outline == Icons.person_outline)     return Icons.person_rounded;
    if (outline == Icons.dashboard_outlined) return Icons.dashboard_rounded;
    return outline;
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}