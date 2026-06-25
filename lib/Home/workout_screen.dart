import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/workout_data.dart';

class SelectDayScreen extends StatefulWidget {
  const SelectDayScreen({super.key});

  @override
  State<SelectDayScreen> createState() => _SelectDayScreenState();
}

class _SelectDayScreenState extends State<SelectDayScreen> {
  final List<Map<String, dynamic>> days = const [
    {"name": "Mon", "full": "Monday", "icon": Icons.wb_sunny},
    {"name": "Tue", "full": "Tuesday", "icon": Icons.wb_sunny},
    {"name": "Wed", "full": "Wednesday", "icon": Icons.cloud},
    {"name": "Thu", "full": "Thursday", "icon": Icons.wb_twilight},
    {"name": "Fri", "full": "Friday", "icon": Icons.weekend},
    {"name": "Sat", "full": "Saturday", "icon": Icons.sports_gymnastics},
    {"name": "Sun", "full": "Sunday", "icon": Icons.bedtime},
  ];

  Map<String, WorkoutDay?> workoutMap = {};
  bool _isRestDayToday = false;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
    _checkRestDay();
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _checkRestDay() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _todayString();
    final isRest = prefs.getString('rest_day_date') == todayStr;
    setState(() {
      _isRestDayToday = isRest;
    });
  }

  Future<void> _setRestDay() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _todayString();

    if (prefs.getString('rest_day_date') == todayStr) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Today is already a rest day.")),
      );
      return;
    }

    // Cek apakah sudah workout hari ini
    final lastWorkoutDate = prefs.getString('last_workout_date');
    if (lastWorkoutDate == todayStr) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You already worked out today. Rest day cannot be set.")),
      );
      return;
    }

    // Set rest day
    await prefs.setString('rest_day_date', todayStr);

    // Update streak: rest day mempertahankan streak (tidak menambah, tidak mengurangi)
    // Jika belum ada streak, inisialisasi dengan 0
    final currentStreak = prefs.getInt('streak') ?? 0;
    // Streak tetap, tidak berubah

    setState(() {
      _isRestDayToday = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Rest day set for today. Streak maintained.")),
    );
  }

  Future<void> _loadWorkouts() async {
    final all = await WorkoutStorage.getAllWorkouts();
    final map = <String, WorkoutDay?>{};
    for (var day in days) {
      WorkoutDay? found;
      for (var w in all) {
        if (w.dayName == day['full']) {
          found = w;
          break;
        }
      }
      map[day['full']] = found;
    }
    if (mounted) {
      setState(() => workoutMap = map);
    }
  }

  Future<void> _refreshData() async {
    await _loadWorkouts();
    await _checkRestDay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Select Day", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFD4FF33)),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: Icon(
              _isRestDayToday ? Icons.bedtime : Icons.bedtime_outlined,
              color: _isRestDayToday ? Colors.orange : Colors.white,
            ),
            onPressed: _setRestDay,
            tooltip: "Set Rest Day",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("Choose a day for your workout plan", style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
                  const Spacer(),
                  if (_isRestDayToday)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Text("Rest Day", style: TextStyle(color: Colors.orange, fontSize: 12)),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: days.length,
                      itemBuilder: (context, index) {
                        final day = days[index];
                        final fullName = day['full'];
                        final workout = workoutMap[fullName];
                        return _DayCard(
                          dayName: day['name'],
                          fullName: fullName,
                          icon: day['icon'],
                          workout: workout,
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FilterScreen(
                                  selectedDay: fullName,
                                  existingWorkout: workout,
                                ),
                              ),
                            );
                            if (result == true) {
                              await _refreshData();
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final String dayName;
  final String fullName;
  final IconData icon;
  final WorkoutDay? workout;
  final VoidCallback onTap;

  const _DayCard({
    required this.dayName,
    required this.fullName,
    required this.icon,
    required this.workout,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: workout != null
                ? [const Color(0xFF1A1C24), const Color(0xFF23262F)]
                : [const Color(0xFF12151C), const Color(0xFF1A1C24)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: workout != null ? const Color(0xFFD4FF33) : const Color(0xFF2A2D35),
            width: workout != null ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: workout != null ? const Color(0xFFD4FF33).withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 32, color: workout != null ? const Color(0xFFD4FF33) : const Color(0xFF6B6F7A)),
              ),
              const SizedBox(height: 8),
              Text(dayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 2),
              Text(fullName, style: const TextStyle(fontSize: 10, color: Color(0xFF8E8E93))),
              if (workout != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4FF33).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${workout!.exercises.length} exercises",
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFFD4FF33)),
                  ),
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: workout!.exercises.take(2).map((ex) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          ex.name,
                          style: const TextStyle(fontSize: 9, color: Color(0xFFB0B3B8)),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      )).toList(),
                    ),
                  ),
                ),
                if (workout!.exercises.length > 2)
                  const Text("...", style: TextStyle(fontSize: 9, color: Color(0xFF6B6F7A))),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ===== FILTER SCREEN DAN SETERUSNYA (sama seperti sebelumnya, hanya untuk lengkap) =====

