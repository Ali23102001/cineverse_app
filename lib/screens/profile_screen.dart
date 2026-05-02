import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final User firebaseUser;
  final List<Movie> favorites;
  final List<Movie> watchlist;

  const ProfileScreen({
    super.key,
    required this.firebaseUser,
    required this.favorites,
    required this.watchlist,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loggingOut = false;

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    try {
      await AuthService().signOut();
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // بيانات المستخدم من Firebase
    final name = widget.firebaseUser.displayName ?? 'Cinema User';
    final email = widget.firebaseUser.email ?? '';
    final photoUrl = widget.firebaseUser.photoURL;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // App bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(children: [
            Container(width: 24, height: 20,
              decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(4)),
              child: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 13)),
            const SizedBox(width: 8),
            const Text('CINEVERSE',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const Spacer(),
            const Icon(Icons.notifications_none_rounded, color: Colors.white),
            const SizedBox(width: 12),
            const Icon(Icons.account_circle_outlined, color: Colors.white),
          ]),
        ),
        const SizedBox(height: 20),

        // Avatar — لو في صورة Google يعرضها
        Center(
          child: Stack(children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.red, width: 3),
              ),
              child: ClipOval(
                child: photoUrl != null
                    ? Image.network(photoUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _defaultAvatar())
                    : _defaultAvatar(),
              ),
            ),
            Positioned(
              bottom: 2, right: 2,
              child: Container(
                width: 24, height: 24,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.red),
                child: const Icon(Icons.edit, size: 12, color: Colors.white),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),

        // Name
        Center(child: Text(name,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800))),
        const SizedBox(height: 4),

        // Email
        Center(child: Text(email,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),

        // Google badge لو دخل بـ Google
        if (widget.firebaseUser.providerData.any((p) => p.providerId == 'google.com')) ...[
          const SizedBox(height: 6),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.g_mobiledata_rounded, color: Colors.blue, size: 16),
                SizedBox(width: 4),
                Text('Signed in with Google',
                    style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ],
        const SizedBox(height: 20),

        // Stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Expanded(child: _StatCard(icon: Icons.favorite, count: widget.favorites.length, label: 'FAVORITES')),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(icon: Icons.bookmark, count: widget.watchlist.length, label: 'WATCHLIST')),
          ]),
        ),
        const SizedBox(height: 24),

        // Settings
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Account Settings',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                _SettingTile(icon: Icons.settings_outlined, label: 'Preferences', onTap: () {}),
                const Divider(color: AppColors.border, height: 1),
                _SettingTile(icon: Icons.security_outlined, label: 'Privacy & Security', onTap: () {}),
                const Divider(color: AppColors.border, height: 1),
                _SettingTile(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  labelColor: AppColors.red,
                  iconColor: AppColors.red,
                  trailing: _loggingOut
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(color: AppColors.red, strokeWidth: 2))
                      : null,
                  onTap: _loggingOut ? () {} : _logout,
                ),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 24),

        // Recent favorites activity
        if (widget.favorites.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Recent Activity',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                GestureDetector(
                  onTap: () {},
                  child: const Text('SEE ALL',
                      style: TextStyle(color: AppColors.red, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ]),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: widget.favorites.take(3).map((m) {
                    final isLast = widget.favorites.indexOf(m) == (widget.favorites.take(3).length - 1);
                    return Column(children: [
                      ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(m.posterUrl, width: 44, height: 44, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(width: 44, height: 44, color: AppColors.card)),
                        ),
                        title: Text(m.title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: const Text('Added to Favorites',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        trailing: const Icon(Icons.favorite, color: AppColors.red, size: 16),
                      ),
                      if (!isLast) const Divider(color: AppColors.border, height: 1),
                    ]);
                  }).toList(),
                ),
              ),
            ]),
          ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _defaultAvatar() => Container(
        color: AppColors.surface,
        child: const Icon(Icons.person_rounded, size: 52, color: AppColors.textSecondary),
      );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  const _StatCard({required this.icon, required this.count, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          Icon(icon, color: AppColors.red, size: 24),
          const SizedBox(height: 6),
          Text('$count', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
          Text(label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11,
                  fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        ]),
      );
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? labelColor, iconColor;
  final VoidCallback onTap;
  final Widget? trailing;
  const _SettingTile({required this.icon, required this.label, required this.onTap, this.labelColor, this.iconColor, this.trailing});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: iconColor ?? AppColors.textSecondary, size: 20),
        title: Text(label, style: TextStyle(color: labelColor ?? Colors.white, fontWeight: FontWeight.w600)),
        trailing: trailing ?? (labelColor == null ? const Icon(Icons.chevron_right, color: AppColors.textSecondary) : null),
        onTap: onTap,
      );
}
