import '../../domain/entities/user.dart';

sealed class AuthenticationEvent {
  const AuthenticationEvent();

  const factory AuthenticationEvent.signUpRequested({
    required String fullName,
    required String email,
    required String password,
  }) = SignUpRequested;

  const factory AuthenticationEvent.signInRequested({
    required String email,
    required String password,
  }) = SignInRequested;

  const factory AuthenticationEvent.signInWithGoogleRequested() =
      SignInWithGoogleRequested;

  const factory AuthenticationEvent.signInWithAppleRequested() =
      SignInWithAppleRequested;

  const factory AuthenticationEvent.signOutRequested() = SignOutRequested;

  const factory AuthenticationEvent.resetPasswordRequested(String email) =
      ResetPasswordRequested;

  const factory AuthenticationEvent.authStateChanged(User? user) =
      AuthStateChanged;

  const factory AuthenticationEvent.checkAuthStatus() = CheckAuthStatus;
}

class SignUpRequested extends AuthenticationEvent {
  final String fullName;
  final String email;
  final String password;

  const SignUpRequested({
    required this.fullName,
    required this.email,
    required this.password,
  });
}

class SignInRequested extends AuthenticationEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password,
  });
}

class SignInWithGoogleRequested extends AuthenticationEvent {
  const SignInWithGoogleRequested();
}

class SignInWithAppleRequested extends AuthenticationEvent {
  const SignInWithAppleRequested();
}

class SignOutRequested extends AuthenticationEvent {
  const SignOutRequested();
}

class ResetPasswordRequested extends AuthenticationEvent {
  final String email;

  const ResetPasswordRequested(this.email);
}

class AuthStateChanged extends AuthenticationEvent {
  final User? user;

  const AuthStateChanged(this.user);
}

class CheckAuthStatus extends AuthenticationEvent {
  const CheckAuthStatus();
}