class FilterScreen extends StatefulWidget {
  final String selectedDay;
  final WorkoutDay? existingWorkout;
  const FilterScreen({super.key, required this.selectedDay, this.existingWorkout});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late List<String> selectedCategories;
  final List<Map<String, dynamic>> categories = [
    {"name": "Back", "icon": Icons.fitness_center, "color": const Color(0xFF6C5CE7)},
    {"name": "Bicep", "icon": Icons.handshake, "color": const Color(0xFF4A90E2)},
    {"name": "Tricep", "icon": Icons.fitness_center, "color": const Color(0xFF9B59B6)},
    {"name": "Chest", "icon": Icons.fitness_center, "color": const Color(0xFFFF453A)},
    {"name": "Shoulder", "icon": Icons.accessibility, "color": const Color(0xFF34C759)},
    {"name": "Abs", "icon": Icons.radio_button_unchecked, "color": const Color(0xFFFFD60A)},
    {"name": "Leg", "icon": Icons.accessibility_new, "color": const Color(0xFFFF9500)},
  ];

  @override
  void initState() {
    super.initState();
    selectedCategories = widget.existingWorkout?.bodyParts.toList() ?? [];
  }

  void toggleCategory(String cat) {
    setState(() {
      if (selectedCategories.contains(cat)) {
        selectedCategories.remove(cat);
      } else {
        selectedCategories.add(cat);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Select Body Parts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1C24),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(widget.selectedDay, style: const TextStyle(fontSize: 12, color: Color(0xFFD4FF33))),
            ),
            const SizedBox(height: 20),
            const Text("Choose muscle groups", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 500 ? 2 : 1;
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3.5,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final selected = selectedCategories.contains(cat['name']);
                      return GestureDetector(
                        onTap: () => toggleCategory(cat['name']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: selected ? cat['color'] : const Color(0xFF1A1C24),
                            borderRadius: BorderRadius.circular(14),
                            border: selected ? null : Border.all(color: const Color(0xFF2A2D35)),
                          ),
                          child: Row(
                            children: [
                              Icon(cat['icon'], size: 20, color: selected ? Colors.white : cat['color']),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  cat['name'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: selected ? Colors.white : const Color(0xFFE0E0E0),
                                  ),
                                ),
                              ),
                              if (selected)
                                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (selectedCategories.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Select at least one body part")),
                    );
                    return;
                  }
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SelectExerciseScreen(
                        selectedCategories: selectedCategories,
                        day: widget.selectedDay,
                        existingExercises: widget.existingWorkout?.exercises ?? [],
                      ),
                    ),
                  );
                  if (result == true && mounted) {
                    Navigator.pop(context, true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4FF33),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Continue", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectExerciseScreen extends StatefulWidget {
  final List<String> selectedCategories;
  final String day;
  final List<ExerciseDetail> existingExercises;
  const SelectExerciseScreen({
    super.key,
    required this.selectedCategories,
    required this.day,
    required this.existingExercises,
  });

  @override
  State<SelectExerciseScreen> createState() => _SelectExerciseScreenState();
}

class _SelectExerciseScreenState extends State<SelectExerciseScreen> {
  List<String> selectedExerciseNames = [];
  List<String> availableExercises = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    selectedExerciseNames = widget.existingExercises.map((e) => e.name).toList();
    _updateAvailableExercises();
  }

  void _updateAvailableExercises() {
    availableExercises = getExercisesByCategories(widget.selectedCategories);
    setState(() {});
  }

  List<String> get filteredExercises {
    if (searchQuery.isEmpty) return availableExercises;
    return availableExercises.where((ex) => ex.toLowerCase().contains(searchQuery.toLowerCase())).toList();
  }

  void toggleExercise(String ex) {
    setState(() {
      if (selectedExerciseNames.contains(ex)) {
        selectedExerciseNames.remove(ex);
      } else {
        selectedExerciseNames.add(ex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Select Exercises", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1C24),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Search exercises",
                  hintStyle: const TextStyle(color: Color(0xFF6B6F7A), fontSize: 14),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF6B6F7A), size: 20),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF6B6F7A), size: 18),
                          onPressed: () => setState(() => searchQuery = ""),
                        )
                      : null,
                ),
                onChanged: (value) => setState(() => searchQuery = value),
              ),
            ),
            const SizedBox(height: 16),
            if (widget.selectedCategories.isEmpty)
              const Expanded(child: Center(child: Text("Select body parts first", style: TextStyle(color: Color(0xFF8E8E93)))))
            else if (availableExercises.isEmpty)
              const Expanded(child: Center(child: Text("No exercises for selected categories", style: TextStyle(color: Color(0xFF8E8E93)))))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filteredExercises.length,
                  itemBuilder: (_, i) {
                    final ex = filteredExercises[i];
                    final selected = selectedExerciseNames.contains(ex);
                    return GestureDetector(
                      onTap: () => toggleExercise(ex),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFFD4FF33).withOpacity(0.1) : const Color(0xFF1A1C24),
                          borderRadius: BorderRadius.circular(12),
                          border: selected ? Border.all(color: const Color(0xFFD4FF33), width: 1) : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: selected ? const Color(0xFFD4FF33).withOpacity(0.2) : const Color(0xFF2A2D35),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                selected ? Icons.check : Icons.fitness_center,
                                color: selected ? const Color(0xFFD4FF33) : const Color(0xFF6B6F7A),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ex,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                  color: selected ? const Color(0xFFD4FF33) : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedExerciseNames.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Select at least one exercise")),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SetRepsScreen(
                        exerciseNames: selectedExerciseNames,
                        day: widget.day,
                        bodyParts: widget.selectedCategories,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4FF33),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Next", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Daftar exercise berdasarkan kategori (sama seperti sebelumnya)
