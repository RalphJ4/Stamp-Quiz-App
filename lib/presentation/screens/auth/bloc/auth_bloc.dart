// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:math';
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/guest_session_service.dart';
import '../../../../services/local_storage_service.dart';
import '../../../../services/notification_service.dart';
export 'auth_event.dart';
export 'auth_state.dart';
import 'auth_event.dart';
import 'auth_state.dart';

String _friendlyAuthError(auth.FirebaseAuthException e) {
  switch (e.code) {
    case 'email-already-in-use':
      return 'This email is already registered. Try signing in instead.';
    case 'invalid-email':
      return 'Please enter a valid email address.';
    case 'user-not-found':
      return 'No account found with this email. Please register first.';
    case 'wrong-password':
      return 'Incorrect password. Please try again.';
    case 'weak-password':
      return 'Password should be at least 6 characters.';
    case 'invalid-credential':
      return 'Invalid email or password. Please try again.';
    case 'user-disabled':
      return 'This account has been disabled. Contact support.';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later.';
    case 'operation-not-allowed':
      return 'This sign-in method is not enabled. Contact support.';
    case 'account-exists-with-different-credential':
      return 'An account already exists with this email using a different sign-in method.';
    case 'requires-recent-login':
      return 'Please sign out and sign in again before retrying.';
    case 'network-request-failed':
      return 'No internet connection. Please check your network and try again.';
    case 'invalid-action-code':
      return 'The link you used is invalid or expired.';
    case 'expired-action-code':
      return 'The link you used has expired.';
    case 'invalid-verification-code':
      return 'The verification code is invalid.';
    case 'invalid-verification-id':
      return 'The verification ID is invalid.';
    case 'provider-already-linked':
      return 'This sign-in method is already connected to your account.';
    case 'credential-already-in-use':
      return 'This login is already being used by another account.';
    default:
      return 'Something went wrong. Please try again.';
  }
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Logger _logger = Logger();
  final AuthService _authService = AuthService();
  final GuestSessionService _guestSessionService = GuestSessionService();
  final LocalStorageService _localStorageService = LocalStorageService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthBloc({bool skipInit = false}) : super(const AuthState()) {
    on<AuthInitialize>(_onInitialize);
    on<AuthStartGuestSession>(_onStartGuestSession);
    on<AuthSignInWithEmail>(_onSignInWithEmail);
    on<AuthRegisterWithEmail>(_onRegisterWithEmail);
    on<AuthSignInWithGoogle>(_onSignInWithGoogle);
    on<AuthSignOut>(_onSignOut);
    on<AuthUpdateDisplayName>(_onUpdateDisplayName);
    on<AuthUpdatePassword>(_onUpdatePassword);
    on<AuthUpdateAvatarColor>(_onUpdateAvatarColor);
    on<AuthGetAvatarColor>(_onGetAvatarColor);
    on<AuthClearError>(_onClearError);
    on<AuthClearSuccess>(_onClearSuccess);
    if (!skipInit) {
      _init();
    }
  }

  AuthService get authService => _authService;
  LocalStorageService get localStorage => _localStorageService;
  bool get canChangePassword => state.mode == AuthMode.loggedIn
      && _authService.currentUser?.email != null
      && _authService.currentUser?.providerData.any((p) => p.providerId == 'password') == true;

  void _init() {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        if (!state.initialized) {
          _setLoggedIn(firebaseUser);
        }
        return;
      }
      if (state.initialized) return;
      final hasGuest = await _guestSessionService.hasSession();
      if (hasGuest) {
        final guestId = await _guestSessionService.getOrCreateSession();
        emit(state.copyWith(
          user: AppUser(id: guestId, isGuest: true),
          mode: AuthMode.guest,
          initialized: true,
        ));
      } else {
        emit(state.copyWith(
          user: null,
          mode: AuthMode.none,
          initialized: true,
        ));
      }
    });
  }

  void _onInitialize(AuthInitialize event, Emitter<AuthState> emit) {}

  void _onStartGuestSession(AuthStartGuestSession event, Emitter<AuthState> emit) async {
    final guestId = await _guestSessionService.getOrCreateSession();
    emit(state.copyWith(
      user: AppUser(id: guestId, isGuest: true),
      mode: AuthMode.guest,
    ));
    _logger.w('→ HomeScreen (guest session started)');
  }

  Future<void> _ensureUserProfile(auth.User firebaseUser) async {
    final docRef = _firestore.collection('users').doc(firebaseUser.uid);
    final doc = await docRef.get();
    final fcmToken = NotificationService.currentToken;
    if (!doc.exists) {
      await docRef.set({
        'uid': firebaseUser.uid,
        'displayName': firebaseUser.displayName ?? '',
        'email': firebaseUser.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        if (fcmToken != null) 'fcmToken': fcmToken,
      });
    } else {
      await docRef.update({
        'lastLogin': FieldValue.serverTimestamp(),
        if (fcmToken != null) 'fcmToken': fcmToken,
      });
    }
  }

  void _setLoggedIn(auth.User firebaseUser) {
    emit(state.copyWith(
      user: AppUser(
        id: firebaseUser.uid,
        isGuest: firebaseUser.isAnonymous,
        email: firebaseUser.email,
        name: firebaseUser.displayName,
      ),
      mode: AuthMode.loggedIn,
      initialized: true,
    ));
    _logger.w('User logged in: ${firebaseUser.email ?? firebaseUser.uid}');
    _ensureUserProfile(firebaseUser).catchError((e) {
      _logger.e('Failed to ensure user profile: $e');
    });
    _migrateGuestData(firebaseUser.uid);
    _loadAvatarIndex();
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
      if (idx != state.avatarIndex) {
        emit(state.copyWith(avatarIndex: idx.clamp(0, 7)));
      }
    } catch (_) {}
  }

  void _onClearError(AuthClearError event, Emitter<AuthState> emit) {
    emit(state.copyWith(clearError: true));
  }

  void _onClearSuccess(AuthClearSuccess event, Emitter<AuthState> emit) {
    emit(state.copyWith(passwordUpdateSuccess: false));
  }

  void _onSignInWithEmail(AuthSignInWithEmail event, Emitter<AuthState> emit) async {
    emit(state.copyWith(clearError: true));
    if (event.email.trim().isEmpty) {
      emit(state.copyWith(error: 'Please enter your email address.'));
      return;
    }
    if (event.password.trim().isEmpty) {
      emit(state.copyWith(error: 'Please enter your password.'));
      return;
    }
    try {
      final cred = await _authService.signInWithEmail(event.email, event.password);
      _setLoggedIn(cred.user!);
    } on auth.FirebaseAuthException catch (e) {
      emit(state.copyWith(error: _friendlyAuthError(e)));
    } catch (e) {
      emit(state.copyWith(error: 'Something went wrong. Please try again.'));
    }
  }

  void _onRegisterWithEmail(AuthRegisterWithEmail event, Emitter<AuthState> emit) async {
    emit(state.copyWith(clearError: true));
    if (event.email.trim().isEmpty) {
      emit(state.copyWith(error: 'Please enter your email address.'));
      return;
    }
    if (event.password.trim().isEmpty) {
      emit(state.copyWith(error: 'Please enter a password.'));
      return;
    }
    try {
      final cred = await _authService.registerWithEmail(event.email, event.password);
      _setLoggedIn(cred.user!);
    } on auth.FirebaseAuthException catch (e) {
      emit(state.copyWith(error: _friendlyAuthError(e)));
    } catch (_) {
      emit(state.copyWith(error: 'Something went wrong. Please try again.'));
    }
  }

  void _onSignInWithGoogle(AuthSignInWithGoogle event, Emitter<AuthState> emit) async {
    emit(state.copyWith(clearError: true));
    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) {
        emit(state.copyWith(error: 'Google sign-in cancelled'));
        return;
      }
      _setLoggedIn(result.user!);
    } on auth.FirebaseAuthException catch (e) {
      emit(state.copyWith(error: _friendlyAuthError(e)));
    } catch (_) {
      emit(state.copyWith(error: 'Something went wrong. Please try again.'));
    }
  }

  void _onSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    await _authService.signOut();
    if (!state.isGuest) {
      await _guestSessionService.clearSession();
    }
    emit(const AuthState(mode: AuthMode.none, initialized: true));
    _logger.w('→ OnboardingScreen (signed out)');
  }

  void _onUpdateDisplayName(AuthUpdateDisplayName event, Emitter<AuthState> emit) async {
    if (state.mode != AuthMode.loggedIn) return;
    try {
      await _authService.updateDisplayName(event.name);
      final user = state.user;
      if (user != null) {
        emit(state.copyWith(
          user: AppUser(id: user.id, isGuest: false, email: user.email, name: event.name),
        ));
      }
      final uid = _authService.currentUser?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).update({'displayName': event.name});
      }
    } catch (e) {
      _logger.e(e.toString());
    }
  }

  void _onUpdatePassword(AuthUpdatePassword event, Emitter<AuthState> emit) async {
    if (state.mode != AuthMode.loggedIn) return;
    emit(state.copyWith(clearError: true));
    try {
      await _authService.reauthenticate(event.currentPassword);
      await _authService.updatePassword(event.newPassword);
      emit(state.copyWith(passwordUpdateSuccess: true));
    } on auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          emit(state.copyWith(error: 'Current password is incorrect.'));
          break;
        case 'weak-password':
          emit(state.copyWith(error: 'New password is too weak. Use at least 6 characters.'));
          break;
        case 'requires-recent-login':
          emit(state.copyWith(error: 'Please sign out and sign in again, then retry.'));
          break;
        case 'too-many-requests':
          emit(state.copyWith(error: 'Too many attempts. Please try again later.'));
          break;
        case 'network-request-failed':
          emit(state.copyWith(error: 'No internet connection. Check your network.'));
          break;
        default:
          emit(state.copyWith(error: _friendlyAuthError(e)));
      }
    } catch (e) {
      _logger.e(e.toString());
      emit(state.copyWith(error: 'Something went wrong. Please try again.'));
    }
  }

  void _onUpdateAvatarColor(AuthUpdateAvatarColor event, Emitter<AuthState> emit) async {
    if (state.mode != AuthMode.loggedIn) return;
    try {
      final uid = _authService.currentUser?.uid;
      if (uid == null) return;
      await _firestore.collection('users').doc(uid).update({'avatarColor': event.colorIndex});
      emit(state.copyWith(avatarIndex: event.colorIndex.clamp(0, 7)));
    } catch (e) {
      _logger.e(e.toString());
    }
  }

  void _onGetAvatarColor(AuthGetAvatarColor event, Emitter<AuthState> emit) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final idx = (doc.data()?['avatarColor'] as int?) ?? 0;
      if (idx != state.avatarIndex) {
        emit(state.copyWith(avatarIndex: idx.clamp(0, 7)));
      }
    } catch (_) {}
  }
}
