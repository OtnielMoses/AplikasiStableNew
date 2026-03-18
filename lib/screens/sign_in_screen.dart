import 'package:flutter/material.dart';
import '../widgets/app_form.dart';
import '../widgets/app_navbar.dart';
import 'landing_page_logged.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

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
                  const AppField(label: 'Email', hint: 'email@example.com'),
                  const SizedBox(height: 16),
                  const AppField(label: 'Password', hint: '••••••••', obscure: true),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'SIGN IN',
                    onTap: () => Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const LandingPageLogged())),
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