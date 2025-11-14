import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object?> get props => [];
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

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthenticationState {
  const Unauthenticated();
}

class Error extends AuthenticationState {
  final String message;
  const Error(this.message);

  @override
  List<Object?> get props => [message];
}

class PasswordResetSent extends AuthenticationState {
  const PasswordResetSent();
}
