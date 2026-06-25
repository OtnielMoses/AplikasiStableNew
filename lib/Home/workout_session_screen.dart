import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _isPaused = false;
  int _completedSets = 0;
  int _totalSets = 0;

  @override
  void initState() {
    super.initState();
    _remaining = widget.initialDuration;
    _totalSets = widget.workout.exercises.fold(0, (sum, ex) => sum + ex.sets);
    _startTimer();
  }

  void _startTimer() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && mounted) {
        setState(() {
          if (_remaining.inSeconds > 0) {
            _remaining = _remaining - const Duration(seconds: 1);
          } else {
            _timer?.cancel();
            _finishWorkout();
          }
        });
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    if (!_isPaused) {
      _startTimer();
    }
  }

  void _nextSet() {
    final currentExercise = widget.workout.exercises[_currentExerciseIndex];
    
    if (_currentSetIndex + 1 < currentExercise.sets) {
      setState(() {
        _currentSetIndex++;
        _completedSets++;
      });
    } else {
      if (_currentExerciseIndex + 1 < widget.workout.exercises.length) {
        setState(() {
          _currentExerciseIndex++;
          _currentSetIndex = 0;
          _completedSets++;
        });
      } else {
        _completedSets++;
        _finishWorkout();
      }
    }
  }

  void _previousSet() {
    if (_currentSetIndex > 0) {
      setState(() {
        _currentSetIndex--;
        _completedSets--;
      });
    } else if (_currentExerciseIndex > 0) {
      final previousExercise = widget.workout.exercises[_currentExerciseIndex - 1];
      setState(() {
        _currentExerciseIndex--;
        _currentSetIndex = previousExercise.sets - 1;
        _completedSets--;
      });
    }
  }

  void _finishWorkout() {
    _timer?.cancel();
    _updateStats();
    _showCompletionDialog();
  }

  Future<void> _updateStats() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Total workouts
    int totalWorkouts = prefs.getInt('total_workouts') ?? 0;
    totalWorkouts++;
    await prefs.setInt('total_workouts', totalWorkouts);

    // Days active
    String? lastActiveDate = prefs.getString('last_active_date');
    if (lastActiveDate != todayStr) {
      int daysActive = prefs.getInt('days_active') ?? 0;
      daysActive++;
      await prefs.setInt('days_active', daysActive);
      await prefs.setString('last_active_date', todayStr);
    }

    // Streak
    String? lastWorkoutDate = prefs.getString('last_workout_date');
    int currentStreak = prefs.getInt('streak') ?? 0;

    // Cek apakah hari ini rest day
    String? restDayDate = prefs.getString('rest_day_date');
    bool isRestDayToday = restDayDate == todayStr;

    if (lastWorkoutDate == null) {
      // Pertama kali workout
      currentStreak = 1;
    } else {
      final last = DateTime.parse(lastWorkoutDate);
      final difference = now.difference(last).inDays;
      if (difference == 0) {
        // Sudah workout hari ini, streak tetap
        // tidak perlu ubah
      } else if (difference == 1) {
        // Workout kemarin, lanjutkan streak
        currentStreak++;
      } else {
        // Terlewat lebih dari 1 hari, cek apakah ada rest day di antara
        // Untuk sederhana, reset streak
        // Namun jika ada rest day yang bersambung, streak tetap
        // Kita cek apakah kemarin adalah rest day
        final yesterdayStr = '${now.subtract(const Duration(days: 1)).year}-${now.subtract(const Duration(days: 1)).month.toString().padLeft(2, '0')}-${now.subtract(const Duration(days: 1)).day.toString().padLeft(2, '0')}';
        String? yesterdayRest = prefs.getString('rest_day_date');
        if (yesterdayRest == yesterdayStr) {
          // Kemarin rest day, streak tidak reset
          // Streak tetap
          // Tapi kita perlu cek apakah sebelumnya workout
          // Untuk sederhana, kita pertahankan streak jika selisih <= 2 hari dan ada rest day
          if (difference <= 2) {
            // Streak tetap
          } else {
            currentStreak = 1;
          }
        } else {
          // Reset streak
          currentStreak = 1;
        }
      }
    }

    await prefs.setInt('streak', currentStreak);
    await prefs.setString('last_workout_date', todayStr);
    
    // Hapus status rest day (karena sudah workout)
    await prefs.remove('rest_day_date');
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1C24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD4FF33).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.emoji_events, color: Color(0xFFD4FF33), size: 28),
            ),
            const SizedBox(width: 12),
            const Text("Workout Complete!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You have successfully completed your workout.",
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(Icons.access_time, "${widget.initialDuration.inMinutes - _remaining.inMinutes} min", "Duration"),
                  _buildStatItem(Icons.fitness_center, "$_completedSets", "Sets"),
                  _buildStatItem(Icons.repeat, "${widget.workout.exercises.length}", "Exercises"),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Finish", style: TextStyle(color: Color(0xFFD4FF33))),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFD4FF33)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF8E8E93))),
      ],
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
    final progress = _completedSets / _totalSets;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            _timer?.cancel();
            Navigator.pop(context);
          },
        ),
        title: const Text("Workout Session", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFFD4FF33)),
            onPressed: () => _showWorkoutInfo(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.workout.sectionName,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${_currentExerciseIndex + 1} of ${widget.workout.exercises.length}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1C24),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.fitness_center, size: 14, color: Color(0xFFD4FF33)),
                          const SizedBox(width: 4),
                          Text(
                            "$_completedSets/$_totalSets",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color(0xFF1A1C24),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4FF33)),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1C24),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "TIMER",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8E8E93),
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${_remaining.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(_remaining.inSeconds % 60).toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4FF33),
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1C24),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Text(
                            currentExercise.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildInfoChip(
                                Icons.repeat,
                                "${_currentSetIndex + 1} / ${currentExercise.sets} sets",
                              ),
                              const SizedBox(width: 16),
                              _buildInfoChip(
                                Icons.fitness_center,
                                "${currentExercise.reps} reps",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0C10),
              border: Border(top: BorderSide(color: const Color(0xFF1A1C24), width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _previousSet,
                    icon: const Icon(Icons.skip_previous, size: 20),
                    label: const Text("Previous"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF2A2D35)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _togglePause,
                    icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause, size: 20),
                    label: Text(_isPaused ? "Resume" : "Pause"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4FF33),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _nextSet,
                    icon: const Icon(Icons.skip_next, size: 20),
                    label: const Text("Next"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4FF33),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D35),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFD4FF33)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
        ],
      ),
    );
  }

  void _showWorkoutInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1C24),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Workout Overview",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            ...widget.workout.exercises.asMap().entries.map((entry) {
              final idx = entry.key;
              final ex = entry.value;
              final isCurrent = idx == _currentExerciseIndex;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCurrent ? const Color(0xFFD4FF33).withOpacity(0.1) : const Color(0xFF2A2D35),
                  borderRadius: BorderRadius.circular(12),
                  border: isCurrent ? Border.all(color: const Color(0xFFD4FF33)) : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCurrent ? const Color(0xFFD4FF33) : const Color(0xFF4A4E59),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          "${idx + 1}",
                          style: TextStyle(
                            color: isCurrent ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ex.name,
                        style: TextStyle(
                          color: isCurrent ? const Color(0xFFD4FF33) : Colors.white,
                          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    Text(
                      "${ex.sets} sets x ${ex.reps} reps",
                      style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4FF33),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text("Close", style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}