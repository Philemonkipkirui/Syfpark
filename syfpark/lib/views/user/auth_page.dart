import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syfpark/services/google_service.dart';
import 'package:syfpark/views/home/constants.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      print('Starting Google Sign-In...');
      final authService = AuthService();
      final userCredential = await authService.signInWithGoogle();
      if (!mounted) {
        print('Widget unmounted before sign-in completed');
        return;
      }
      if (userCredential != null) {
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? true;
        print('Sign-in successful: UID=${userCredential.user?.uid}, isNewUser=$isNewUser');
        if (isNewUser) {
          print('Attempting to save new user data to Firestore...');
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .set({
              'email': userCredential.user!.email,
              'displayName': userCredential.user!.displayName ?? 'Anonymous',
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            print('Firestore write successful for UID=${userCredential.user!.uid}');
          } catch (firestoreError) {
            print('Firestore write failed: $firestoreError');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to save user data: $firestoreError')),
              );
            }
          }
        } else {
          print('Returning user, no Firestore write needed');
        }
        // Delay to ensure Firestore write completes
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          print('Navigating to /home');
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          print('Widget unmounted before navigation');
        }
      } else {
        print('Google Sign-In returned null userCredential');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google Sign-In failed')),
          );
        }
      }
    } catch (e) {
      print('Sign-in error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during sign-in: $e')),
        );
      }
    }
  }

  void _handleAppleSignIn() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Apple Sign-In not implemented yet')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logos/app_logo.png',
                  height: 80,
                  width: 80,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.account_circle,
                    size: 80,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome to SyfPark',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in or create an account to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                _buildAuthButton(
                  icon: Image.asset('assets/logos/google.png', height: 24),
                  label: 'Continue with Google',
                  backgroundColor: Colors.white,
                  textColor: AppColors.textSecondary,
                  borderColor: AppColors.textSecondary,
                  onPressed: _handleGoogleSignIn,
                ),
                const SizedBox(height: 16),
                _buildAuthButton(
                  icon: Image.asset('assets/logos/Apple.png', height: 24),
                  label: 'Continue with Apple',
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  borderColor: Colors.black,
                  onPressed: _handleAppleSignIn,
                ),
                const Spacer(),
                TextButton.icon(
                  icon: Icon(Icons.arrow_back, color: AppColors.textSecondary),
                  label: Text(
                    'Back',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButton({
    required Widget icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onPressed,
  }) {
    return AnimatedScaleButton(
      child: ElevatedButton.icon(
        icon: icon,
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor),
          ),
          minimumSize: const Size(double.infinity, 56),
          elevation: 2,
          shadowColor: AppColors.accent.withOpacity(0.3),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class AnimatedScaleButton extends StatefulWidget {
  final Widget child;

  const AnimatedScaleButton({super.key, required this.child});

  @override
  State<AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}