String normalizeMuscle(String muscle) {
  if (muscle == 'Bahu') return 'Bahu & Punggung';
  return muscle;
}

class ExerciseItem {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final String? unit;
  final String muscle;

  ExerciseItem({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    this.unit,
    required this.muscle,
  });

  factory ExerciseItem.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? json['Name'] ?? 'Exercise').toString();
    final id = (json['id'] ?? name.toLowerCase().replaceAll(' ', '-')).toString();
    return ExerciseItem(
      id: id,
      name: name,
      sets: int.tryParse(json['sets']?.toString() ?? '') ?? 3,
      reps: int.tryParse(json['reps']?.toString() ?? '') ?? 10,
      unit: json['unit']?.toString(),
      muscle: normalizeMuscle((json['muscle'] ?? '').toString()),
    );
  }

  String get target => '${sets}x$reps${unit != null ? ' $unit' : ''}';
}

class ScheduledDayPlan {
  final String type; // "workout" | "rest"
  final String title;
  final String muscle;
  final List<ExerciseItem> exercises;

  ScheduledDayPlan({
    required this.type,
    required this.title,
    required this.muscle,
    required this.exercises,
  });

  bool get isRest => type == 'rest';

  factory ScheduledDayPlan.fromJson(Map<String, dynamic> json) {
    final type = json['type'] == 'rest' ? 'rest' : 'workout';
    final exercisesRaw = (json['exercises'] as List?) ?? [];
    return ScheduledDayPlan(
      type: type,
      title: (json['title'] ?? (type == 'rest' ? 'Rest Day' : 'Workout Day')).toString(),
      muscle: normalizeMuscle((json['muscle'] ?? '').toString()),
      exercises: exercisesRaw
          .whereType<Map<String, dynamic>>()
          .map(ExerciseItem.fromJson)
          .toList(),
    );
  }
}