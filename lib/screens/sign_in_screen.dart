import 'dart:convert';
import 'package:flutter/material.dart';
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
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isLoading = false;
  String? _errorMsg;

  Future<void> _login() async {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMsg = 'Email dan Password tidak boleh kosong');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg  = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email'   : email,
          'password': password,
        }),
      );

      // Debug — lihat di terminal
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const LandingPageLogged()));
        }
      } else {
        setState(() {
          _errorMsg = data['message'] ?? 'Email atau password salah';
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Tidak dapat terhubung ke server';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    controller: _emailCtrl,
                  ),
                  const SizedBox(height: 16),
                  AppField(
                    label: 'Password',
                    hint: '••••••••',
                    obscure: true,
                    controller: _passwordCtrl,
                  ),
                  const SizedBox(height: 16),

                  // Pesan error
                  if (_errorMsg != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _errorMsg!,
                        style: const TextStyle(
                            color: Color(0xFFff6b6b), fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Tombol login
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : AppButton(label: 'SIGN IN', onTap: _login),

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