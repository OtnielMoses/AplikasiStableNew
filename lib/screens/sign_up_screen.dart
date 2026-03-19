import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/app_form.dart';
import '../widgets/app_navbar.dart';
import 'landing_page_logged.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controller untuk ambil isi field
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _usernameCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();

  bool _isLoading = false;
  String? _errorMsg;

  // ── FUNGSI REGISTER ──────────────────────────────────────
  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/v1/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'first_name': _firstNameCtrl.text.trim(),
          'last_name' : _lastNameCtrl.text.trim(),
          'username'  : _usernameCtrl.text.trim(),
          'email'     : _emailCtrl.text.trim(),
          'password'  : _passwordCtrl.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Berhasil → pindah ke halaman logged
        if (mounted) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const LandingPageLogged()));
        }
      } else {
        // Gagal → tampilkan pesan error dari server
        setState(() {
          _errorMsg = data['message'] ?? 'Registrasi gagal';
        });
      }
    } catch (e) {
      // Error koneksi
      setState(() {
        _errorMsg = 'Tidak dapat terhubung ke server';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
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
                  const Text('SIGN UP',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3)),
                  const SizedBox(height: 30),

                  // Fields — sekarang pakai controller
                  AppField(label: 'First Name', hint: 'John',
                      controller: _firstNameCtrl),
                  const SizedBox(height: 16),
                  AppField(label: 'Last Name', hint: 'Doe',
                      controller: _lastNameCtrl),
                  const SizedBox(height: 16),
                  AppField(label: 'Username', hint: '@username',
                      controller: _usernameCtrl),
                  const SizedBox(height: 16),
                  AppField(label: 'Email', hint: 'email@example.com',
                      controller: _emailCtrl),
                  const SizedBox(height: 16),
                  AppField(label: 'Password', hint: '••••••••',
                      obscure: true, controller: _passwordCtrl),
                  const SizedBox(height: 16),

                  // Pesan error
                  if (_errorMsg != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_errorMsg!,
                          style: const TextStyle(
                              color: Color(0xFFff6b6b), fontSize: 13)),
                    ),

                  // Tombol — loading state
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : AppButton(label: 'SIGN UP', onTap: _signUp),

                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const SignInScreen())),
                    child: const Text('Sudah punya akun? Sign In',
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