// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_data.dart';
import 'workout_session_screen.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/formatter.dart';
import 'package:stable_app/core/widgets/common/custom_button.dart';
import 'package:stable_app/core/widgets/common/custom_card.dart';

// ==================== WORKOUT DATABASE ====================

Duration _parseDuration(String durationStr) {
  final match = RegExp(r'(\d+)').firstMatch(durationStr);
  final minutes = int.tryParse(match?.group(1) ?? '30') ?? 30;
  return Duration(minutes: minutes);
}

final Map<String, WorkoutDay> _workoutDatabase = {

  // ===== DAILY CHALLENGE =====

  'Push Day': WorkoutDay(
    dayName: 'Push Day',
    sectionName: 'Push Day — Chest & Triceps',
    bodyParts: ['Chest', 'Shoulder', 'Tricep'],
    exercises: [
      ExerciseDetail(name: 'Push Up', sets: 3, reps: 15),
      ExerciseDetail(name: 'Bench Press', sets: 4, reps: 10),
      ExerciseDetail(name: 'Incline Press', sets: 3, reps: 10),
      ExerciseDetail(name: 'Dumbbell Fly', sets: 3, reps: 12),
      ExerciseDetail(name: 'Pec Deck', sets: 3, reps: 12),
      ExerciseDetail(name: 'Military Press', sets: 3, reps: 10),
      ExerciseDetail(name: 'Lateral Raise', sets: 3, reps: 15),
      ExerciseDetail(name: 'Tricep Pushdown', sets: 3, reps: 12),
      ExerciseDetail(name: 'Skull Crusher', sets: 3, reps: 10),
    ],
  ),

  'Pull Day': WorkoutDay(
    dayName: 'Pull Day',
    sectionName: 'Pull Day — Back & Biceps',
    bodyParts: ['Back', 'Bicep'],
    exercises: [
      ExerciseDetail(name: 'Pull Up', sets: 4, reps: 8),
      ExerciseDetail(name: 'Bent Over Row', sets: 4, reps: 10),
      ExerciseDetail(name: 'Lat Pulldown', sets: 3, reps: 12),
      ExerciseDetail(name: 'Seated Row', sets: 3, reps: 12),
      ExerciseDetail(name: 'Single Arm Row', sets: 3, reps: 10),
      ExerciseDetail(name: 'Reverse Fly', sets: 3, reps: 15),
      ExerciseDetail(name: 'Barbell Curl', sets: 3, reps: 12),
      ExerciseDetail(name: 'Hammer Curl', sets: 3, reps: 12),
      ExerciseDetail(name: 'Concentration Curl', sets: 3, reps: 10),
    ],
  ),

  'Leg Day': WorkoutDay(
    dayName: 'Leg Day',
    sectionName: 'Leg Day — Lower Body',
    bodyParts: ['Leg'],
    exercises: [
      ExerciseDetail(name: 'Squat', sets: 4, reps: 10),
      ExerciseDetail(name: 'Leg Press', sets: 4, reps: 12),
      ExerciseDetail(name: 'Lunge', sets: 3, reps: 12),
      ExerciseDetail(name: 'Bulgarian Split Squat', sets: 3, reps: 10),
      ExerciseDetail(name: 'Leg Curl', sets: 3, reps: 12),
      ExerciseDetail(name: 'Leg Extension', sets: 3, reps: 15),
      ExerciseDetail(name: 'Hip Thrust', sets: 3, reps: 12),
      ExerciseDetail(name: 'Calf Raise', sets: 4, reps: 20),
      ExerciseDetail(name: 'Box Jump', sets: 3, reps: 8),
    ],
  ),

  'Full Body\nBlast': WorkoutDay(
    dayName: 'Full Body Blast',
    sectionName: 'Full Body Blast — Total Conditioning',
    bodyParts: ['Chest', 'Back', 'Leg', 'Shoulder', 'Abs'],
    exercises: [
      ExerciseDetail(name: 'Squat', sets: 4, reps: 10),
      ExerciseDetail(name: 'Bench Press', sets: 3, reps: 10),
      ExerciseDetail(name: 'Deadlift', sets: 3, reps: 8),
      ExerciseDetail(name: 'Pull Up', sets: 3, reps: 8),
      ExerciseDetail(name: 'Military Press', sets: 3, reps: 10),
      ExerciseDetail(name: 'Lunge', sets: 3, reps: 12),
      ExerciseDetail(name: 'Bent Over Row', sets: 3, reps: 10),
      ExerciseDetail(name: 'Plank', sets: 3, reps: 45),
      ExerciseDetail(name: 'Push Up', sets: 3, reps: 15),
      ExerciseDetail(name: 'Crunches', sets: 3, reps: 20),
    ],
  ),

  'HIIT\nCardio': WorkoutDay(
    dayName: 'HIIT Cardio',
    sectionName: 'HIIT Cardio — Fat Burner',
    bodyParts: ['Abs', 'Leg'],
    exercises: [
      ExerciseDetail(name: 'Mountain Climber', sets: 4, reps: 30),
      ExerciseDetail(name: 'Box Jump', sets: 4, reps: 10),
      ExerciseDetail(name: 'Flutter Kick', sets: 3, reps: 30),
      ExerciseDetail(name: 'Squat', sets: 4, reps: 15),
      ExerciseDetail(name: 'V-Up', sets: 3, reps: 15),
      ExerciseDetail(name: 'Lunge', sets: 3, reps: 20),
      ExerciseDetail(name: 'Russian Twist', sets: 3, reps: 20),
      ExerciseDetail(name: 'Leg Raise', sets: 3, reps: 15),
    ],
  ),

  // ===== WORKOUT LIBRARY — BEGINNER =====

  'ARM BEGINNER': WorkoutDay(
    dayName: 'ARM BEGINNER',
    sectionName: 'Arm — Beginner',
    bodyParts: ['Bicep', 'Tricep'],
    exercises: [
      ExerciseDetail(name: 'Dumbbell Curl', sets: 3, reps: 12),
      ExerciseDetail(name: 'Hammer Curl', sets: 3, reps: 12),
      ExerciseDetail(name: 'Barbell Curl', sets: 3, reps: 10),
      ExerciseDetail(name: 'Concentration Curl', sets: 3, reps: 10),
      ExerciseDetail(name: 'Reverse Curl', sets: 3, reps: 12),
      ExerciseDetail(name: 'Zottman Curl', sets: 3, reps: 10),
      ExerciseDetail(name: 'Tricep Dip', sets: 3, reps: 10),
      ExerciseDetail(name: 'Tricep Pushdown', sets: 3, reps: 12),
      ExerciseDetail(name: 'Overhead Extension', sets: 3, reps: 12),
      ExerciseDetail(name: 'Bench Dip', sets: 3, reps: 12),
      ExerciseDetail(name: 'Tricep Kickback', sets: 3, reps: 12),
      ExerciseDetail(name: 'Close Grip Bench Press', sets: 3, reps: 10),
    ],
  ),

  'PUSH BEGINNER': WorkoutDay(
    dayName: 'PUSH BEGINNER',
    sectionName: 'Push — Beginner',
    bodyParts: ['Chest', 'Shoulder', 'Tricep'],
    exercises: [
      ExerciseDetail(name: 'Push Up', sets: 3, reps: 15),
      ExerciseDetail(name: 'Bench Press', sets: 3, reps: 10),
      ExerciseDetail(name: 'Incline Press', sets: 3, reps: 10),
      ExerciseDetail(name: 'Dumbbell Fly', sets: 3, reps: 12),
      ExerciseDetail(name: 'Pec Deck', sets: 3, reps: 12),
      ExerciseDetail(name: 'Military Press', sets: 3, reps: 10),
      ExerciseDetail(name: 'Lateral Raise', sets: 3, reps: 15),
      ExerciseDetail(name: 'Front Raise', sets: 3, reps: 12),
      ExerciseDetail(name: 'Arnold Press', sets: 3, reps: 10),
      ExerciseDetail(name: 'Tricep Pushdown', sets: 3, reps: 12),
      ExerciseDetail(name: 'Bench Dip', sets: 3, reps: 12),
      ExerciseDetail(name: 'Overhead Extension', sets: 3, reps: 12),
    ],
  ),

  'PULL BEGINNER': WorkoutDay(
    dayName: 'PULL BEGINNER',
    sectionName: 'Pull — Beginner',
    bodyParts: ['Back', 'Bicep'],
    exercises: [
      ExerciseDetail(name: 'Lat Pulldown', sets: 3, reps: 12),
      ExerciseDetail(name: 'Seated Row', sets: 3, reps: 12),
      ExerciseDetail(name: 'Bent Over Row', sets: 3, reps: 10),
      ExerciseDetail(name: 'Single Arm Row', sets: 3, reps: 10),
      ExerciseDetail(name: 'Back Extension', sets: 3, reps: 12),
      ExerciseDetail(name: 'Reverse Fly', sets: 3, reps: 15),
      ExerciseDetail(name: 'Pull Up', sets: 3, reps: 6),
      ExerciseDetail(name: 'Dumbbell Curl', sets: 3, reps: 12),
      ExerciseDetail(name: 'Hammer Curl', sets: 3, reps: 12),
      ExerciseDetail(name: 'Barbell Curl', sets: 3, reps: 10),
      ExerciseDetail(name: 'Preacher Curl', sets: 3, reps: 10),
      ExerciseDetail(name: 'Concentration Curl', sets: 3, reps: 10),
    ],
  ),

  'LEG BEGINNER': WorkoutDay(
    dayName: 'LEG BEGINNER',
    sectionName: 'Leg — Beginner',
    bodyParts: ['Leg'],
    exercises: [
      ExerciseDetail(name: 'Squat', sets: 3, reps: 12),
      ExerciseDetail(name: 'Leg Press', sets: 3, reps: 12),
      ExerciseDetail(name: 'Lunge', sets: 3, reps: 12),
      ExerciseDetail(name: 'Leg Extension', sets: 3, reps: 15),
      ExerciseDetail(name: 'Leg Curl', sets: 3, reps: 12),
      ExerciseDetail(name: 'Calf Raise', sets: 3, reps: 20),
      ExerciseDetail(name: 'Hip Thrust', sets: 3, reps: 12),
      ExerciseDetail(name: 'Box Jump', sets: 3, reps: 8),
      ExerciseDetail(name: 'Bulgarian Split Squat', sets: 3, reps: 10),
      ExerciseDetail(name: 'Leg Press', sets: 3, reps: 10),
      ExerciseDetail(name: 'Squat', sets: 3, reps: 10),
      ExerciseDetail(name: 'Calf Raise', sets: 3, reps: 20),
    ],
  ),

  // ===== WORKOUT LIBRARY — INTERMEDIATE =====

  'ARM INTERMEDIATE': WorkoutDay(
    dayName: 'ARM INTERMEDIATE',
    sectionName: 'Arm — Intermediate',
    bodyParts: ['Bicep', 'Tricep'],
    exercises: [
      ExerciseDetail(name: 'Barbell Curl', sets: 4, reps: 10),
      ExerciseDetail(name: 'Preacher Curl', sets: 4, reps: 10),
      ExerciseDetail(name: 'Incline Curl', sets: 3, reps: 10),
      ExerciseDetail(name: 'Cable Curl', sets: 3, reps: 12),
      ExerciseDetail(name: 'Hammer Curl', sets: 3, reps: 12),
      ExerciseDetail(name: 'Concentration Curl', sets: 3, reps: 10),
      ExerciseDetail(name: 'Zottman Curl', sets: 3, reps: 10),
      ExerciseDetail(name: 'Skull Crusher', sets: 4, reps: 10),
      ExerciseDetail(name: 'Tricep Pushdown', sets: 4, reps: 12),
      ExerciseDetail(name: 'Close Grip Bench Press', sets: 3, reps: 10),
      ExerciseDetail(name: 'Overhead Extension', sets: 3, reps: 12),
      ExerciseDetail(name: 'Tricep Kickback', sets: 3, reps: 12),
      ExerciseDetail(name: 'Bench Dip', sets: 3, reps: 15),
      ExerciseDetail(name: 'Tricep Dip', sets: 3, reps: 12),
    ],
  ),

  'PUSH INTERMEDIATE': WorkoutDay(
    dayName: 'PUSH INTERMEDIATE',
    sectionName: 'Push — Intermediate',
    bodyParts: ['Chest', 'Shoulder', 'Tricep'],
    exercises: [
      ExerciseDetail(name: 'Bench Press', sets: 4, reps: 10),
      ExerciseDetail(name: 'Incline Press', sets: 4, reps: 10),
      ExerciseDetail(name: 'Decline Press', sets: 3, reps: 10),
      ExerciseDetail(name: 'Dumbbell Fly', sets: 3, reps: 12),
      ExerciseDetail(name: 'Cable Crossover', sets: 3, reps: 12),
      ExerciseDetail(name: 'Pec Deck', sets: 3, reps: 12),
      ExerciseDetail(name: 'Chest Dip', sets: 3, reps: 10),
      ExerciseDetail(name: 'Military Press', sets: 4, reps: 10),
      ExerciseDetail(name: 'Arnold Press', sets: 3, reps: 10),
      ExerciseDetail(name: 'Lateral Raise', sets: 3, reps: 15),
      ExerciseDetail(name: 'Upright Row', sets: 3, reps: 12),
      ExerciseDetail(name: 'Skull Crusher', sets: 3, reps: 10),
      ExerciseDetail(name: 'Tricep Pushdown', sets: 3, reps: 12),
      ExerciseDetail(name: 'Close Grip Bench Press', sets: 3, reps: 10),
    ],
  ),

  'PULL INTERMEDIATE': WorkoutDay(
    dayName: 'PULL INTERMEDIATE',
    sectionName: 'Pull — Intermediate',
    bodyParts: ['Back', 'Bicep'],
    exercises: [
      ExerciseDetail(name: 'Pull Up', sets: 4, reps: 8),
      ExerciseDetail(name: 'Bent Over Row', sets: 4, reps: 10),
      ExerciseDetail(name: 'T-Bar Row', sets: 3, reps: 10),
      ExerciseDetail(name: 'Lat Pulldown', sets: 3, reps: 12),
      ExerciseDetail(name: 'Seated Row', sets: 3, reps: 12),
      ExerciseDetail(name: 'Single Arm Row', sets: 3, reps: 10),
      ExerciseDetail(name: 'Rack Pull', sets: 3, reps: 8),
      ExerciseDetail(name: 'Reverse Fly', sets: 3, reps: 15),
      ExerciseDetail(name: 'Barbell Curl', sets: 4, reps: 10),
      ExerciseDetail(name: 'Preacher Curl', sets: 3, reps: 10),
      ExerciseDetail(name: 'Incline Curl', sets: 3, reps: 10),
      ExerciseDetail(name: 'Cable Curl', sets: 3, reps: 12),
      ExerciseDetail(name: 'Hammer Curl', sets: 3, reps: 12),
      ExerciseDetail(name: 'Concentration Curl', sets: 3, reps: 10),
    ],
  ),

  'LEG INTERMEDIATE': WorkoutDay(
    dayName: 'LEG INTERMEDIATE',
    sectionName: 'Leg — Intermediate',
    bodyParts: ['Leg'],
    exercises: [
      ExerciseDetail(name: 'Squat', sets: 4, reps: 10),
      ExerciseDetail(name: 'Leg Press', sets: 4, reps: 12),
      ExerciseDetail(name: 'Bulgarian Split Squat', sets: 3, reps: 10),
      ExerciseDetail(name: 'Lunge', sets: 3, reps: 12),
      ExerciseDetail(name: 'Deadlift', sets: 3, reps: 8),
      ExerciseDetail(name: 'Leg Curl', sets: 3, reps: 12),
      ExerciseDetail(name: 'Leg Extension', sets: 3, reps: 15),
      ExerciseDetail(name: 'Hip Thrust', sets: 4, reps: 12),
      ExerciseDetail(name: 'Box Jump', sets: 3, reps: 8),
      ExerciseDetail(name: 'Calf Raise', sets: 4, reps: 20),
      ExerciseDetail(name: 'Squat', sets: 3, reps: 8),
      ExerciseDetail(name: 'Leg Press', sets: 3, reps: 10),
      ExerciseDetail(name: 'Lunge', sets: 3, reps: 10),
      ExerciseDetail(name: 'Calf Raise', sets: 3, reps: 20),
    ],
  ),

  // ===== WORKOUT LIBRARY — ADVANCE =====

  'ARM ADVANCE': WorkoutDay(
    dayName: 'ARM ADVANCE',
    sectionName: 'Arm — Advance',
    bodyParts: ['Bicep', 'Tricep'],
    exercises: [
      ExerciseDetail(name: 'Barbell Curl', sets: 5, reps: 8),
      ExerciseDetail(name: 'Preacher Curl', sets: 4, reps: 8),
      ExerciseDetail(name: 'Incline Curl', sets: 4, reps: 8),
      ExerciseDetail(name: 'Cable Curl', sets: 4, reps: 10),
      ExerciseDetail(name: 'Concentration Curl', sets: 3, reps: 10),
      ExerciseDetail(name: 'Zottman Curl', sets: 3, reps: 8),
      ExerciseDetail(name: 'Reverse Curl', sets: 3, reps: 10),
      ExerciseDetail(name: 'Hammer Curl', sets: 4, reps: 10),
      ExerciseDetail(name: 'Close Grip Bench Press', sets: 5, reps: 8),
      ExerciseDetail(name: 'Skull Crusher', sets: 4, reps: 8),
      ExerciseDetail(name: 'Tricep Pushdown', sets: 4, reps: 10),
      ExerciseDetail(name: 'Overhead Extension', sets: 4, reps: 10),
      ExerciseDetail(name: 'Tricep Dip', sets: 4, reps: 12),
      ExerciseDetail(name: 'Tricep Kickback', sets: 3, reps: 12),
      ExerciseDetail(name: 'Cable Curl', sets: 3, reps: 12),
      ExerciseDetail(name: 'Bench Dip', sets: 3, reps: 15),
    ],
  ),

  'PUSH ADVANCE': WorkoutDay(
    dayName: 'PUSH ADVANCE',
    sectionName: 'Push — Advance',
    bodyParts: ['Chest', 'Shoulder', 'Tricep'],
    exercises: [
      ExerciseDetail(name: 'Bench Press', sets: 5, reps: 6),
      ExerciseDetail(name: 'Incline Press', sets: 4, reps: 8),
      ExerciseDetail(name: 'Decline Press', sets: 4, reps: 8),
      ExerciseDetail(name: 'Dumbbell Fly', sets: 4, reps: 10),
      ExerciseDetail(name: 'Cable Crossover', sets: 4, reps: 12),
      ExerciseDetail(name: 'Pec Deck', sets: 3, reps: 12),
      ExerciseDetail(name: 'Chest Dip', sets: 4, reps: 10),
      ExerciseDetail(name: 'Push Up', sets: 3, reps: 20),
      ExerciseDetail(name: 'Military Press', sets: 5, reps: 6),
      ExerciseDetail(name: 'Arnold Press', sets: 4, reps: 8),
      ExerciseDetail(name: 'Lateral Raise', sets: 4, reps: 15),
      ExerciseDetail(name: 'Rear Delt Fly', sets: 3, reps: 15),
      ExerciseDetail(name: 'Upright Row', sets: 3, reps: 10),
      ExerciseDetail(name: 'Close Grip Bench Press', sets: 4, reps: 8),
      ExerciseDetail(name: 'Skull Crusher', sets: 4, reps: 8),
      ExerciseDetail(name: 'Tricep Pushdown', sets: 4, reps: 10),
    ],
  ),

  'PULL ADVANCE': WorkoutDay(
    dayName: 'PULL ADVANCE',
    sectionName: 'Pull — Advance',
    bodyParts: ['Back', 'Bicep'],
    exercises: [
      ExerciseDetail(name: 'Deadlift', sets: 5, reps: 5),
      ExerciseDetail(name: 'Pull Up', sets: 5, reps: 8),
      ExerciseDetail(name: 'Bent Over Row', sets: 4, reps: 8),
      ExerciseDetail(name: 'T-Bar Row', sets: 4, reps: 8),
      ExerciseDetail(name: 'Rack Pull', sets: 4, reps: 6),
      ExerciseDetail(name: 'Lat Pulldown', sets: 4, reps: 10),
      ExerciseDetail(name: 'Seated Row', sets: 3, reps: 10),
      ExerciseDetail(name: 'Single Arm Row', sets: 3, reps: 8),
      ExerciseDetail(name: 'Back Extension', sets: 3, reps: 12),
      ExerciseDetail(name: 'Reverse Fly', sets: 3, reps: 15),
      ExerciseDetail(name: 'Barbell Curl', sets: 4, reps: 8),
      ExerciseDetail(name: 'Preacher Curl', sets: 4, reps: 8),
      ExerciseDetail(name: 'Incline Curl', sets: 3, reps: 8),
      ExerciseDetail(name: 'Cable Curl', sets: 3, reps: 10),
      ExerciseDetail(name: 'Hammer Curl', sets: 3, reps: 10),
      ExerciseDetail(name: 'Concentration Curl', sets: 3, reps: 8),
    ],
  ),

  'LEG ADVANCE': WorkoutDay(
    dayName: 'LEG ADVANCE',
    sectionName: 'Leg — Advance',
    bodyParts: ['Leg'],
    exercises: [
      ExerciseDetail(name: 'Squat', sets: 5, reps: 6),
      ExerciseDetail(name: 'Deadlift', sets: 4, reps: 6),
      ExerciseDetail(name: 'Bulgarian Split Squat', sets: 4, reps: 8),
      ExerciseDetail(name: 'Leg Press', sets: 4, reps: 10),
      ExerciseDetail(name: 'Lunge', sets: 4, reps: 10),
      ExerciseDetail(name: 'Hip Thrust', sets: 4, reps: 10),
      ExerciseDetail(name: 'Box Jump', sets: 4, reps: 8),
      ExerciseDetail(name: 'Leg Curl', sets: 4, reps: 10),
      ExerciseDetail(name: 'Leg Extension', sets: 4, reps: 12),
      ExerciseDetail(name: 'Calf Raise', sets: 5, reps: 20),
      ExerciseDetail(name: 'Squat', sets: 3, reps: 5),
      ExerciseDetail(name: 'Bulgarian Split Squat', sets: 3, reps: 8),
      ExerciseDetail(name: 'Hip Thrust', sets: 3, reps: 10),
      ExerciseDetail(name: 'Leg Press', sets: 3, reps: 8),
      ExerciseDetail(name: 'Box Jump', sets: 3, reps: 6),
      ExerciseDetail(name: 'Calf Raise', sets: 3, reps: 20),
    ],
  ),
};

