import 'package:equatable/equatable.dart';

enum AuthMode { loggedIn, guest, none }

class AppUser extends Equatable {
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

  @override
  List<Object?> get props => [id, isGuest, email, name];
}

class AuthState extends Equatable {
  final AuthMode mode;
  final AppUser? user;
  final bool initialized;
  final int avatarIndex;
  final String? error;
  final bool passwordUpdateSuccess;
  final bool passwordResetSent;

  const AuthState({
    this.mode = AuthMode.none,
    this.user,
    this.initialized = false,
    this.avatarIndex = 0,
    this.error,
    this.passwordUpdateSuccess = false,
    this.passwordResetSent = false,
  });

  bool get isLoggedIn => mode == AuthMode.loggedIn;
  bool get isGuest => mode == AuthMode.guest;

  AuthState copyWith({
    AuthMode? mode,
    AppUser? user,
    bool? initialized,
    int? avatarIndex,
    String? error,
    bool clearError = false,
    bool? passwordUpdateSuccess,
    bool? passwordResetSent,
  }) {
    return AuthState(
      mode: mode ?? this.mode,
      user: user ?? this.user,
      initialized: initialized ?? this.initialized,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      error: clearError ? null : (error ?? this.error),
      passwordUpdateSuccess: passwordUpdateSuccess ?? this.passwordUpdateSuccess,
      passwordResetSent: passwordResetSent ?? this.passwordResetSent,
    );
  }

  @override
  List<Object?> get props =>
      [mode, user, initialized, avatarIndex, error, passwordUpdateSuccess, passwordResetSent];
}
