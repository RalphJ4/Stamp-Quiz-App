import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  int _avatarIndex = 0;

  AuthMode get mode => _mode;
  AppUser? get user => _user;
  bool get initialized => _initialized;
  bool get isLoggedIn => _mode == AuthMode.loggedIn;
  bool get isGuest => _mode == AuthMode.guest;
  int get avatarIndex => _avatarIndex;

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
      if (_initialized) return;
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
    _loadAvatarIndex();
    notifyListeners();
    _logger.w('User logged in: ${firebaseUser.email ?? firebaseUser.uid}');
    _ensureUserProfile(firebaseUser).catchError((e) {
      _logger.e('Failed to ensure user profile: $e');
    });
    _migrateGuestData(firebaseUser.uid);
  }

  Future<void> _migrateGuestData(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final guestId = prefs.getString('guest_session_id');
      if (guestId == null || guestId.isEmpty) return;
      final prefix = 'guest_$guestId';
      final oldStamps = prefs.getInt('${prefix}_stamps') ?? 0;
      if (oldStamps <= 0) return;
      final oldBestStreak = prefs.getInt('${prefix}_bestStreak') ?? 0;
      final oldTotalCorrect = prefs.getInt('${prefix}_totalCorrect') ?? 0;
      final oldTotalAnswered = prefs.getInt('${prefix}_totalAnswered') ?? 0;
      final docRef = _firestore.collection('users').doc(uid);
      await _firestore.runTransaction((tx) async {
        final doc = await tx.get(docRef);
        final existing = doc.data() ?? {};
        final mergedStamps = max(oldStamps, (existing['stamps'] as num?)?.toInt() ?? 0);
        final mergedBestStreak = max(oldBestStreak, (existing['bestStreak'] as num?)?.toInt() ?? 0);
        final mergedTotalCorrect = max(oldTotalCorrect, (existing['totalCorrect'] as num?)?.toInt() ?? 0);
        final mergedTotalAnswered = max(oldTotalAnswered, (existing['totalAnswered'] as num?)?.toInt() ?? 0);
        tx.set(docRef, {
          'stamps': mergedStamps,
          'bestStreak': mergedBestStreak,
          'totalCorrect': mergedTotalCorrect,
          'totalAnswered': mergedTotalAnswered,
        }, SetOptions(merge: true));
      });
      await prefs.remove('${prefix}_stamps');
      await prefs.remove('${prefix}_bestStreak');
      await prefs.remove('${prefix}_totalCorrect');
      await prefs.remove('${prefix}_totalAnswered');
      _logger.i('Migrated guest stats to Firestore user $uid');
    } catch (e) {
      _logger.e('Failed to migrate guest data: $e');
    }
  }

  Future<void> _loadAvatarIndex() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final idx = (doc.data()?['avatarColor'] as int?) ?? 0;
      if (idx != _avatarIndex) {
        _avatarIndex = idx.clamp(0, 7);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<String?> signInWithEmail(String email, String password) async {
    try {
      final cred = await _authService.signInWithEmail(email, password);
      _setLoggedIn(cred.user!);
      return null;
    } on auth.FirebaseAuthException catch (e) {
      return e.message ?? 'Sign in failed';
    } catch (e) {
      return 'Sign in failed: $e';
    }
  }

  Future<String?> registerWithEmail(String email, String password) async {
    try {
      final cred = await _authService.registerWithEmail(email, password);
      _setLoggedIn(cred.user!);
      return null;
    } on auth.FirebaseAuthException catch (e) {
      return e.message ?? 'Registration failed';
    } catch (e) {
      return 'Registration failed: $e';
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
    } catch (e) {
      return 'Google sign-in failed: $e';
    }
  }

  Future<String?> updateDisplayName(String name) async {
    if (_mode != AuthMode.loggedIn) return 'Only logged-in users can change name';
    try {
      await _authService.updateDisplayName(name);
      _user = AppUser(
        id: _user!.id,
        isGuest: false,
        email: _user!.email,
        name: name,
      );
      final uid = _authService.currentUser?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).update({'displayName': name});
      }
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updatePassword(String currentPassword, String newPassword) async {
    if (_mode != AuthMode.loggedIn) return 'Only logged-in users can change password';
    try {
      await _authService.reauthenticate(currentPassword);
      await _authService.updatePassword(newPassword);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateAvatarColor(int colorIndex) async {
    if (_mode != AuthMode.loggedIn) return 'Only logged-in users can change avatar';
    try {
      final uid = _authService.currentUser?.uid;
      if (uid == null) return 'Not authenticated';
      await _firestore.collection('users').doc(uid).update({'avatarColor': colorIndex});
      _avatarIndex = colorIndex.clamp(0, 7);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<int> getAvatarColor() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return 0;
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return (doc.data()?['avatarColor'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<String?> getDisplayName() async {
    if (_mode != AuthMode.loggedIn) return null;
    return _user?.name;
  }

  bool get canChangePassword => _mode == AuthMode.loggedIn
      && _authService.currentUser?.email != null
      && _authService.currentUser?.providerData.any((p) => p.providerId == 'password') == true;

  Future<void> signOut() async {
    await _authService.signOut();
    await _guestSessionService.clearSession();
    _mode = AuthMode.none;
    _user = null;
    _logger.w('→ OnboardingScreen (signed out)');
    notifyListeners();
  }
}
