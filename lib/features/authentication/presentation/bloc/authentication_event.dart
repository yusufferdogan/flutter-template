import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';

part 'authentication_event.freezed.dart';

@freezed
class AuthenticationEvent with _$AuthenticationEvent {
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
