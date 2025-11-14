sealed class AuthFailure {
  const AuthFailure();

  const factory AuthFailure.invalidCredentials() = InvalidCredentials;
  const factory AuthFailure.emailAlreadyExists() = EmailAlreadyExists;
  const factory AuthFailure.weakPassword() = WeakPassword;
  const factory AuthFailure.networkError() = NetworkError;
  const factory AuthFailure.serverError(String message) = ServerError;
  const factory AuthFailure.oauthCancelled() = OAuthCancelled;
  const factory AuthFailure.oauthFailed(String message) = OAuthFailed;
  const factory AuthFailure.unknown(String message) = Unknown;

  T when<T>({
    required T Function() invalidCredentials,
    required T Function() emailAlreadyExists,
    required T Function() weakPassword,
    required T Function() networkError,
    required T Function(String message) serverError,
    required T Function() oauthCancelled,
    required T Function(String message) oauthFailed,
    required T Function(String message) unknown,
  }) {
    final failure = this;
    if (failure is InvalidCredentials) {
      return invalidCredentials();
    } else if (failure is EmailAlreadyExists) {
      return emailAlreadyExists();
    } else if (failure is WeakPassword) {
      return weakPassword();
    } else if (failure is NetworkError) {
      return networkError();
    } else if (failure is ServerError) {
      return serverError(failure.message);
    } else if (failure is OAuthCancelled) {
      return oauthCancelled();
    } else if (failure is OAuthFailed) {
      return oauthFailed(failure.message);
    } else if (failure is Unknown) {
      return unknown(failure.message);
    } else {
      throw Exception('Unknown AuthFailure type');
    }
  }
}

class InvalidCredentials extends AuthFailure {
  const InvalidCredentials();
}

class EmailAlreadyExists extends AuthFailure {
  const EmailAlreadyExists();
}

class WeakPassword extends AuthFailure {
  const WeakPassword();
}

class NetworkError extends AuthFailure {
  const NetworkError();
}

class ServerError extends AuthFailure {
  final String message;
  const ServerError(this.message);
}

class OAuthCancelled extends AuthFailure {
  const OAuthCancelled();
}

class OAuthFailed extends AuthFailure {
  final String message;
  const OAuthFailed(this.message);
}

class Unknown extends AuthFailure {
  final String message;
  const Unknown(this.message);
}
