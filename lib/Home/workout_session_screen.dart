import 'package:flutter/material.dart';
import 'dart:async';
import '../models/workout_data.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final WorkoutDay workout;
  final Duration initialDuration;

  const WorkoutSessionScreen({super.key, required this.workout, required this.initialDuration});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  late Duration _remaining;
  Timer? _timer;
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 0;

  @override
  void initState() {
    super.initState();
    _remaining = widget.initialDuration;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining = _remaining - const Duration(seconds: 1);
        } else {
          _timer?.cancel();
          _showCompletionDialog();
        }
      });
    });
  }

  void _nextSet() {
    final currentExercise = widget.workout.exercises[_currentExerciseIndex];
    if (_currentSetIndex + 1 < currentExercise.sets) {
      setState(() {
        _currentSetIndex++;
      });
    } else {
      if (_currentExerciseIndex + 1 < widget.workout.exercises.length) {
        setState(() {
          _currentExerciseIndex++;
          _currentSetIndex = 0;
        });
      } else {
        // Selesai semua latihan
        _finishWorkout();
      }
    }
  }

  void _finishWorkout() {
    _timer?.cancel();
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F222A),
        title: const Text("Congratulations!"),
        content: Text("You completed your workout!\nTime spent: ${widget.initialDuration.inMinutes - _remaining.inMinutes} minutes ${widget.initialDuration.inSeconds - _remaining.inSeconds} seconds"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // kembali ke home
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = widget.workout.exercises[_currentExerciseIndex];
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Workout Session"),
        actions: [
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () {
              _timer?.cancel();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${_remaining.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(_remaining.inSeconds % 60).toString().padLeft(2, '0')}",
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFFD4FF33)),
            ),
            const SizedBox(height: 40),
            Text(
              currentExercise.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              "Set $_currentSetIndex of ${currentExercise.sets}",
              style: const TextStyle(fontSize: 20, color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Text(
              "Reps: ${currentExercise.reps}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextSet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4FF33),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Next Set", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}