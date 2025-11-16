import 'package:filmku/features/bookmarks/data/datasource/local/bookmark_local_datasource.dart';
import 'package:filmku/features/bookmarks/data/datasource/local/bookmark_local_datasource_impl.dart';
import 'package:filmku/features/bookmarks/domain/repositories/bookmark_repository.dart';
import 'package:filmku/features/bookmarks/data/repositories/bookmark_repository_impl.dart';
import 'package:filmku/features/bookmarks/domain/use_cases/get_bookmarks_use_case.dart';
import 'package:filmku/features/home/data/datasource/local/home_local_datasource.dart';
import 'package:filmku/features/home/data/datasource/local/home_local_datasource_impl.dart';
import 'package:filmku/features/home/data/datasource/remote/home_remote_data_source.dart';
import 'package:filmku/features/home/data/datasource/remote/home_remote_datasource.dart';
import 'package:filmku/features/home/domain/repositories/home_repository.dart';
import 'package:filmku/features/home/data/repositories/home_repository_impl.dart';
import 'package:filmku/features/home/domain/use_cases/fetch_and_cache_genre_use_case.dart';
import 'package:filmku/features/home/domain/use_cases/fetch_and_cache_movies_use_case.dart';
import 'package:filmku/features/home/domain/use_cases/fetch_cached_genre_use_case.dart';
import 'package:filmku/features/home/domain/use_cases/fetch_cached_movies_use_case.dart';
import 'package:filmku/features/movie_detail/data/datasource/local/movie_detail_local_datasource.dart';
import 'package:filmku/features/movie_detail/data/datasource/local/movie_detail_local_datasource_impl.dart';
import 'package:filmku/features/movie_detail/data/datasource/remote/movie_detail_remote_data_source.dart';
import 'package:filmku/features/movie_detail/data/datasource/remote/movie_detail_remote_datasource.dart';
import 'package:filmku/features/movie_detail/domain/repositories/movie_detail_repository.dart';
import 'package:filmku/features/movie_detail/data/repositories//movie_detail_repository_impl.dart';
import 'package:filmku/features/movie_detail/domain/use_cases/add_bookmark_use_case.dart';
import 'package:filmku/features/movie_detail/domain/use_cases/get_casts_use_case.dart';
import 'package:filmku/features/movie_detail/domain/use_cases/get_movie_details_use_case.dart';
import 'package:filmku/features/movie_detail/domain/use_cases/get_videos_use_case.dart';
import 'package:filmku/features/movie_detail/domain/use_cases/is_bookmark_use_case.dart';
import 'package:filmku/features/movie_detail/domain/use_cases/remove_bookmark_use_case.dart';
import 'package:filmku/features/notifications/data/datasource/local/notifications_local_datasource.dart';
import 'package:filmku/features/notifications/data/datasource/local/notifications_local_datasource_impl.dart';
import 'package:filmku/features/notifications/domain/repository/notifications_repository.dart';
import 'package:filmku/features/notifications/data/repository/notifications_repository_impl.dart';
import 'package:filmku/features/notifications/domain/use_cases/clear_all_notifications_use_case.dart';
import 'package:filmku/features/notifications/domain/use_cases/get_all_notifications_use_case.dart';
import 'package:filmku/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:filmku/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:filmku/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:filmku/features/authentication/domain/repositories/auth_repository.dart';
import 'package:filmku/features/authentication/domain/usecases/sign_up_usecase.dart';
import 'package:filmku/features/authentication/domain/usecases/sign_in_usecase.dart';
import 'package:filmku/features/authentication/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:filmku/features/authentication/domain/usecases/sign_in_with_apple_usecase.dart';
import 'package:filmku/features/authentication/domain/usecases/sign_out_usecase.dart';
import 'package:filmku/features/authentication/domain/usecases/reset_password_usecase.dart';
import 'package:filmku/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:filmku/shared/local/cache/local_db.dart';
import 'package:filmku/shared/local/cache/local_db_impl.dart';
import 'package:filmku/shared/local/shared_prefs/shared_pref.dart';
import 'package:filmku/shared/local/shared_prefs/shared_pref_impl.dart';
import 'package:filmku/shared/network/dio_network_service.dart';
import 'package:filmku/shared/network/network_service.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final injector = GetIt.instance;

Future<void> initSingletons() async {
  //Services
  injector.registerLazySingleton<LocalDb>(() => InitDbImpl());
  injector.registerLazySingleton<NetworkService>(() => DioNetworkService());
  injector.registerLazySingleton<SharedPref>(() => SharedPrefImplementation());

  //Authentication services
  injector.registerLazySingleton<firebase_auth.FirebaseAuth>(
      () => firebase_auth.FirebaseAuth.instance);
  injector.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  injector.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());

  //initiating db
  await injector<LocalDb>().initDb();
}

void provideDataSources() {
  //Home
  injector.registerFactory<HomeLocalDataSource>(
      () => HomeLocalDataSourceImpl(localDb: injector.get<LocalDb>()));
  injector.registerFactory<HomeRemoteDataSource>(() =>
      HomeRemoteDataSourceImpl(networkService: injector.get<NetworkService>()));

  //MovieDetail
  injector.registerFactory<MovieDetailRemoteDataSource>(() =>
      MovieDetailRemoteDataSourceImpl(
          networkService: injector.get<NetworkService>()));
  injector.registerFactory<MovieDetailLocalDataSource>(
      () => MovieDetailLocalDataSourceImpl(localDb: injector.get<LocalDb>()));

  //Bookmark
  injector.registerFactory<BookmarkLocalDataSource>(
      () => BookmarkLocalDataSourceImpl(localDb: injector.get<LocalDb>()));

  //Notification
  injector.registerFactory<NotificationsLocalDataSource>(
      () => NotificationsLocalDataSourceImpl(localDb: injector.get<LocalDb>()));

  //Authentication
  injector.registerFactory<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(
      secureStorage: injector.get<FlutterSecureStorage>(),
      localDb: injector.get<LocalDb>()));
  injector.registerFactory<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(
      dio: (injector.get<NetworkService>() as DioNetworkService).dio,
      baseUrl: 'https://api.example.com'));
}

