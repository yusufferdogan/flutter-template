sealed class HomeFailure {
  const HomeFailure();

  const factory HomeFailure.network() = NetworkFailure;
  const factory HomeFailure.server(String message) = ServerFailure;
  const factory HomeFailure.cache() = CacheFailure;

  T when<T>({
    required T Function() network,
    required T Function(String message) server,
    required T Function() cache,
  }) {
    final failure = this;
    if (failure is NetworkFailure) {
      return network();
    } else if (failure is ServerFailure) {
      return server(failure.message);
    } else if (failure is CacheFailure) {
      return cache();
    } else {
      throw Exception('Unknown HomeFailure type');
    }
  }

  String toMessage() {
    return when(
      network: () => 'Please check your internet connection',
      server: (message) => message.isEmpty
          ? 'Unable to load content. Please try again'
          : message,
      cache: () => 'Failed to load cached data',
    );
  }
}

class NetworkFailure extends HomeFailure {
  const NetworkFailure();
}

class ServerFailure extends HomeFailure {
  final String message;
  const ServerFailure(this.message);
}

class CacheFailure extends HomeFailure {
  const CacheFailure();
}
