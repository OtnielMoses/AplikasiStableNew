import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'coach_chat_screen.dart';
import 'coach_checkout_screen.dart';

// Data coach
class Coach {
  final String id;
  final String name;
  final String specialty;
  final String experience;
  final double rating;
  final String imageUrl;
  final String bio;

  Coach({
    required this.id,
    required this.name,
    required this.specialty,
    required this.experience,
    required this.rating,
    required this.imageUrl,
    required this.bio,
  });
}

final List<Coach> coaches = [
  Coach(
    id: '1',
    name: 'Alex Johnson',
    specialty: 'Strength & Conditioning',
    experience: '5 years',
    rating: 4.8,
    imageUrl: 'assets/coach1.png',
    bio: 'Ex-athlete with passion for functional fitness.',
  ),
  Coach(
    id: '2',
    name: 'Maria Garcia',
    specialty: 'Yoga & Mobility',
    experience: '8 years',
    rating: 4.9,
    imageUrl: 'assets/coach2.png',
    bio: 'Certified yoga instructor, helps with flexibility and recovery.',
  ),
  Coach(
    id: '3',
    name: 'James Lee',
    specialty: 'Bodybuilding',
    experience: '10 years',
    rating: 4.7,
    imageUrl: 'assets/coach3.png',
    bio: 'Competitive bodybuilder, specializes in hypertrophy.',
  ),
  Coach(
    id: '4',
    name: 'Sarah Kim',
    specialty: 'Nutrition & Weight Loss',
    experience: '6 years',
    rating: 4.6,
    imageUrl: 'assets/coach4.png',
    bio: 'Nutritionist and weight loss expert, holistic approach.',
  ),
];

class PersonalTrainerScreen extends StatefulWidget {
  const PersonalTrainerScreen({super.key});

  @override
  State<PersonalTrainerScreen> createState() => _PersonalTrainerScreenState();
}

class _PersonalTrainerScreenState extends State<PersonalTrainerScreen> {
  bool _isInSession = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final session = prefs.getBool('isChatSessionActive') ?? false;
    setState(() {
      _isInSession = session;
    });
  }

  // Method untuk refresh status session (dipanggil saat kembali dari chat)
  void refreshSession() {
    _checkSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0C10),
        elevation: 0,
        title: const Text(
          "Coaches",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: _isInSession
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, size: 64, color: Color(0xFFD4FF33)),
                  const SizedBox(height: 16),
                  const Text(
                    "You are currently in a coaching session.",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Tap here to resume your session",
                    style: TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Resume session - ambil coach id dari shared prefs
                      _resumeSession();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4FF33),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Resume Session",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: coaches.length,
              itemBuilder: (context, index) {
                final coach = coaches[index];
                return _CoachCard(
                  coach: coach,
                  onHireSuccess: () {
                    // Setelah hire sukses, refresh status
                    _checkSession();
                  },
                );
              },
            ),
    );
  }

  Future<void> _resumeSession() async {
    final prefs = await SharedPreferences.getInstance();
    final coachId = prefs.getString('currentCoachId');
    if (coachId == null) {
      // Jika tidak ada coachId, clear session
      await prefs.remove('isChatSessionActive');
      setState(() {
        _isInSession = false;
      });
      return;
    }
    // Cari coach berdasarkan id
    final coach = coaches.firstWhere((c) => c.id == coachId, orElse: () => coaches.first);
    // Navigasi ke chat screen dengan sisa waktu
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoachChatScreen(
          coach: coach,
          sessionDuration: const Duration(minutes: 15),
          isResuming: true,
        ),
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  final Coach coach;
  final VoidCallback onHireSuccess;
  const _CoachCard({required this.coach, required this.onHireSuccess});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2D35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[800],
                    image: const DecorationImage(
                      image: AssetImage('assets/coach_placeholder.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: const Icon(Icons.person, size: 32, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coach.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coach.specialty,
                        style: const TextStyle(
                          color: Color(0xFFD4FF33),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFFFD60A), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            coach.rating.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            coach.experience,
                            style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              coach.bio,
              style: const TextStyle(color: Color(0xFFB0B3B8), fontSize: 14),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CoachCheckoutScreen(coach: coach),
                    ),
                  );
                  if (result == true) {
                    onHireSuccess();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4FF33),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Hire Coach",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}