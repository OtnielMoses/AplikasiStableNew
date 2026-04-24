import 'package:flutter/material.dart';
import '../models/workout_data.dart';

// =============================== 1. SELECT DAY SCREEN ===============================
class SelectDayScreen extends StatefulWidget {
  const SelectDayScreen({super.key});

  @override
  State<SelectDayScreen> createState() => _SelectDayScreenState();
}

class _SelectDayScreenState extends State<SelectDayScreen> {
  final List<Map<String, dynamic>> days = const [
    {"name": "Mon", "full": "Monday", "icon": Icons.sunny},
    {"name": "Tue", "full": "Tuesday", "icon": Icons.wb_sunny},
    {"name": "Wed", "full": "Wednesday", "icon": Icons.cloud},
    {"name": "Thu", "full": "Thursday", "icon": Icons.wb_twilight},
    {"name": "Fri", "full": "Friday", "icon": Icons.weekend},
    {"name": "Sat", "full": "Saturday", "icon": Icons.sports},
    {"name": "Sun", "full": "Sunday", "icon": Icons.bedtime},
  ];

  Map<String, WorkoutDay?> workoutMap = {};

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
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
    setState(() {
      workoutMap = map;
    });
  }

  Future<void> _refreshData() async {
    await _loadWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Select Day", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFD4FF33)),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Choose a day for your workout plan", style: TextStyle(fontSize: 16, color: Colors.white70)),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
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
                            builder: (_) => FilterScreen(selectedDay: fullName, existingWorkout: workout),
                          ),
                        );
                        if (result == true) {
                          await _loadWorkouts(); // auto-reload setelah save
                        }
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
          color: const Color(0xFF1F222A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: workout != null ? const Color(0xFFD4FF33) : Colors.white10,
            width: workout != null ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: workout != null ? const Color(0xFFD4FF33) : Colors.white54),
              const SizedBox(height: 8),
              Text(dayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(fullName, style: const TextStyle(fontSize: 11, color: Colors.white54)),
              if (workout != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4FF33).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${workout!.bodyParts.length} parts • ${workout!.exercises.length} ex",
                    style: const TextStyle(fontSize: 10, color: Color(0xFFD4FF33)),
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: workout!.exercises.map((ex) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          "• ${ex.name}",
                          style: const TextStyle(fontSize: 9, color: Colors.white70),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )).take(3).toList(),
                    ),
                  ),
                ),
                if (workout!.exercises.length > 3)
                  const Text("...", style: TextStyle(fontSize: 9, color: Colors.white54)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// =============================== 2. FILTER SCREEN ===============================
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
    {"name": "Back", "icon": Icons.airline_seat_recline_normal, "color": Colors.orange},
    {"name": "Bicep", "icon": Icons.handshake, "color": Colors.blue},
    {"name": "Tricep", "icon": Icons.fitness_center, "color": Colors.deepPurple},
    {"name": "Chest", "icon": Icons.fitness_center, "color": Colors.red},
    {"name": "Shoulder", "icon": Icons.accessibility, "color": Colors.green},
    {"name": "Abs", "icon": Icons.radio_button_unchecked, "color": Colors.amber},
    {"name": "Leg", "icon": Icons.accessibility_new, "color": Colors.pink},
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
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Select Body Parts (${widget.selectedDay})"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Choose muscle groups", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: categories.map((cat) {
                final selected = selectedCategories.contains(cat['name']);
                return GestureDetector(
                  onTap: () => toggleCategory(cat['name']),
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 72) / 2,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: selected ? cat['color'] : const Color(0xFF1F222A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        Icon(cat['icon'], color: selected ? Colors.black : cat['color']),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            cat['name'],
                            style: TextStyle(
                              color: selected ? Colors.black : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(Icons.check_circle, color: Colors.black, size: 20),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
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
                  if (result == true) Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4FF33),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================== 3. SELECT EXERCISE SCREEN ===============================
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
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Exercises (${widget.day})"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search workout",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF1F222A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () => setState(() => searchQuery = ""),
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
            const SizedBox(height: 20),
            if (widget.selectedCategories.isEmpty)
              const Center(child: Text("Select body parts first", style: TextStyle(color: Colors.white54)))
            else if (availableExercises.isEmpty)
              const Center(child: Text("No exercises for selected categories", style: TextStyle(color: Colors.white54)))
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
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFFD4FF33).withOpacity(0.15) : const Color(0xFF1F222A),
                          borderRadius: BorderRadius.circular(16),
                          border: selected ? Border.all(color: const Color(0xFFD4FF33)) : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selected ? Icons.check_circle : Icons.fitness_center,
                              color: selected ? const Color(0xFFD4FF33) : Colors.white54,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                ex,
                                style: TextStyle(
                                  color: selected ? const Color(0xFFD4FF33) : Colors.white,
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Next"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================== 4. SET & REPS SCREEN ===============================
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Set & Reps"),
      ),
      body: ListView.builder(
        itemCount: exerciseDetails.length,
        itemBuilder: (_, i) {
          final ex = exerciseDetails[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF1F222A),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(ex.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => setState(() { if (ex.sets > 1) ex.sets--; }),
                            icon: const Icon(Icons.remove),
                          ),
                          Text("${ex.sets} sets", style: const TextStyle(fontSize: 16)),
                          IconButton(
                            onPressed: () => setState(() { ex.sets++; }),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => setState(() { if (ex.reps > 1) ex.reps--; }),
                            icon: const Icon(Icons.remove),
                          ),
                          Text("${ex.reps} reps", style: const TextStyle(fontSize: 16)),
                          IconButton(
                            onPressed: () => setState(() { ex.reps++; }),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
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
            if (result == true) Navigator.pop(context, true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4FF33),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text("Next"),
        ),
      ),
    );
  }
}

// =============================== 5. WORKOUT SECTION SCREEN (SAVE) ===============================
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Workout Section"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1F222A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text("Day: ${widget.day}"),
            ),
            const SizedBox(height: 20),
            const Text("Section Name", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _sectionController,
              decoration: InputDecoration(
                hintText: "e.g., Upper Body",
                filled: true,
                fillColor: const Color(0xFF1F222A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Exercises", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Expanded(
              child: widget.exercisesDetail.isEmpty
                  ? const Center(child: Text("No exercises selected", style: TextStyle(color: Colors.white54)))
                  : ListView.separated(
                      itemCount: widget.exercisesDetail.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, i) => ListTile(
                        leading: const Icon(Icons.fitness_center, color: Color(0xFFD4FF33)),
                        title: Text(widget.exercisesDetail[i].name),
                        subtitle: Text("${widget.exercisesDetail[i].sets} sets x ${widget.exercisesDetail[i].reps} reps"),
                        trailing: const Icon(Icons.drag_handle, color: Colors.white54),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_sectionController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter section name")),
                        );
                        return;
                      }
                      final workout = WorkoutDay(
                        dayName: widget.day,
                        bodyParts: widget.bodyParts,
                        exercises: widget.exercisesDetail,
                        sectionName: _sectionController.text,
                      );
                      await WorkoutStorage.saveWorkout(workout);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Workout saved!")),
                        );
                        Navigator.pop(context, true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4FF33),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("Save"),
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