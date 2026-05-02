import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import 'email_verification_screen.dart';
import 'login_screen.dart';
import 'main_shell.dart';

/// Splash — يشوف لو في مستخدم logged in يروح Home، غيره يروح Login
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _progress;
  String _status = 'INITIALIZING IMMERSIVE EXPERIENCE';

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(seconds: 3));
    _progress = Tween<double>(begin: 0, end: 1).animate(_anim);
    _anim.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() => _status = 'LOADING CINEMA DATABASE');

    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() => _status = 'READY');

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // شوف حالة Firebase Auth
    final user = FirebaseAuth.instance.currentUser;

    Widget destination;
    if (user == null) {
      // لازم يسجّل دخول
      destination = const LoginScreen();
    } else if (!user.emailVerified &&
        user.providerData.every((p) => p.providerId != 'google.com')) {
      // الإيميل مش متفعّل (و مش Google)
      destination = const EmailVerificationScreen();
    } else {
      // سبق ودخل وفعّل
      destination = MainShell(firebaseUser: user);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060C14),
      body: SafeArea(
        child: Stack(
          children: [
            CustomPaint(painter: _GridPainter(), child: const SizedBox.expand()),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(color: AppColors.red.withOpacity(0.4), blurRadius: 40, spreadRadius: 5),
                      ],
                    ),
                    child: const Icon(Icons.movie_filter_rounded, color: AppColors.red, size: 48),
                  ),
                  const SizedBox(height: 32),
                  const Text('CINEVERSE',
                      style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: 6)),
                  const SizedBox(height: 8),
                  const Text('YOUR PORTAL TO THE SILVER SCREEN',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 2)),
                ],
              ),
            ),
            Positioned(
              bottom: 48, left: 32, right: 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedBuilder(
                    animation: _progress,
                    builder: (_, __) => LinearProgressIndicator(
                      value: _progress.value,
                      backgroundColor: Colors.white12,
                      color: AppColors.red,
                      minHeight: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    const SizedBox(
                      width: 14, height: 14,
                      child: CircularProgressIndicator(color: AppColors.red, strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    Text(_status,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1.2)),
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

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.03)..strokeWidth = 1;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
