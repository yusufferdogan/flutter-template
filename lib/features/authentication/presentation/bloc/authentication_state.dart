import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';

part 'authentication_state.freezed.dart';

@freezed
class AuthenticationState with _$AuthenticationState {
  const factory AuthenticationState.initial() = Initial;
  const factory AuthenticationState.loading() = Loading;
  const factory AuthenticationState.authenticated(User user) = Authenticated;
  const factory AuthenticationState.unauthenticated() = Unauthenticated;
  const factory AuthenticationState.error(String message) = Error;
  const factory AuthenticationState.passwordResetSent() = PasswordResetSent;
}