List<String> getExercisesByCategories(List<String> categories) {
  final Map<String, List<String>> exerciseMap = {
    'Chest': ['Bench Press', 'Incline Press', 'Decline Press', 'Dumbbell Fly', 'Cable Crossover', 'Pec Deck', 'Chest Dip', 'Push Up'],
    'Back': ['Pull Up', 'Bent Over Row', 'T-Bar Row', 'Lat Pulldown', 'Seated Row', 'Single Arm Row', 'Rack Pull', 'Reverse Fly', 'Back Extension', 'Deadlift'],
    'Shoulder': ['Military Press', 'Arnold Press', 'Lateral Raise', 'Rear Delt Fly', 'Upright Row', 'Front Raise'],
    'Bicep': ['Barbell Curl', 'Preacher Curl', 'Incline Curl', 'Cable Curl', 'Concentration Curl', 'Zottman Curl', 'Reverse Curl', 'Hammer Curl'],
    'Tricep': ['Close Grip Bench Press', 'Skull Crusher', 'Tricep Pushdown', 'Overhead Extension', 'Tricep Dip', 'Tricep Kickback', 'Bench Dip'],
    'Leg': ['Squat', 'Leg Press', 'Bulgarian Split Squat', 'Lunge', 'Deadlift', 'Leg Curl', 'Leg Extension', 'Hip Thrust', 'Box Jump', 'Calf Raise'],
    'Abs': ['Plank', 'Crunches', 'Russian Twist', 'Leg Raise', 'V-Up', 'Flutter Kick', 'Mountain Climber'],
  };
  List<String> result = [];
  for (var cat in categories) {
    if (exerciseMap.containsKey(cat)) {
      result.addAll(exerciseMap[cat]!);
    }
  }
  return result.toSet().toList();
}

class SetRepsScreen extends StatefulWidget {
  final List<String> exerciseNames;
  final String day;
  final List<String> bodyParts;
  const SetRepsScreen({super.key, required this.exerciseNames, required this.day, required this.bodyParts});

  @override
  State<SetRepsScreen> createState() => _SetRepsScreenState();
}

