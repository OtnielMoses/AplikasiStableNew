import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import 'profile_screen.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  int _totalSeconds = 0;
  bool _running = false;
  Timer? _timer;

  void _toggleTimer() {
    if (_running) {
      _timer?.cancel();
      setState(() {
        _running = false;
        _totalSeconds = 0;
      });
    } else {
      setState(() => _running = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _totalSeconds++);
      });
    }
  }

  String get _minutes => (_totalSeconds ~/ 60).toString().padLeft(2, '0');
  String get _seconds => (_totalSeconds % 60).toString().padLeft(2, '0');

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0d1b2a), Colors.black],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── NAVBAR (scrollable) ───────────────────────
              AppNavbar(links: [
                NavLink('Home', onTap: () => Navigator.pop(context)),
                NavLink('Exercise'),
                NavLink('Leaderboard'),
                NavLink('Profile', onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()))),
                NavLink('Logout', color: kRed, onTap: () =>
                    Navigator.popUntil(context, (r) => r.isFirst)),
              ]),

              // ── TIMER ────────────────────────────────────
              Expanded(
                child: Center(
                  child: Padding(
                    // Padding kiri kanan agar tidak mepet
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
                      width: screenWidth, // ikuti lebar layar - padding
                      constraints: const BoxConstraints(maxWidth: 500),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 40),
                      decoration: BoxDecoration(
                        color: const Color(0xFF070b0c),
                        border: Border.all(
                            color: const Color(0xFF7e7e7e), width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Label
                          const Text(
                            'READY TO DOMINATE?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Lexend Giga',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Timer display — font size mengikuti lebar layar
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_minutes,
                                    style: const TextStyle(
                                      fontFamily: 'Lexend Giga',
                                      fontSize: 100,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFe0e0e0),
                                      height: 1,
                                    )),
                                const Text(':',
                                    style: TextStyle(
                                      fontFamily: 'Lexend Giga',
                                      fontSize: 100,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFe0e0e0),
                                      height: 1,
                                    )),
                                Text(_seconds,
                                    style: const TextStyle(
                                      fontFamily: 'Lexend Giga',
                                      fontSize: 100,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFe0e0e0),
                                      height: 1,
                                    )),
                              ],
                            ),
                          ),
                          const SizedBox(height: 36),

                          // Button
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFe0e0e0),
                              foregroundColor: const Color(0xFF0d0d0d),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50)),
                            ),
                            onPressed: _toggleTimer,
                            icon: Icon(
                                _running ? Icons.stop : Icons.play_arrow,
                                size: 18),
                            label: Text(
                              _running ? 'STOP WORKOUT' : 'START WORKOUT',
                              style: const TextStyle(
                                fontFamily: 'Lexend Giga',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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