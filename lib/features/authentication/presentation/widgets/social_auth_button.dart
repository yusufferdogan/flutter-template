import 'package:flutter/material.dart';

enum SocialAuthProvider { google, apple }

class SocialAuthButton extends StatelessWidget {
  final SocialAuthProvider provider;
  final VoidCallback onPressed;

  const SocialAuthButton({
    super.key,
    required this.provider,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isApple = provider == SocialAuthProvider.apple;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isApple ? Icons.apple : Icons.g_mobiledata,
              size: 24,
              color: Colors.black,
            ),
            const SizedBox(width: 12),
            Text(
              'Continue with ${isApple ? 'Apple' : 'Google'}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
