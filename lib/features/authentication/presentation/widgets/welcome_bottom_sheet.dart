import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/authentication_bloc.dart';
import '../bloc/authentication_event.dart';
import '../bloc/authentication_state.dart';
import 'gradient_button.dart';
import 'social_auth_button.dart';

class WelcomeBottomSheet extends StatelessWidget {
  const WelcomeBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        state.maybeWhen(
          authenticated: (user) {
            Navigator.of(context).pop();
            context.go('/home');
          },
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
              ),
            );
          },
          orElse: () {},
        );
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Sign Up Button
                    GradientButton(
                      text: 'Sign Up',
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push('/signup');
                      },
                    ),
                    const SizedBox(height: 16),
                    // Login Button
                    GradientButton(
                      text: 'Login',
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push('/signin');
                      },
                      isOutlined: true,
                    ),
                    const SizedBox(height: 24),
                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Apple Sign In
                    BlocBuilder<AuthenticationBloc, AuthenticationState>(
                      builder: (context, state) {
                        final isLoading = state is Loading;
                        return SocialAuthButton(
                          provider: SocialAuthProvider.apple,
                          onPressed: isLoading
                              ? () {}
                              : () {
                                  context.read<AuthenticationBloc>().add(
                                        const AuthenticationEvent
                                            .signInWithAppleRequested(),
                                      );
                                },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Google Sign In
                    BlocBuilder<AuthenticationBloc, AuthenticationState>(
                      builder: (context, state) {
                        final isLoading = state is Loading;
                        return SocialAuthButton(
                          provider: SocialAuthProvider.google,
                          onPressed: isLoading
                              ? () {}
                              : () {
                                  context.read<AuthenticationBloc>().add(
                                        const AuthenticationEvent
                                            .signInWithGoogleRequested(),
                                      );
                                },
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
