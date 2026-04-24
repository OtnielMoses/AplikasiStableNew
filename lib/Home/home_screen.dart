import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import '../models/workout_data.dart';
import 'workout_session_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onCreateWorkout;
  const HomeScreen({super.key, this.onCreateWorkout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedLevel = "Beginner";
  late DateTime currentDate;
  late List<DateTime> weekDays;
  int selectedDayIndex = 3;
  int _timerMinutes = 0;
  int _timerSeconds = 0;
  bool _isTimerSet = false;

  final workouts = [
    {"title": "ABS BEGINNER", "level": "Beginner"},
    {"title": "SHOULDER & BACK BEGINNER", "level": "Beginner"},
    {"title": "FULL BODY INTERMEDIATE", "level": "Intermediate"},
    {"title": "ADVANCE FAT LOSS", "level": "Advance"},
  ];

  @override
  void initState() {
    super.initState();
    currentDate = DateTime.now();
    _generateWeekDays();
  }

  void _generateWeekDays() {
    DateTime start = currentDate.subtract(const Duration(days: 3));
    weekDays = List.generate(7, (index) => start.add(Duration(days: index)));
  }

  void _showTimerPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        int hours = _timerMinutes ~/ 60;
        int minutes = _timerMinutes % 60;
        return Container(
          height: 300,
          decoration: const BoxDecoration(
            color: Color(0xFF1F222A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text("Set Timer", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Expanded(
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration: Duration(hours: hours, minutes: minutes),
                  onTimerDurationChanged: (duration) {
                    setState(() {
                      _timerMinutes = duration.inMinutes;
                      _timerSeconds = duration.inSeconds % 60;
                      _isTimerSet = true;
                    });
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4FF33), foregroundColor: Colors.black),
                child: const Text("OK"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _startWorkout(WorkoutDay workout) {
    if (!_isTimerSet || (_timerMinutes == 0 && _timerSeconds == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please set timer first")));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutSessionScreen(
          workout: workout,
          initialDuration: Duration(minutes: _timerMinutes, seconds: _timerSeconds),
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = workouts.where((w) => w["level"] == selectedLevel).toList();
    final now = DateTime.now();
    final formattedDate = DateFormat('d MMMM yyyy').format(now);
    final dayName = DateFormat('EEEE').format(now);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
            return Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(radius: 25),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Hello, John", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("Have a productive workout day!", style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.chat_bubble_outline),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _chip("Advanced", Colors.purple.shade200, Colors.black),
                    const SizedBox(width: 10),
                    _chip("Training Days", Colors.orange, Colors.white),
                    const SizedBox(width: 10),
                    _chip("Community", Colors.blue, Colors.white),
                  ],
                ),
                const SizedBox(height: 25),
                Center(
                  child: Column(
                    children: [
                      Text(dayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFD4FF33))),
                      const SizedBox(height: 4),
                      Text(formattedDate, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                _calendar(),
                const SizedBox(height: 25),
                const Center(child: Text("Today's Activity", style: TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(height: 20),
                FutureBuilder<WorkoutDay?>(
                  future: WorkoutStorage.getWorkoutForDay(dayName),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final workout = snapshot.data;
                    if (workout != null) {
                      return _todayWorkoutCard(workout);
                    } else {
                      return _noWorkoutCard();
                    }
                  },
                ),
                const SizedBox(height: 25),
                _dailyChallenge(),
                const SizedBox(height: 25),
                const Text("Have a plan?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _timerCard(),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: widget.onCreateWorkout,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                    child: const Text("Create Workout"),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _filter("Beginner"),
                    const SizedBox(width: 10),
                    _filter("Intermediate"),
                    const SizedBox(width: 10),
                    _filter("Advance"),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  children: filtered.map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: _exerciseCard(w["title"]!),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _calendar() {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: weekDays.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final date = weekDays[i];
          final isSelected = i == selectedDayIndex;
          final dayShort = DateFormat('E').format(date);
          final dayNum = date.day.toString();
          return GestureDetector(
            onTap: () => setState(() { selectedDayIndex = i; currentDate = date; }),
            child: Container(
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isSelected ? const Color(0xFFD4FF33) : Colors.transparent,
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dayShort, style: TextStyle(color: isSelected ? Colors.black : Colors.white70, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(dayNum, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _todayWorkoutCard(WorkoutDay workout) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1F222A), Color(0xFF2A2F3A)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4FF33), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fitness_center, color: Color(0xFFD4FF33)),
              const SizedBox(width: 8),
              Text("Today's Plan: ${workout.sectionName}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text("Body parts: ${workout.bodyParts.join(", ")}", style: const TextStyle(fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 4),
          Text("Exercises: ${workout.exercises.length} movements", style: const TextStyle(fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _startWorkout(workout),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4FF33), foregroundColor: Colors.black),
            child: const Text("Start Workout"),
          ),
        ],
      ),
    );
  }

  Widget _noWorkoutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1F222A), borderRadius: BorderRadius.circular(20)),
      child: const Column(
        children: [
          Icon(Icons.calendar_today, color: Colors.white54),
          SizedBox(height: 8),
          Text("No workout planned for today", style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _timerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.purple.shade200, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Timer", style: TextStyle(color: Colors.black, fontSize: 18)),
              Text(
                _isTimerSet ? "${(_timerMinutes ~/ 60).toString().padLeft(2, '0')}:${(_timerMinutes % 60).toString().padLeft(2, '0')}" : "Not set",
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _showTimerPicker,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: const Text("Set timer"),
          ),
        ],
      ),
    );
  }

  Widget _dailyChallenge() {
    final challenges = ["Push Day", "Pull Day", "Leg Day", "Upper Body", "HIIT", "Home Workout"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Daily Challenge", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: challenges.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) => Container(
              width: 140,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color(0xFF1F222A)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.local_fire_department, color: Color(0xFFD4FF33)),
                  const Spacer(),
                  Text(challenges[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(String text, Color bg, Color txt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: txt)),
    );
  }

  Widget _filter(String label) {
    final isSelected = selectedLevel == label;
    return GestureDetector(
      onTap: () => setState(() => selectedLevel = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _exerciseCard(String title) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Colors.black, Colors.blueGrey]),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text("Start"),
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Icon(Icons.access_time, size: 16),
                Text(" 78 min"),
                SizedBox(width: 10),
                Icon(Icons.local_fire_department, size: 16),
                Text(" 28 Exercises"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}