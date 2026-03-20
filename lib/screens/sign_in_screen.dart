import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../widgets/app_form.dart';
import '../widgets/app_navbar.dart';
import 'landing_page_logged.dart';
import 'sign_up_screen.dart';
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Email dan Password tidak boleh kosong');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Uri apiUrl = Uri.parse('https://api-stable-app.com/api/login'); 
      
      final response = await http.post(
        apiUrl,
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LandingPageLogged()),
          );
        }
      } else {
        // Jika gagal (email/password tidak cocok di database)
        _showErrorSnackBar('Maaf Username/Password salah');
      }
    } catch (e) {
      _showErrorSnackBar('Terjadi kesalahan koneksi server.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color kNavy = Color(0xFF000080); 

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kNavy, Colors.black],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 380,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF131e2e),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2a3a4a)),
              ),
              child: Column(
                children: [
                  const Text('💪', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 10),
                  const Text('SIGN IN',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3)),
                  const SizedBox(height: 30),
                  
                  AppField(
                    label: 'Email', 
                    hint: 'email@example.com',
                    controller: _emailController,
                  ),
                  const SizedBox(height: 16),
                  AppField(
                    label: 'Password', 
                    hint: '••••••••', 
                    obscure: true,
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 24),
                  
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.blue)
                      : AppButton(
                          label: 'SIGN IN',
                          onTap: _login,
                        ),
                  
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen())),
                    child: const Text('Belum punya akun? Sign Up',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('← Kembali',
                        style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}