import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'email_verification_screen.dart';
import 'main_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  bool _googleLoading = false;
  String? _error;

  Future<void> _register() async {
    // Validation
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill all fields.');
      return;
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    if (_passCtrl.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      final user = await _authService.registerWithEmail(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      if (!mounted) return;
      if (user != null) {
        // انتقل لشاشة التحقق من الإيميل
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
        );
      }
    } catch (e) {
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  // ── Google Sign-In ─────────────────────────────────
  Future<void> _googleSignIn() async {
    setState(() { _googleLoading = true; _error = null; });
    try {
      final user = await _authService.signInWithGoogle();
      if (!mounted) return;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainShell(firebaseUser: user)),
        );
      } else {
        setState(() => _googleLoading = false);
      }
    } catch (e) {
      setState(() { _error = e.toString(); _googleLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Logo
              Center(
                child: Column(children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 28, height: 24,
                      decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(5)),
                      child: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Text('CINEVERSE',
                        style: TextStyle(color: AppColors.red, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  ]),
                  const SizedBox(height: 6),
                  const Text('UNLOCK A UNIVERSE OF CINEMA',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1.5)),
                ]),
              ),
              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Create Account',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 20),

                    AuthField(label: 'NAME', hint: 'John Doe', icon: Icons.person_outline, controller: _nameCtrl),
                    const SizedBox(height: 14),
                    AuthField(label: 'EMAIL ADDRESS', hint: 'email@example.com',
                        icon: Icons.email_outlined, controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    AuthField(label: 'PASSWORD', hint: '••••••••',
                        icon: Icons.lock_outline, controller: _passCtrl, obscure: true),
                    const SizedBox(height: 14),
                    AuthField(label: 'CONFIRM PASSWORD', hint: '••••••••',
                        icon: Icons.shield_outlined, controller: _confirmCtrl, obscure: true),

                    // Error
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.red.withOpacity(0.3)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.error_outline, color: AppColors.red, size: 14),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_error!,
                              style: const TextStyle(color: AppColors.red, fontSize: 12))),
                        ]),
                      ),
                    ],

                    const SizedBox(height: 22),
                    RedButton(label: 'Register  →', onTap: _register, loading: _loading),
                    const SizedBox(height: 18),

                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Already have an account?',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text('Switch to Login',
                            style: TextStyle(color: AppColors.red, fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                    ]),
                    const SizedBox(height: 18),

                    Row(children: [
                      const Expanded(child: Divider(color: AppColors.border)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OR JOIN WITH',
                            style: TextStyle(color: AppColors.textHint, fontSize: 10, letterSpacing: 1)),
                      ),
                      const Expanded(child: Divider(color: AppColors.border)),
                    ]),
                    const SizedBox(height: 14),
                    // Google Sign-In button
                    _googleLoading
                        ? const Center(
                            child: SizedBox(width: 24, height: 24,
                                child: CircularProgressIndicator(
                                    color: AppColors.red, strokeWidth: 2)))
                        : _SocialBtn(
                            label: 'GOOGLE',
                            icon: Icons.g_mobiledata_rounded,
                            onTap: _googleSignIn,
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'By registering, you agree to our Terms of Service and\nPrivacy Policy. Enjoy the CINEVERSE experience.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textHint, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _SocialBtn({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}
