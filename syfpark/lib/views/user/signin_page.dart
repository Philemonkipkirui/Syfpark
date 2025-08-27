// lib/views/user/signin_page.dart
import 'package:flutter/material.dart';
import 'package:syfpark/services/google_service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleGoogleSignIn() async {
    final authService = AuthService();
    final userCredential = await authService.signInWithGoogle();
    if (userCredential != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Sign-In failed')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Sign In', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Email/Password Form
              const Text("Email", style: TextStyle(color: Colors.black)),
              const SizedBox(height: 5),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
                style: const TextStyle(color: Colors.black),
                validator: (value) => value!.isEmpty || !value.contains('@') ? 'Valid email is required' : null,
              ),
              const SizedBox(height: 15),

              const Text("Password", style: TextStyle(color: Colors.black)),
              const SizedBox(height: 5),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
                style: const TextStyle(color: Colors.black),
                validator: (value) => value!.isEmpty ? 'Password is required' : null,
              ),
              const SizedBox(height: 20),

              // Email Sign-In Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final authService = AuthService();
                      final userCredential = await authService.signInWithEmail(
                        _emailController.text,
                        _passwordController.text,
                      );
                      if (userCredential != null) {
                        Navigator.pushReplacementNamed(context, '/home');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Email Sign-In failed')),
                        );
                      }
                    }
                  },
                  child: const Text("Sign In", style: TextStyle(fontSize: 22, color: Colors.black)),
                ),
              ),
              const SizedBox(height: 20),

              // Google Sign-In Button
              Center(
                child: ElevatedButton.icon(
                  icon: Image.asset('assets/logos/google.png', height: 24),
                  label: const Text('Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _handleGoogleSignIn,
                ),
              ),
              const SizedBox(height: 20),

              // Link to Sign-Up
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text(
                    'Don\'t have an account? Sign Up',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}