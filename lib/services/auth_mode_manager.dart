import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'guest_session_service.dart';
import 'local_storage_service.dart';

enum AuthMode { loggedIn, guest, none }

class AppUser {
  final String id;
  final bool isGuest;
  final String? email;
  final String? name;

  const AppUser({
    required this.id,
    required this.isGuest,
    this.email,
    this.name,
  });
}

class AuthModeManager extends ChangeNotifier {
  final Logger _logger = Logger();
  final AuthService _authService = AuthService();
  final GuestSessionService _guestSessionService = GuestSessionService();
  final LocalStorageService _localStorageService = LocalStorageService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthMode _mode = AuthMode.none;
  AppUser? _user;
  bool _initialized = false;

  AuthMode get mode => _mode;
  AppUser? get user => _user;
  bool get initialized => _initialized;
  bool get isLoggedIn => _mode == AuthMode.loggedIn;
  bool get isGuest => _mode == AuthMode.guest;

  AuthService get authService => _authService;
  LocalStorageService get localStorage => _localStorageService;

  Future<void> initialize() async {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        if (!_initialized) {
          _setLoggedIn(firebaseUser);
        }
        return;
      }
      final hasGuest = await _guestSessionService.hasSession();
      if (hasGuest) {
        final guestId = await _guestSessionService.getOrCreateSession();
        _user = AppUser(id: guestId, isGuest: true);
        _mode = AuthMode.guest;
      } else {
        _user = null;
        _mode = AuthMode.none;
      }
      _initialized = true;
      notifyListeners();
    });
  }

  Future<void> _ensureUserProfile(auth.User firebaseUser) async {
    final docRef = _firestore.collection('users').doc(firebaseUser.uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'uid': firebaseUser.uid,
        'displayName': firebaseUser.displayName ?? '',
        'email': firebaseUser.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.update({'lastLogin': FieldValue.serverTimestamp()});
    }
  }

  Future<void> startGuestSession() async {
    final guestId = await _guestSessionService.getOrCreateSession();
    _user = AppUser(id: guestId, isGuest: true);
    _mode = AuthMode.guest;
    _logger.w('→ HomeScreen (guest session started)');
    notifyListeners();
  }

  void _setLoggedIn(auth.User firebaseUser) {
    _user = AppUser(
      id: firebaseUser.uid,
      isGuest: firebaseUser.isAnonymous,
      email: firebaseUser.email,
      name: firebaseUser.displayName,
    );
    _mode = AuthMode.loggedIn;
    _initialized = true;
    notifyListeners();
    _logger.w('User logged in: ${firebaseUser.email ?? firebaseUser.uid}');
    _ensureUserProfile(firebaseUser).catchError((e) {
      _logger.e('Failed to ensure user profile: $e');
    });
  }

  Future<String?> signInWithEmail(String email, String password) async {
    try {
      final cred = await _authService.signInWithEmail(email, password);
      _setLoggedIn(cred.user!);
      return null;
    } on auth.FirebaseAuthException catch (e) {
      return e.message ?? 'Sign in failed';
    }
  }

  Future<String?> registerWithEmail(String email, String password) async {
    try {
      final cred = await _authService.registerWithEmail(email, password);
      _setLoggedIn(cred.user!);
      return null;
    } on auth.FirebaseAuthException catch (e) {
      return e.message ?? 'Registration failed';
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) return 'Google sign-in cancelled';
      _setLoggedIn(result.user!);
      return null;
    } on auth.FirebaseAuthException catch (e) {
      return e.message ?? 'Google sign-in failed';
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    await _guestSessionService.clearSession();
    _mode = AuthMode.none;
    _user = null;
    _logger.w('→ OnboardingScreen (signed out)');
    notifyListeners();
  }
}
