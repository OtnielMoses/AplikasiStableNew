import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseDetail {
  String name;
  int sets;
  int reps;

  ExerciseDetail({required this.name, required this.sets, required this.reps});

  // Konversi ke Map (untuk JSON)
  Map<String, dynamic> toJson() => {
        'name': name,
        'sets': sets,
        'reps': reps,
      };

  // Konversi dari Map (dari JSON)
  factory ExerciseDetail.fromJson(Map<String, dynamic> json) => ExerciseDetail(
        name: json['name'] as String,
        sets: json['sets'] as int,
        reps: json['reps'] as int,
      );
}

class WorkoutDay {
  final String dayName;
  final List<String> bodyParts;
  final List<ExerciseDetail> exercises;
  final String sectionName;

  WorkoutDay({
    required this.dayName,
    required this.bodyParts,
    required this.exercises,
    required this.sectionName,
  });

  Map<String, dynamic> toJson() => {
        'dayName': dayName,
        'bodyParts': bodyParts,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'sectionName': sectionName,
      };

  factory WorkoutDay.fromJson(Map<String, dynamic> json) => WorkoutDay(
        dayName: json['dayName'] as String,
        bodyParts: List<String>.from(json['bodyParts']),
        exercises: (json['exercises'] as List)
            .map((e) => ExerciseDetail.fromJson(e as Map<String, dynamic>))
            .toList(),
        sectionName: json['sectionName'] as String,
      );
}

class WorkoutStorage {
  static const String _key = 'workout_plan';

  static Future<void> saveWorkout(WorkoutDay workout) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? existing = prefs.getStringList(_key);
    List<WorkoutDay> list = existing != null
        ? existing.map((e) => WorkoutDay.fromJson(jsonDecode(e))).toList()
        : [];
    // Hapus jika sudah ada hari yang sama
    list.removeWhere((w) => w.dayName == workout.dayName);
    list.add(workout);
    // Serialisasi ke JSON string
    final List<String> encoded = list.map((w) => jsonEncode(w.toJson())).toList();
    await prefs.setStringList(_key, encoded);
    print("Workout saved for ${workout.dayName}: ${workout.exercises.length} exercises"); // debug
  }

  static Future<WorkoutDay?> getWorkoutForDay(String dayName) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? list = prefs.getStringList(_key);
    if (list == null) return null;
    final workouts = list.map((e) => WorkoutDay.fromJson(jsonDecode(e))).toList();
    try {
      return workouts.firstWhere((w) => w.dayName == dayName);
    } catch (_) {
      return null;
    }
  }

  static Future<List<WorkoutDay>> getAllWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? list = prefs.getStringList(_key);
    if (list == null) return [];
    return list.map((e) => WorkoutDay.fromJson(jsonDecode(e))).toList();
  }
}

// ========== DATABASE LATIHAN (tetap) ==========
class Exercise {
  final String name;
  final String category;
  Exercise({required this.name, required this.category});
}

final List<Exercise> exerciseDatabase = [
  // Back
  Exercise(name: "Pull Up", category: "Back"),
  Exercise(name: "Lat Pulldown", category: "Back"),
  Exercise(name: "Seated Row", category: "Back"),
  Exercise(name: "Bent Over Row", category: "Back"),
  Exercise(name: "T-Bar Row", category: "Back"),
  Exercise(name: "Deadlift", category: "Back"),
  Exercise(name: "Back Extension", category: "Back"),
  Exercise(name: "Reverse Fly", category: "Back"),
  Exercise(name: "Single Arm Row", category: "Back"),
  Exercise(name: "Rack Pull", category: "Back"),
  // Bicep
  Exercise(name: "Barbell Curl", category: "Bicep"),
  Exercise(name: "Dumbbell Curl", category: "Bicep"),
  Exercise(name: "Hammer Curl", category: "Bicep"),
  Exercise(name: "Preacher Curl", category: "Bicep"),
  Exercise(name: "Concentration Curl", category: "Bicep"),
  Exercise(name: "Cable Curl", category: "Bicep"),
  Exercise(name: "Incline Curl", category: "Bicep"),
  Exercise(name: "Zottman Curl", category: "Bicep"),
  Exercise(name: "Reverse Curl", category: "Bicep"),
  // Tricep
  Exercise(name: "Tricep Dip", category: "Tricep"),
  Exercise(name: "Tricep Pushdown", category: "Tricep"),
  Exercise(name: "Skull Crusher", category: "Tricep"),
  Exercise(name: "Overhead Extension", category: "Tricep"),
  Exercise(name: "Close Grip Bench Press", category: "Tricep"),
  Exercise(name: "Tricep Kickback", category: "Tricep"),
  Exercise(name: "Bench Dip", category: "Tricep"),
  // Chest
  Exercise(name: "Bench Press", category: "Chest"),
  Exercise(name: "Incline Press", category: "Chest"),
  Exercise(name: "Decline Press", category: "Chest"),
  Exercise(name: "Dumbbell Fly", category: "Chest"),
  Exercise(name: "Chest Dip", category: "Chest"),
  Exercise(name: "Push Up", category: "Chest"),
  Exercise(name: "Cable Crossover", category: "Chest"),
  Exercise(name: "Pec Deck", category: "Chest"),
  // Shoulder
  Exercise(name: "Military Press", category: "Shoulder"),
  Exercise(name: "Lateral Raise", category: "Shoulder"),
  Exercise(name: "Front Raise", category: "Shoulder"),
  Exercise(name: "Rear Delt Fly", category: "Shoulder"),
  Exercise(name: "Upright Row", category: "Shoulder"),
  Exercise(name: "Arnold Press", category: "Shoulder"),
  Exercise(name: "Shrug", category: "Shoulder"),
  // Abs
  Exercise(name: "Crunches", category: "Abs"),
  Exercise(name: "Leg Raise", category: "Abs"),
  Exercise(name: "Plank", category: "Abs"),
  Exercise(name: "Russian Twist", category: "Abs"),
  Exercise(name: "Hanging Leg Raise", category: "Abs"),
  Exercise(name: "Mountain Climber", category: "Abs"),
  Exercise(name: "V-Up", category: "Abs"),
  Exercise(name: "Flutter Kick", category: "Abs"),
  // Leg
  Exercise(name: "Squat", category: "Leg"),
  Exercise(name: "Leg Press", category: "Leg"),
  Exercise(name: "Lunge", category: "Leg"),
  Exercise(name: "Leg Curl", category: "Leg"),
  Exercise(name: "Leg Extension", category: "Leg"),
  Exercise(name: "Calf Raise", category: "Leg"),
  Exercise(name: "Box Jump", category: "Leg"),
  Exercise(name: "Bulgarian Split Squat", category: "Leg"),
  Exercise(name: "Hip Thrust", category: "Leg"),
];

List<String> getExercisesByCategories(List<String> categories) {
  if (categories.isEmpty) return [];
  return exerciseDatabase
      .where((ex) => categories.contains(ex.category))
      .map((ex) => ex.name)
      .toList()
    ..sort();
}