void provideRepositories() {
  //home
  injector.registerFactory<HomeRepository>(() => HomeRepositoryImpl(
      homeRemoteDataSource: injector.get<HomeRemoteDataSource>(),
      homeLocalDataSource: injector.get<HomeLocalDataSource>()));

  //MovieDetail
  injector.registerFactory<MovieDetailRepository>(() =>
      MovieDetailRepositoryImpl(
          movieDetailRemoteDataSource:
              injector.get<MovieDetailRemoteDataSource>(),
          movieDetailLocalDataSource:
              injector.get<MovieDetailLocalDataSource>()));

  //Bookmark
  injector.registerFactory<BookmarkRepository>(() => BookmarkRepositoryImpl(
      bookmarkLocalDataSource: injector.get<BookmarkLocalDataSource>()));

  //Notification
  injector.registerFactory<NotificationRepository>(() =>
      NotificationRepositoryImpl(
          notificationsLocalDataSource:
              injector.get<NotificationsLocalDataSource>()));

  //Authentication
  injector.registerFactory<AuthRepository>(() => AuthRepositoryImpl(
      remoteDataSource: injector.get<AuthRemoteDataSource>(),
      localDataSource: injector.get<AuthLocalDataSource>(),
      firebaseAuth: injector.get<firebase_auth.FirebaseAuth>(),
      googleSignIn: injector.get<GoogleSignIn>()));
}

void provideUseCases() {
  //home
  injector.registerFactory<FetchAndCacheGenreUseCase>(() =>
      FetchAndCacheGenreUseCase(
          homeRepository: injector.get<HomeRepository>()));
  injector.registerFactory<FetchAndCacheMoviesUseCase>(() =>
      FetchAndCacheMoviesUseCase(
          homeRepository: injector.get<HomeRepository>()));
  injector.registerFactory<FetchCacheGenresUseCase>(() =>
      FetchCacheGenresUseCase(homeRepository: injector.get<HomeRepository>()));
  injector.registerFactory<FetchCachedMoviesUseCase>(() =>
      FetchCachedMoviesUseCase(homeRepository: injector.get<HomeRepository>()));

  //MovieDetail
  injector.registerFactory<AddBookmarkUseCase>(() => AddBookmarkUseCase(
      movieDetailRepository: injector.get<MovieDetailRepository>()));
  injector.registerFactory<GetCastsUseCase>(() => GetCastsUseCase(
      movieDetailRepository: injector.get<MovieDetailRepository>()));
  injector.registerFactory<GetMovieDetailsUseCase>(() => GetMovieDetailsUseCase(
      movieDetailRepository: injector.get<MovieDetailRepository>()));
  injector.registerFactory<IsBookmarkedUseCase>(() => IsBookmarkedUseCase(
      movieDetailRepository: injector.get<MovieDetailRepository>()));
  injector.registerFactory<RemoveBookmarkUseCase>(() => RemoveBookmarkUseCase(
      movieDetailRepository: injector.get<MovieDetailRepository>()));
  injector.registerFactory(() => GetVideosUseCase(
      movieDetailRemoteDataSource:
          injector.get<MovieDetailRemoteDataSource>()));

  //Bookmarks
  injector.registerFactory<GetBookmarksUseCase>(() => GetBookmarksUseCase(
      bookmarkRepository: injector.get<BookmarkRepository>()));
  // injector.registerFactory<RemoveBookmarkUseCase>(() => RemoveBookmarkUseCase(bookmarkRepository: injector.get<BookmarkRepository>()));

  //Notifications
  injector.registerFactory<GetAllNotificationsUseCase>(() =>
      GetAllNotificationsUseCase(
          notificationRepository: injector.get<NotificationRepository>()));
  injector.registerFactory<ClearAllNotificationsUseCase>(() =>
      ClearAllNotificationsUseCase(
          notificationRepository: injector.get<NotificationRepository>()));

  //Authentication
  injector.registerFactory<SignUpUseCase>(
      () => SignUpUseCase(injector.get<AuthRepository>()));
  injector.registerFactory<SignInUseCase>(
      () => SignInUseCase(injector.get<AuthRepository>()));
  injector.registerFactory<SignInWithGoogleUseCase>(
      () => SignInWithGoogleUseCase(injector.get<AuthRepository>()));
  injector.registerFactory<SignInWithAppleUseCase>(
      () => SignInWithAppleUseCase(injector.get<AuthRepository>()));
  injector.registerFactory<SignOutUseCase>(
      () => SignOutUseCase(injector.get<AuthRepository>()));
  injector.registerFactory<ResetPasswordUseCase>(
      () => ResetPasswordUseCase(injector.get<AuthRepository>()));
}

void provideBlocs() {
  //Authentication
  injector.registerFactory<AuthenticationBloc>(() => AuthenticationBloc(
      signUpUseCase: injector.get<SignUpUseCase>(),
      signInUseCase: injector.get<SignInUseCase>(),
      signInWithGoogleUseCase: injector.get<SignInWithGoogleUseCase>(),
      signInWithAppleUseCase: injector.get<SignInWithAppleUseCase>(),
      signOutUseCase: injector.get<SignOutUseCase>(),
      resetPasswordUseCase: injector.get<ResetPasswordUseCase>(),
      authRepository: injector.get<AuthRepository>()));
}
