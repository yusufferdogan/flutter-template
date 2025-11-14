import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
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

  @override
  List<Object?> get props => [fullName, email, password];
}

class SignInRequested extends AuthenticationEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
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

  @override
  List<Object?> get props => [email];
}

class AuthStateChanged extends AuthenticationEvent {
  final User? user;

  const AuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class CheckAuthStatus extends AuthenticationEvent {
  const CheckAuthStatus();
}
