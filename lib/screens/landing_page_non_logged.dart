import 'package:flutter/material.dart';
import '../widgets/gradient_text.dart';
import '../widgets/app_navbar.dart';
import '../utils/responsive_helper.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class LandingPageNonLogged extends StatelessWidget {
  const LandingPageNonLogged({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final small = ResponsiveHelper.isSmall(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────
            Container(
              height: h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [kNavy, Colors.black],
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppNavbar(links: [
                      NavLink('Home'),
                      NavLink('Sign Up',
                          color: kRed,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const SignUpScreen()))),
                      NavLink('Sign In',
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const SignInScreen()))),
                    ]),
                    const SizedBox(height: 50),
                    Center(
                      child: Text('⚡', style: TextStyle(fontSize: small ? 80 : 120)),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: EdgeInsets.only(left: ResponsiveHelper.textLeft(context)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GradientText('FORGE DISCIPLINE',
                              fontSize: 70,
                              gradient: const LinearGradient(
                                  colors: [Colors.grey, Colors.grey])),
                          GradientText('BUILD CONSISTENCY',
                              fontSize: 70,
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.white, Color(0xFF253745), Color(0xFF11212d)],
                                stops: [0.2, 0.8, 1.0],
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── BODY ────────────────────────────────────────
            Container(
              height: h * 0.5,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, kDark],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🥉🥈🥇🏆👑', style: TextStyle(fontSize: small ? 40 : 60)),
                  const SizedBox(height: 20),
                  GradientText(
                    'HIT YOUR STRIKES AND TOP THE RANK',
                    fontSize: 15,
                    letterSpacing: small ? 3 : 5,
                    textAlign: TextAlign.center,
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Color(0xFF253745), Color(0xFF11212d)],
                      stops: [0.2, 0.8, 1.0],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}