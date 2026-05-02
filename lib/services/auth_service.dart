import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// AuthService — كل العمليات بتاعة المستخدمين عن طريق Firebase
class AuthService {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '739346128775-oj6r57at8434k5si1cbtjasks3hrckln.apps.googleusercontent.com',
    serverClientId:
        '739346128775-oj6r57at8434k5si1cbtjasks3hrckln.apps.googleusercontent.com',
  );

  // ── الحصول على المستخدم الحالي ──────────────────
  User? get currentUser => _auth.currentUser;

  // ── Stream لمتابعة حالة تسجيل الدخول ────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ═══════════════════════════════════════════════
  //  EMAIL & PASSWORD
  // ═══════════════════════════════════════════════

  /// تسجيل دخول بالإيميل والباسورد
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = result.user;
      // ── تحقق من أن الإيميل مفعّل ──
      if (user != null && !user.emailVerified) {
        await _auth.signOut();
        throw 'Please verify your email first. Check your inbox.';
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// إنشاء حساب جديد بالإيميل والباسورد
  Future<User?> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = result.user;
      if (user != null) {
        // حدّث الاسم في Firebase Auth
        await user.updateDisplayName(name.trim());

        // ابعت إيميل التحقق
        await user.sendEmailVerification();

        // احفظ بيانات المستخدم في Firestore
        await _saveUserToFirestore(user, name: name.trim());
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ═══════════════════════════════════════════════
  //  GOOGLE SIGN IN
  // ═══════════════════════════════════════════════

  /// تسجيل دخول بـ Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // المستخدم ألغى

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      final user = result.user;

      if (user != null) {
        // احفظ في Firestore لو أول مرة
        await _saveUserToFirestore(user);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Google Sign-In failed. Please try again.';
    }
  }

  // ═══════════════════════════════════════════════
  //  FIRESTORE — CRUD USERS
  // ═══════════════════════════════════════════════

  /// احفظ أو حدّث بيانات المستخدم في Firestore
  Future<void> _saveUserToFirestore(User user, {String? name}) async {
    final docRef = _db.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      // إنشاء جديد
      await docRef.set({
        'uid': user.uid,
        'name': name ?? user.displayName ?? 'User',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'favorites': 0,
        'watchlist': 0,
      });
    }
  }

  /// جيب كل المستخدمين من Firestore (للـ Dashboard)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final snapshot = await _db.collection('users').get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  /// تحديث بيانات مستخدم
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  /// حذف مستخدم من Firestore (الـ Dashboard)
  Future<void> deleteUserFromFirestore(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  /// جيب بيانات المستخدم الحالي من Firestore
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.exists ? {'id': doc.id, ...doc.data()!} : null;
  }

  // ═══════════════════════════════════════════════
  //  EMAIL VERIFICATION
  // ═══════════════════════════════════════════════

  /// إعادة إرسال إيميل التحقق
  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// تحقق لو الإيميل اتفعّل (بعد reload)
  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // ═══════════════════════════════════════════════
  //  LOGOUT
  // ═══════════════════════════════════════════════
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // المستخدم ممكن مكانش سجّل بـ Google — عادي
    }
    await _auth.signOut();
  }

  // ═══════════════════════════════════════════════
  //  ERROR HANDLING
  // ═══════════════════════════════════════════════
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}
