import 'package:flutter/material.dart';
import 'Login/login_screen.dart';
import 'Login/signin_screen.dart';
import 'Login/signup_screen.dart';
import 'Home/main_screen.dart';
import 'Login/verif_email.dart';
import 'Onboarding/gender.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Workout App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/loginPassword': (context) => const LoginPasswordScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const MainScreen(),
        '/verify-email': (context) => const VerifyEmailScreen(),
        '/gender': (context) => const GenderSelectionPage(),
      },
    );
  }
}