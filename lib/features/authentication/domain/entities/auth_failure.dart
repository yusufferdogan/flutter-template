import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_failure.freezed.dart';

@freezed
class AuthFailure with _$AuthFailure {
  const factory AuthFailure.invalidCredentials() = InvalidCredentials;
  const factory AuthFailure.emailAlreadyExists() = EmailAlreadyExists;
  const factory AuthFailure.weakPassword() = WeakPassword;
  const factory AuthFailure.networkError() = NetworkError;
  const factory AuthFailure.serverError(String message) = ServerError;
  const factory AuthFailure.oauthCancelled() = OAuthCancelled;
  const factory AuthFailure.oauthFailed(String message) = OAuthFailed;
  const factory AuthFailure.unknown(String message) = Unknown;
}
