import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_in_with_apple_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final SignUpUseCase signUpUseCase;
  final SignInUseCase signInUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignInWithAppleUseCase signInWithAppleUseCase;
  final SignOutUseCase signOutUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final AuthRepository authRepository;

  StreamSubscription<AuthState>? _authStateSubscription;

  AuthenticationBloc({
    required this.signUpUseCase,
    required this.signInUseCase,
    required this.signInWithGoogleUseCase,
    required this.signInWithAppleUseCase,
    required this.signOutUseCase,
    required this.resetPasswordUseCase,
    required this.authRepository,
  }) : super(const AuthenticationState.initial()) {
    on<SignUpRequested>(_onSignUpRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<SignInWithAppleRequested>(_onSignInWithAppleRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<AuthStateChanged>(_onAuthStateChanged);
    on<CheckAuthStatus>(_onCheckAuthStatus);

    // Listen to auth state changes
    _authStateSubscription = authRepository.authStateChanges.listen((authState) {
      if (authState == AuthState.unauthenticated) {
        add(const AuthenticationEvent.authStateChanged(null));
      }
    });
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const AuthenticationState.loading());

    final result = await signUpUseCase(
      fullName: event.fullName,
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthenticationState.error(_mapFailureToMessage(failure))),
      (user) => emit(AuthenticationState.authenticated(user)),
    );
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const AuthenticationState.loading());

    final result = await signInUseCase(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthenticationState.error(_mapFailureToMessage(failure))),
      (user) => emit(AuthenticationState.authenticated(user)),
    );
  }

  Future<void> _onSignInWithGoogleRequested(
    SignInWithGoogleRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const AuthenticationState.loading());

    final result = await signInWithGoogleUseCase();

    result.fold(
      (failure) => emit(AuthenticationState.error(_mapFailureToMessage(failure))),
      (user) => emit(AuthenticationState.authenticated(user)),
    );
  }

  Future<void> _onSignInWithAppleRequested(
    SignInWithAppleRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const AuthenticationState.loading());

    final result = await signInWithAppleUseCase();

    result.fold(
      (failure) => emit(AuthenticationState.error(_mapFailureToMessage(failure))),
      (user) => emit(AuthenticationState.authenticated(user)),
    );
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const AuthenticationState.loading());

    final result = await signOutUseCase();

    result.fold(
      (failure) => emit(AuthenticationState.error(_mapFailureToMessage(failure))),
      (_) => emit(const AuthenticationState.unauthenticated()),
    );
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const AuthenticationState.loading());

    final result = await resetPasswordUseCase(event.email);

    result.fold(
      (failure) => emit(AuthenticationState.error(_mapFailureToMessage(failure))),
      (_) => emit(const AuthenticationState.passwordResetSent()),
    );
  }

  Future<void> _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthenticationState> emit,
  ) async {
    if (event.user != null) {
      emit(AuthenticationState.authenticated(event.user!));
    } else {
      emit(const AuthenticationState.unauthenticated());
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const AuthenticationState.loading());

    final result = await authRepository.getCurrentUser();

    result.fold(
      (failure) => emit(const AuthenticationState.unauthenticated()),
      (user) {
        if (user != null) {
          emit(AuthenticationState.authenticated(user));
        } else {
          emit(const AuthenticationState.unauthenticated());
        }
      },
    );
  }

  String _mapFailureToMessage(AuthFailure failure) {
    return failure.when(
      invalidCredentials: () => 'Invalid email or password',
      emailAlreadyExists: () => 'An account with this email already exists',
      weakPassword: () => 'Password must be at least 8 characters',
      networkError: () => 'Please check your internet connection',
      serverError: (message) => message.isNotEmpty ? message : 'Something went wrong. Please try again',
      oauthCancelled: () => 'Sign in was cancelled',
      oauthFailed: (message) => 'Sign in failed: $message',
      unknown: (message) => message,
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