class _SetRepsScreenState extends State<SetRepsScreen> {
  late List<ExerciseDetail> exerciseDetails;

  @override
  void initState() {
    super.initState();
    exerciseDetails = widget.exerciseNames.map((name) => ExerciseDetail(name: name, sets: 3, reps: 10)).toList();
  }

  void updateSets(int index, int delta) {
    setState(() {
      int newValue = exerciseDetails[index].sets + delta;
      if (newValue >= 1) exerciseDetails[index].sets = newValue;
    });
  }

  void updateReps(int index, int delta) {
    setState(() {
      int newValue = exerciseDetails[index].reps + delta;
      if (newValue >= 1) exerciseDetails[index].reps = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Set & Reps", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exerciseDetails.length,
        itemBuilder: (_, i) {
          final ex = exerciseDetails[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1C24),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4FF33).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.fitness_center, color: Color(0xFFD4FF33), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ex.name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCounter("Sets", ex.sets, () => updateSets(i, -1), () => updateSets(i, 1)),
                      _buildCounter("Reps", ex.reps, () => updateReps(i, -1), () => updateReps(i, 1)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0C10),
          border: Border(top: BorderSide(color: const Color(0xFF1A1C24), width: 1)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkoutSectionScreen(
                    exercisesDetail: exerciseDetails,
                    day: widget.day,
                    bodyParts: widget.bodyParts,
                  ),
                ),
              );
              if (result == true && mounted) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4FF33),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Next", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Widget _buildCounter(String label, int value, VoidCallback onMinus, VoidCallback onPlus) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
          const SizedBox(height: 6),
          Row(
            children: [
              GestureDetector(
                onTap: onMinus,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1C24),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.remove, size: 16, color: Color(0xFFD4FF33)),
                ),
              ),
              const SizedBox(width: 12),
              Text(value.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onPlus,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1C24),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, size: 16, color: Color(0xFFD4FF33)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WorkoutSectionScreen extends StatefulWidget {
  final List<ExerciseDetail> exercisesDetail;
  final String day;
  final List<String> bodyParts;
  const WorkoutSectionScreen({
    super.key,
    required this.exercisesDetail,
    required this.day,
    required this.bodyParts,
  });

  @override
  State<WorkoutSectionScreen> createState() => _WorkoutSectionScreenState();
}

class _WorkoutSectionScreenState extends State<WorkoutSectionScreen> {
  final TextEditingController _sectionController = TextEditingController();

  @override
  void dispose() {
    _sectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Workout Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1C24),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Color(0xFFD4FF33)),
                  const SizedBox(width: 8),
                  Text(widget.day, style: const TextStyle(fontSize: 13, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("Section Name", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF8E8E93))),
            const SizedBox(height: 6),
            TextField(
              controller: _sectionController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: "e.g., Upper Body, Full Body, Cardio",
                hintStyle: const TextStyle(color: Color(0xFF6B6F7A), fontSize: 14),
                filled: true,
                fillColor: const Color(0xFF1A1C24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Exercises", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF8E8E93))),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1C24),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: widget.exercisesDetail.isEmpty
                    ? const Center(child: Text("No exercises selected", style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(14),
                        itemCount: widget.exercisesDetail.length,
                        separatorBuilder: (_, __) => const Divider(color: Color(0xFF2A2D35), height: 1),
                        itemBuilder: (_, i) {
                          final ex = widget.exercisesDetail[i];
                          return Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4FF33).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.fitness_center, color: Color(0xFFD4FF33), size: 16),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(ex.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                                    const SizedBox(height: 2),
                                    Text("${ex.sets} sets x ${ex.reps} reps", style: const TextStyle(fontSize: 11, color: Color(0xFF8E8E93))),
                                  ],
                                ),
                              ),
                              const Icon(Icons.drag_handle, size: 16, color: Color(0xFF6B6F7A)),
                            ],
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2A2D35)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Cancel", style: TextStyle(fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_sectionController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter section name")),
                        );
                        return;
                      }
                      final workout = WorkoutDay(
                        dayName: widget.day,
                        bodyParts: widget.bodyParts,
                        exercises: widget.exercisesDetail,
                        sectionName: _sectionController.text.trim(),
                      );
                      await WorkoutStorage.saveWorkout(workout);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Workout saved successfully!")),
                        );
                        Navigator.pop(context, true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4FF33),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Save", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}