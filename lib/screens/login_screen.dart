import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'email_verification_screen.dart';
import 'register_screen.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _authService = AuthService();

  bool _obscure       = true;
  bool _loading       = false;
  bool _googleLoading = false;
  String? _error;

  // ── Email Login ──────────────────────────────────
  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill all fields.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final user = await _authService.signInWithEmail(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );
      if (!mounted) return;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainShell(firebaseUser: user)),
        );
      }
    } catch (e) {
      final msg = e.toString();
      // لو الإيميل مش متفعّل — سجّل دخول تاني وابعته لشاشة التحقق
      if (msg.contains('verify your email')) {
        try {
          // سجّل دخول عشان نقدر نبعت verification email
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text.trim(),
          );
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
          );
        } catch (_) {
          setState(() { _error = msg; _loading = false; });
        }
      } else {
        setState(() { _error = msg; _loading = false; });
      }
    }
  }

  // ── Google Login ─────────────────────────────────
  Future<void> _googleLogin() async {
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

  // ── Forgot Password ──────────────────────────────
  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email first to reset password.');
      return;
    }
    try {
      // Firebase بيبعت إيميل reset مباشرة
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Password reset email sent! Check your inbox.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _error = 'No account found with this email.';
            break;
          case 'invalid-email':
            _error = 'Please enter a valid email address.';
            break;
          default:
            _error = 'Could not send reset email. Try again.';
        }
      });
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
              // ── Logo ─────────────────────────────
              Center(
                child: Column(children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 28, height: 24,
                      decoration: BoxDecoration(
                          color: AppColors.red, borderRadius: BorderRadius.circular(5)),
                      child: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Text('CINEVERSE',
                        style: TextStyle(color: AppColors.red, fontSize: 26,
                            fontWeight: FontWeight.w900, letterSpacing: 2)),
                  ]),
                  const SizedBox(height: 6),
                  const Text('Experience cinema beyond boundaries',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ]),
              ),
              const SizedBox(height: 32),

              // ── Card ─────────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome Back',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    const Text('SIGN IN TO YOUR ACCOUNT',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11,
                            letterSpacing: 1.2, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 24),

                    // Email
                    AuthField(
                      label: 'EMAIL ADDRESS',
                      hint: 'name@cinema.com',
                      icon: Icons.email_outlined,
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Password header
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('PASSWORD',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11,
                              letterSpacing: 1.2, fontWeight: FontWeight.w700)),
                      GestureDetector(
                        onTap: _forgotPassword,
                        child: const Text('FORGOT PASSWORD?',
                            style: TextStyle(color: AppColors.red, fontSize: 11,
                                fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                      ),
                    ]),
                    const SizedBox(height: 6),

                    // Password field
                    TextField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '••••••••••',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textHint, size: 18),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textHint, size: 18,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),

                    // Error box
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

                    const SizedBox(height: 24),
                    RedButton(label: 'Sign In  →', onTap: _login, loading: _loading),
                    const SizedBox(height: 24),

                    // OR divider
                    Row(children: [
                      const Expanded(child: Divider(color: AppColors.border)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OR CONTINUE WITH',
                            style: TextStyle(color: AppColors.textHint, fontSize: 10, letterSpacing: 1)),
                      ),
                      const Expanded(child: Divider(color: AppColors.border)),
                    ]),
                    const SizedBox(height: 16),

                    // Google Sign-In button
                    _googleLoading
                        ? const Center(
                            child: SizedBox(width: 24, height: 24,
                                child: CircularProgressIndicator(
                                    color: AppColors.red, strokeWidth: 2)))
                        : _SocialBtn(
                            label: 'GOOGLE',
                            icon: Icons.g_mobiledata_rounded,
                            onTap: _googleLogin,
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: RichText(
                  text: const TextSpan(
                    text: 'New to Cineverse? ',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    children: [
                      TextSpan(text: 'Create an account',
                          style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Social Button ────────────────────────────────────
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
            border: Border.all(color: AppColors.border),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}