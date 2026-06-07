sealed class AuthEvent {}

final class AuthInitialize extends AuthEvent {}

final class AuthStartGuestSession extends AuthEvent {}

final class AuthSignInWithEmail extends AuthEvent {
  final String email;
  final String password;
  AuthSignInWithEmail({required this.email, required this.password});
}

final class AuthRegisterWithEmail extends AuthEvent {
  final String email;
  final String password;
  AuthRegisterWithEmail({required this.email, required this.password});
}

final class AuthSignInWithGoogle extends AuthEvent {}

final class AuthSignOut extends AuthEvent {}

final class AuthUpdateDisplayName extends AuthEvent {
  final String name;
  AuthUpdateDisplayName({required this.name});
}

final class AuthUpdatePassword extends AuthEvent {
  final String currentPassword;
  final String newPassword;
  AuthUpdatePassword({required this.currentPassword, required this.newPassword});
}

final class AuthUpdateAvatarColor extends AuthEvent {
  final int colorIndex;
  AuthUpdateAvatarColor({required this.colorIndex});
}

final class AuthGetAvatarColor extends AuthEvent {}

final class AuthClearError extends AuthEvent {}
