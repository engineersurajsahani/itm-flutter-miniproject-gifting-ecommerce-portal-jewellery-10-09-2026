import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';

class ConsumerAccount {
  final String fullName;
  final String email;

  ConsumerAccount({required this.fullName, required this.email});
}

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ConsumerAccount? _currentConsumer;
  bool _isAdmin = false;

  // False until Firebase has reported whether a persisted session exists
  // (fires once on startup, restoring any session from a previous page
  // load). Screens that decide "which UI to show" on launch — see
  // AuthGate — must wait for this before reading isAdmin/currentConsumer,
  // otherwise they'd always see the pre-restore "logged out" state.
  bool _isReady = false;

  ConsumerAccount? get currentConsumer => _currentConsumer;
  bool get isAdmin => _isAdmin;
  bool get isLoggedIn => _isAdmin || _currentConsumer != null;
  bool get isReady => _isReady;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _isAdmin = user.email == "admin@aurelia.com";
        _currentConsumer = ConsumerAccount(
          fullName: user.displayName ?? "Sovereign Member",
          email: user.email ?? "",
        );
      } else {
        _currentConsumer = null;
        _isAdmin = false;
      }
      _isReady = true;
      notifyListeners();
    });
  }

  // Throws ApiException with a user-facing message on failure (e.g. email taken).
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential creds = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      await creds.user?.updateDisplayName(fullName.trim());
      
      _isAdmin = email.trim().toLowerCase() == "admin@aurelia.com";
      _currentConsumer = ConsumerAccount(
        fullName: fullName.trim(),
        email: email.trim().toLowerCase(),
      );
      notifyListeners();
    } catch (e) {
      throw ApiException(_mapFirebaseAuthError(e));
    }
  }

  // Throws ApiException with a user-facing message on failure (e.g. invalid credentials).
  Future<void> login({required String email, required String password}) async {
    try {
      UserCredential creds = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final user = creds.user;
      if (user != null) {
        _isAdmin = user.email == "admin@aurelia.com";
        _currentConsumer = ConsumerAccount(
          fullName: user.displayName ?? "Sovereign Member",
          email: user.email ?? "",
        );
      }
      notifyListeners();
    } catch (e) {
      throw ApiException(_mapFirebaseAuthError(e));
    }
  }

  // Throws ApiException with a user-facing message on failure (e.g. popup closed).
  Future<void> signInWithGoogle() async {
    if (!kIsWeb) {
      throw ApiException("Google Sign-In is only available on the web build right now.");
    }
    try {
      final googleProvider = GoogleAuthProvider();
      final creds = await _auth.signInWithPopup(googleProvider);
      final user = creds.user;
      if (user != null) {
        _isAdmin = user.email == "admin@aurelia.com";
        _currentConsumer = ConsumerAccount(
          fullName: user.displayName ?? "Sovereign Member",
          email: user.email ?? "",
        );
      }
      notifyListeners();
    } catch (e) {
      throw ApiException(_mapFirebaseAuthError(e));
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      _currentConsumer = null;
      _isAdmin = false;
      notifyListeners();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  String _mapFirebaseAuthError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No sovereign member found under this credential record.';
        case 'wrong-password':
          return 'Invalid access credentials. Please verify your credentials.';
        case 'email-already-in-use':
          return 'This email credentials record has already been claimed.';
        case 'weak-password':
          return 'The password entered is too weak. Ensure at least 6 characters.';
        case 'invalid-email':
          return 'The email address format is not structured correctly.';
        case 'popup-closed-by-user':
        case 'cancelled-popup-request':
          return 'Sign-in was cancelled before it could complete.';
        case 'account-exists-with-different-credential':
          return 'This email is already registered using a different sign-in method.';
        default:
          return e.message ?? 'An error occurred during vault authentication.';
      }
    }
    return e.toString();
  }
}