// ==================== END WORKOUT DATABASE ====================

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
  WorkoutDay? _todayWorkout;
  bool _isLoadingWorkout = true;
  String _userName = "Guest";
  String _userInitial = "G";

  final List<String> levels = ["Beginner", "Intermediate", "Advance"];
  late PageController _pageController;

  final List<Map<String, String>> workouts = [
    {"title": "ARM BEGINNER", "level": "Beginner", "duration": "60 min", "exercises": "12", "image": "assets/arm1.png"},
    {"title": "PUSH BEGINNER", "level": "Beginner", "duration": "60 min", "exercises": "12", "image": "assets/chest1.png"},
    {"title": "PULL BEGINNER", "level": "Beginner", "duration": "60 min", "exercises": "12", "image": "assets/back1.png"},
    {"title": "LEG BEGINNER", "level": "Beginner", "duration": "60 min", "exercises": "12", "image": "assets/leg1.png"},
    {"title": "ARM INTERMEDIATE", "level": "Intermediate", "duration": "70 min", "exercises": "14", "image": "assets/arm2.png"},
    {"title": "PUSH INTERMEDIATE", "level": "Intermediate", "duration": "70 min", "exercises": "14", "image": "assets/chest2.png"},
    {"title": "PULL INTERMEDIATE", "level": "Intermediate", "duration": "70 min", "exercises": "14", "image": "assets/back2.png"},
    {"title": "LEG INTERMEDIATE", "level": "Intermediate", "duration": "70 min", "exercises": "14", "image": "assets/leg2.png"},
    {"title": "ARM ADVANCE", "level": "Advance", "duration": "80 min", "exercises": "16", "image": "assets/arm3.png"},
    {"title": "PUSH ADVANCE", "level": "Advance", "duration": "80 min", "exercises": "16", "image": "assets/chest3.png"},
    {"title": "PULL ADVANCE", "level": "Advance", "duration": "80 min", "exercises": "16", "image": "assets/back.webp"},
    {"title": "LEG ADVANCE", "level": "Advance", "duration": "80 min", "exercises": "16", "image": "assets/leg3.png"},
  ];

  final List<Map<String, dynamic>> challenges = [
    {"title": "Push Day", "subtitle": "Chest & Triceps", "description": "Bangun kekuatan dada, bahu, dan trisep dengan program push day terbaik.", "duration": "35 Min", "level": "Beginner", "gradientColors": [Color(0xFF1E3A5F), Color(0xFF1A5496), Color(0xFF2B7DE9)], "accentColor": AppColors.blue},
    {"title": "Pull Day", "subtitle": "Back & Biceps", "description": "Perkuat otot punggung dan lengan dengan latihan pull yang intens.", "duration": "40 Min", "level": "Intermediate", "gradientColors": [Color(0xFF2D1B69), Color(0xFF4A2DB5), Color(0xFF6C5CE7)], "accentColor": AppColors.purple},
    {"title": "Leg Day", "subtitle": "Lower Body", "description": "Bangun kekuatan kaki dan glutes dengan squat & deadlift intensif.", "duration": "45 Min", "level": "Advanced", "gradientColors": [Color(0xFF0A2E2E), Color(0xFF0F5050), Color(0xFF1D9E75)], "accentColor": AppColors.green},
    {"title": "Full Body\nBlast", "subtitle": "Total Conditioning", "description": "Latihan seluruh tubuh yang komprehensif untuk kebugaran optimal.", "duration": "50 Min", "level": "Advanced", "gradientColors": [Color(0xFF2E1A0A), Color(0xFF7A3A10), Color(0xFFD4803A)], "accentColor": AppColors.orange},
    {"title": "HIIT\nCardio", "subtitle": "Fat Burner", "description": "Bakar lemak maksimal dengan interval training intensitas tinggi.", "duration": "25 Min", "level": "Intermediate", "gradientColors": [Color(0xFF3A0A0A), Color(0xFF8B2200), Color(0xFFD85A30)], "accentColor": AppColors.red},
  ];

  @override
  void initState() {
    super.initState();
    currentDate = DateTime.now();
    _generateWeekDays();
    _loadUserData();
    _pageController = PageController(initialPage: levels.indexOf(selectedLevel));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTodayWorkout();
      _centerCurrentDate();
    });
  }
  
  void _centerCurrentDate() {
    int todayIndex = weekDays.indexWhere((date) =>
        date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day);
    if (todayIndex != -1) selectedDayIndex = todayIndex;
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? "";
    String name = prefs.getString('username') ?? "";
    if (name.isEmpty && email.isNotEmpty) name = email.split('@')[0];
    if (name.isNotEmpty) {
      setState(() {
        _userName = name;
        _userInitial = name.substring(0, 1).toUpperCase();
      });
    }
  }

  Future<void> _loadTodayWorkout() async {
    if (!mounted) return;
    setState(() => _isLoadingWorkout = true);
    try {
      final workout = await WorkoutStorage.getWorkoutForDay(DateFormat('EEEE').format(DateTime.now()));
      if (mounted) setState(() {
        _todayWorkout = workout;
        _isLoadingWorkout = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingWorkout = false);
    }
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
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text("Set Timer", style: AppTextStyles.headingH4),
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: CustomButton(
                  text: "Confirm",
                  onPressed: () => Navigator.pop(context),
                  width: double.infinity,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _startWorkout(WorkoutDay workout) {
    if (!_isTimerSet || (_timerMinutes == 0 && _timerSeconds == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please set timer first"), backgroundColor: AppColors.error),
      );
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
    ).then((_) => _loadTodayWorkout());
  }

  Future<void> _refreshData() async => _loadTodayWorkout();

  void _showChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Chat Support"),
        content: TextField(
          style: const TextStyle(color: AppColors.textPrimary),
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Describe your problem...",
            hintStyle: TextStyle(color: AppColors.textDisabled),
            filled: true,
            fillColor: AppColors.border,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          CustomButton(
            text: "Send",
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Message sent. We'll respond soon."), backgroundColor: AppColors.success),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('d MMMM yyyy').format(now);
    final dayName = DateFormat('EEEE').format(now);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildChipsRow(),
                      const SizedBox(height: 28),
                      _buildDateSection(dayName, formattedDate),
                      const SizedBox(height: 20),
                      _buildCalendar(),
                      const SizedBox(height: 28),
                      _buildSectionTitle("Today's Activity"),
                      const SizedBox(height: 16),
                      _buildTodayActivitySection(),
                      const SizedBox(height: 28),
                      _buildSectionTitle("Daily Challenge"),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildDailyChallenge()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 28),
                      _buildSectionTitle("Have a plan?"),
                      const SizedBox(height: 16),
                      _buildTimerCard(),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: "Create Workout",
                        onPressed: widget.onCreateWorkout ?? () {},
                        width: double.infinity,
                      ),
                      const SizedBox(height: 28),
                      _buildSectionTitle("Workout Library"),
                      const SizedBox(height: 16),
                      _buildLevelSelector(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 600,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => selectedLevel = levels[index]),
                    itemCount: levels.length,
                    itemBuilder: (context, index) {
                      final filtered = workouts.where((w) => w["level"] == levels[index]).toList();
                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildWorkoutCard(filtered[i]),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  child: _buildComplaintSection(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyChallenge() {
    return SizedBox(
      height: 340,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: challenges.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, index) {
          final c = challenges[index];
          final List<Color> gradientColors = (c['gradientColors'] as List).cast<Color>();
          final Color accentColor = c['accentColor'] as Color;
          return Container(
            width: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: _CardGeoPainter(accentColor: accentColor))),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildCardChip(c['duration'], Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.9), border: Colors.white.withOpacity(0.2)),
                            const SizedBox(width: 8),
                            _buildCardChip(c['level'].toUpperCase(), accentColor.withOpacity(0.2), AppColors.primary, border: AppColors.primary.withOpacity(0.4)),
                          ],
                        ),
                        const Spacer(),
                        Text(c['title'], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, height: 0.95)),
                        const SizedBox(height: 10),
                        Text(c['description'], maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75))),
                        const SizedBox(height: 16),
                        _buildChallengeCTA(accentColor, c['title'] as String, c['duration'] as String),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardChip(String text, Color bg, Color textColor, {required Color border}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor)),
    );
  }

  Widget _buildChallengeCTA(Color accentColor, String challengeTitle, String durationStr) {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () {
            final workout = _workoutDatabase[challengeTitle];
            if (workout == null) return;
            if (!_isTimerSet || (_timerMinutes == 0 && _timerSeconds == 0)) {
              final duration = _parseDuration(durationStr);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkoutSessionScreen(
                    workout: workout,
                    initialDuration: duration,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkoutSessionScreen(
                    workout: workout,
                    initialDuration: Duration(minutes: _timerMinutes, seconds: _timerSeconds),
                  ),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('START NOW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1, color: accentColor)),
                Container(width: 28, height: 28, decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle), child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintSection() {
    return GestureDetector(
      onTap: _showChatDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Center(child: Text("Tidak menemukan latihan mu? Chat Admin", style: TextStyle(fontSize: 13, color: AppColors.primary))),
      ),
    );
  }

  Widget _buildLevelSelector() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: levels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final level = levels[index];
          final isSelected = selectedLevel == level;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedLevel = level;
                _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: isSelected ? Colors.transparent : AppColors.border),
              ),
              child: Center(
                child: Text(level,
                  style: TextStyle(
                    color: isSelected ? Colors.black : AppColors.textHint,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayActivitySection() {
    if (_isLoadingWorkout) {
      return const CustomCard(
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    if (_todayWorkout != null) return _buildTodayWorkoutCard(_todayWorkout!);
    return _buildEmptyWorkoutCard();
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])),
          child: Center(child: Text(_userInitial, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_userName, style: AppTextStyles.bodyLarge),
              const Text("Have a productive workout day!", style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        GestureDetector(
          onTap: _showChatDialog,
          child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)), child: Icon(Icons.chat_bubble_outline, size: 22, color: AppColors.primary)),
        ),
      ],
    );
  }

  Widget _buildChipsRow() {
    return _horizontalScroll(
      spacing: 10,
      children: [
        _buildChip("Advanced", AppColors.purple),
        _buildChip("Training Days", AppColors.primary),
        _buildChip("Community", AppColors.blue),
      ],
    );
  }

  Widget _horizontalScroll({required List<Widget> children, double spacing = 0}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(children.length * 2 - 1, (index) {
          if (index.isOdd) return SizedBox(width: spacing);
          return children[index ~/ 2];
        }),
      ),
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color)),
    );
  }

  Widget _buildDateSection(String dayName, String formattedDate) {
    return Center(
      child: Column(
        children: [
          Text(dayName.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary, letterSpacing: 1)),
          const SizedBox(height: 6),
          Text(formattedDate, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return SizedBox(
      height: 84,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(width: 20),
          ...List.generate(weekDays.length, (i) {
            final date = weekDays[i];
            final isSelected = i == selectedDayIndex;
            return GestureDetector(
              onTap: () => setState(() { selectedDayIndex = i; currentDate = date; }),
              child: Container(
                width: 68, height: 84, margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isSelected ? AppColors.primary : AppColors.surface,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(DateFormat('E').format(date), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isSelected ? Colors.black : AppColors.textHint)),
                    const SizedBox(height: 6),
                    Text(date.day.toString(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isSelected ? Colors.black : AppColors.textPrimary)),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
  }

  Widget _buildTodayWorkoutCard(WorkoutDay workout) {
    return CustomCard(
      borderColor: AppColors.primary.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.fitness_center, color: AppColors.primary, size: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(workout.sectionName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text("${workout.exercises.length} exercises", style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: workout.bodyParts.map((part) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(8)), child: Text(part, style: const TextStyle(fontSize: 11, color: AppColors.primary)))).toList(),
          ),
          const SizedBox(height: 14),
          CustomButton(text: "Start", onPressed: () => _startWorkout(workout), isOutlined: true, width: double.infinity),
        ],
      ),
    );
  }

  Widget _buildEmptyWorkoutCard() {
    return CustomCard(
      child: Column(
        children: [
          const Icon(Icons.calendar_today, size: 40, color: AppColors.textDisabled),
          const SizedBox(height: 12),
          const Text("No workout planned for today", style: AppTextStyles.bodyMedium),
          const SizedBox(height: 12),
          CustomButton(text: "Create Plan", onPressed: widget.onCreateWorkout ?? () {}),
        ],
      ),
    );
  }

  Widget _buildTimerCard() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 12, spreadRadius: 2)]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.asset('assets/time.jpg', height: 120, width: double.infinity, fit: BoxFit.cover),
            Container(height: 120, decoration: BoxDecoration(color: AppColors.purple.withOpacity(0.85))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("WORKOUT TIMER", style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(_isTimerSet ? Formatter.formatTimer(_timerMinutes, _timerSeconds) : "00:00", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: _showTimerPicker,
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.textPrimary, side: const BorderSide(color: AppColors.primary, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))),
                    child: const Text("SET", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(Map<String, String> workout) {
    final level = workout["level"]!;
    final levelColor = level == "Beginner" ? AppColors.blue : level == "Intermediate" ? AppColors.purple : AppColors.red;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: levelColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(workout["image"]!, height: 140, width: double.infinity, fit: BoxFit.cover),
                Container(height: 140, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.7)]))),
                Positioned(top: 12, right: 12, child: Container(width: 36, height: 36, decoration: BoxDecoration(color: levelColor.withOpacity(0.2), borderRadius: BorderRadius.circular(18), border: Border.all(color: levelColor, width: 1.5)), child: const Icon(Icons.flash_on, color: Colors.white, size: 18))),
                Positioned(bottom: 12, left: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: levelColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: levelColor, blurRadius: 6, spreadRadius: 1)]), child: Text(level, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)))),
              ],
            ),
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout["title"]!, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildSportyIcon(Icons.timer_outlined, workout["duration"]!, levelColor),
                      const SizedBox(width: 16),
                      _buildSportyIcon(Icons.repeat, "${workout["exercises"]} ex", levelColor),
                    ],
                  ),
                  const SizedBox(height: 14),
                  CustomButton(
                    text: "START",
                    onPressed: () {
                      final workoutData = _workoutDatabase[workout['title']];
                      if (workoutData == null) return;
                      final duration = _isTimerSet && (_timerMinutes > 0 || _timerSeconds > 0)
                          ? Duration(minutes: _timerMinutes, seconds: _timerSeconds)
                          : _parseDuration(workout['duration']!);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutSessionScreen(
                            workout: workoutData,
                            initialDuration: duration,
                          ),
                        ),
                      );
                    },
                    backgroundColor: AppColors.primary,
                    textColor: Colors.black,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportyIcon(IconData icon, String text, Color color) {
    return Row(children: [Icon(icon, size: 14, color: color), const SizedBox(width: 6), Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _CardGeoPainter extends CustomPainter {
  final Color accentColor;
  const _CardGeoPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final circlePaint = Paint()..color = Colors.white.withOpacity(0.06)..style = PaintingStyle.stroke..strokeWidth = 36;
    canvas.drawCircle(Offset(w * 0.85, h * 0.22), w * 0.52, circlePaint);
    final circlePaint2 = Paint()..color = Colors.white.withOpacity(0.04)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawCircle(Offset(w * 0.85, h * 0.22), w * 0.34, circlePaint2);
    final bandPaint = Paint()..color = Colors.white.withOpacity(0.055)..style = PaintingStyle.fill;
    final band1 = Path()..moveTo(0, h * 0.62)..lineTo(w * 0.28, h * 0.38)..lineTo(w * 0.28 + 18, h * 0.38)..lineTo(18, h * 0.62)..close();
    canvas.drawPath(band1, bandPaint);
    final band2 = Paint()..color = Colors.white.withOpacity(0.035);
    final band2Path = Path()..moveTo(0, h * 0.70)..lineTo(w * 0.22, h * 0.50)..lineTo(w * 0.22 + 12, h * 0.50)..lineTo(12, h * 0.70)..close();
    canvas.drawPath(band2Path, band2..style = PaintingStyle.fill);
    final dotPaint = Paint()..color = Colors.white.withOpacity(0.12)..style = PaintingStyle.fill;
    for (int row = 0; row < 3; row++) for (int col = 0; col < 3; col++) canvas.drawCircle(Offset(22.0 + col * 18, 26.0 + row * 18), 2.2, dotPaint);
    final barPaint = Paint()..color = accentColor.withOpacity(0.5)..strokeCap = StrokeCap.round..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, h * 0.77, w * 0.38, 4), const Radius.circular(2)), barPaint);
    final crossPaint = Paint()..color = Colors.white.withOpacity(0.2)..strokeWidth = 1.8..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.88, h * 0.87), Offset(w * 0.96, h * 0.87), crossPaint);
    canvas.drawLine(Offset(w * 0.92, h * 0.83), Offset(w * 0.92, h * 0.91), crossPaint);
    final linePaint = Paint()..color = AppColors.primary.withOpacity(0.15)..strokeWidth = 2.0..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.60, h * 0.08), Offset(w * 0.82, h * 0.02), linePaint);
    final linePaint2 = Paint()..color = AppColors.primary.withOpacity(0.08)..strokeWidth = 1.5..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.63, h * 0.12), Offset(w * 0.88, h * 0.06), linePaint2);
  }

  @override
  bool shouldRepaint(_CardGeoPainter old) => old.accentColor != accentColor;
}