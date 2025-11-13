import '../../domain/entities/user.dart';

sealed class AuthenticationState {
  const AuthenticationState();

  const factory AuthenticationState.initial() = Initial;
  const factory AuthenticationState.loading() = Loading;
  const factory AuthenticationState.authenticated(User user) = Authenticated;
  const factory AuthenticationState.unauthenticated() = Unauthenticated;
  const factory AuthenticationState.error(String message) = Error;
  const factory AuthenticationState.passwordResetSent() = PasswordResetSent;
}

class Initial extends AuthenticationState {
  const Initial();
}

class Loading extends AuthenticationState {
  const Loading();
}

class Authenticated extends AuthenticationState {
  final User user;
  const Authenticated(this.user);
}

class Unauthenticated extends AuthenticationState {
  const Unauthenticated();
}

class Error extends AuthenticationState {
  final String message;
  const Error(this.message);
}

class PasswordResetSent extends AuthenticationState {
  const PasswordResetSent();
}
