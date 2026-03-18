import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import 'exercise_screen.dart';

// ── DATA MODEL ───────────────────────────────────────────────
class WorkoutDay {
  final String day;
  String title;
  List<ExerciseItem> exercises;
  WorkoutDay({required this.day, required this.title, required this.exercises});
}

class ExerciseItem {
  String name;
  String sets;
  ExerciseItem({required this.name, required this.sets});
}

// ── SCREEN ───────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _firstName = 'WINorWIN';
  String _lastName  = '';

  final List<WorkoutDay> _days = [
    WorkoutDay(day: 'MONDAY',    title: 'Push Day Core',   exercises: [ExerciseItem(name: 'Bench Press', sets: '4x10'), ExerciseItem(name: 'Triceps Dips', sets: '3x12')]),
    WorkoutDay(day: 'TUESDAY',   title: 'Pull & Back',     exercises: [ExerciseItem(name: 'Bench Press', sets: '4x10'), ExerciseItem(name: 'Triceps Dips', sets: '3x12')]),
    WorkoutDay(day: 'WEDNESDAY', title: 'Active Recovery', exercises: [ExerciseItem(name: 'Bench Press', sets: '4x10'), ExerciseItem(name: 'Triceps Dips', sets: '3x12')]),
    WorkoutDay(day: 'THURSDAY',  title: 'Leg Day',         exercises: [ExerciseItem(name: 'Bench Press', sets: '4x10'), ExerciseItem(name: 'Triceps Dips', sets: '3x12')]),
    WorkoutDay(day: 'FRIDAY',    title: 'Shoulders & Arm', exercises: [ExerciseItem(name: 'Bench Press', sets: '4x10'), ExerciseItem(name: 'Triceps Dips', sets: '3x12')]),
    WorkoutDay(day: 'SATURDAY',  title: 'HIIT Cardio',     exercises: [ExerciseItem(name: 'Bench Press', sets: '4x10'), ExerciseItem(name: 'Triceps Dips', sets: '3x12')]),
    WorkoutDay(day: 'SUNDAY',    title: 'Rest',            exercises: []),
  ];

  // ── EDIT NAMA ──────────────────────────────────────────────
  void _openNameModal() {
    final firstCtrl = TextEditingController(text: _firstName);
    final lastCtrl  = TextEditingController(text: _lastName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF131e2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Edit Nama', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModalField(controller: firstCtrl, hint: 'First Name'),
            const SizedBox(height: 12),
            _ModalField(controller: lastCtrl, hint: 'Last Name'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1e88e5)),
            onPressed: () {
              setState(() {
                _firstName = firstCtrl.text.trim();
                _lastName  = lastCtrl.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ── EDIT WORKOUT ───────────────────────────────────────────
  void _openWorkoutModal(WorkoutDay wd) {
    final titleCtrl = TextEditingController(text: wd.title);
    final tempExercises = wd.exercises
        .map((e) => ExerciseItem(name: e.name, sets: e.sets))
        .toList();

    final exerciseOptions = [
      'Bench Press','Incline Bench Press','Push Up','Chest Fly',
      'Pull Up','Lat Pulldown','Seated Row','Bent Over Row','Deadlift',
      'Overhead Press','Lateral Raise','Arnold Press',
      'Barbell Curl','Dumbbell Curl','Hammer Curl',
      'Triceps Dips','Skull Crusher','Tricep Pushdown',
      'Squat','Leg Press','Lunges','Romanian Deadlift','Leg Curl','Calf Raise',
      'Plank','Crunches','Leg Raise','Russian Twist',
      'Running','Cycling','Jump Rope','HIIT','Rest Day',
    ];
    final setsOptions = ['1x8','2x8','3x8','4x8','1x10','2x10','3x10','4x10',
        '1x12','2x12','3x12','4x12','3x15','4x15','5x5','To Failure'];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: const Color(0xFF131e2e),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text('Edit ${wd.day}',
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ModalField(controller: titleCtrl, hint: 'Judul Latihan'),
                  const SizedBox(height: 16),
                  ...tempExercises.asMap().entries.map((entry) {
                    final i = entry.key;
                    final ex = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: _DropdownField(
                              value: exerciseOptions.contains(ex.name)
                                  ? ex.name : exerciseOptions.first,
                              items: exerciseOptions,
                              onChanged: (val) =>
                                  setModalState(() => ex.name = val!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 90,
                            child: _DropdownField(
                              value: setsOptions.contains(ex.sets)
                                  ? ex.sets : setsOptions.first,
                              items: setsOptions,
                              onChanged: (val) =>
                                  setModalState(() => ex.sets = val!),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => setModalState(
                                () => tempExercises.removeAt(i)),
                            child: const Icon(Icons.close,
                                color: Color(0xFFff6060), size: 20),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => setModalState(() => tempExercises.add(
                        ExerciseItem(name: exerciseOptions.first, sets: '3x10'))),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF1e88e5)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('+ Tambah Latihan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(0xFF1e88e5),
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1e88e5)),
              onPressed: () {
                setState(() {
                  wd.title = titleCtrl.text.trim();
                  wd.exercises = tempExercises;
                });
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  // ── BUILD ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Mobile jika lebar < 600
    final isMobile = screenWidth < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0d1b2a), Color(0xFF061521)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── NAVBAR ──────────────────────────────────
                AppNavbar(links: [
                  NavLink('Home', onTap: () => Navigator.pop(context)),
                  NavLink('Exercise', onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ExerciseScreen()))),
                  NavLink('Leaderboard'),
                  NavLink('Profile'),
                  NavLink('Logout', color: kRed, onTap: () =>
                      Navigator.popUntil(context, (r) => r.isFirst)),
                ]),

                const SizedBox(height: 20),

                // ── PROFILE SECTION ──────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Foto profil — ukuran lebih kecil di mobile
                      Stack(
                        children: [
                          Container(
                            width: isMobile ? 80 : 120,
                            height: isMobile ? 80 : 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2a3545),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0xFF3a4a5a), width: 3),
                            ),
                            child: Center(
                              child: Text('👤',
                                  style: TextStyle(
                                      fontSize: isMobile ? 36 : 56)),
                            ),
                          ),
                          Positioned(
                            bottom: 2, right: 2,
                            child: Container(
                              width: 26, height: 26,
                              decoration: BoxDecoration(
                                color: const Color(0xFFffc0c0),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFF0a0f1a), width: 2),
                              ),
                              child: const Center(
                                child: Text('📷',
                                    style: TextStyle(fontSize: 11)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // Nama & stats — pakai Flexible agar tidak overflow
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Hey, $_firstName'
                                    '${_lastName.isNotEmpty ? ' $_lastName' : ''}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      // Font size lebih kecil di mobile
                                      fontSize: isMobile ? 22 : 40,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                      fontFamily: 'Montserrat',
                                    ),
                                    // Biarkan wrap jika terlalu panjang
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: _openNameModal,
                                  child: const Text('✏️',
                                      style: TextStyle(fontSize: 16)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF475868),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('🔥 0',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          fontFamily: 'Montserrat')),
                                ),
                                const SizedBox(width: 12),
                                const Text('Global #-',
                                    style: TextStyle(
                                        color: Color(0xFFf0a500),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        fontFamily: 'Montserrat')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ── WORKOUT GRID ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      // Mobile: 2 kolom, Desktop: 4 kolom
                      crossAxisCount: isMobile ? 2 : 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      // Rasio lebih tinggi agar konten muat
                      childAspectRatio: isMobile ? 0.85 : 0.75,
                    ),
                    itemCount: _days.length,
                    itemBuilder: (_, i) => _WorkoutCard(
                      wd: _days[i],
                      onEdit: () => _openWorkoutModal(_days[i]),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── WORKOUT CARD ─────────────────────────────────────────────
class _WorkoutCard extends StatelessWidget {
  final WorkoutDay wd;
  final VoidCallback onEdit;

  const _WorkoutCard({required this.wd, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF17232d),
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header hari + pensil
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(wd.day,
                    style: const TextStyle(
                        color: Color(0xFFcdcfd1),
                        fontSize: 9,
                        letterSpacing: 1,
                        fontFamily: 'Montserrat')),
              ),
              GestureDetector(
                onTap: onEdit,
                child: const Text('✏️', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Judul latihan
          Text(wd.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Color(0xFFcdcfd1),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat')),
          const SizedBox(height: 8),

          // Exercise list
          Expanded(
            child: wd.exercises.isEmpty
                ? const Center(
                    child: Text('rest day',
                        style: TextStyle(
                            color: Color(0xFF4a6a7a),
                            fontStyle: FontStyle.italic,
                            fontSize: 11)))
                : ListView(
                    padding: EdgeInsets.zero,
                    children: wd.exercises
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  border: Border.all(
                                      color: const Color(0xFF868686)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(e.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: Color(0xFFcdcfd1),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Montserrat')),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1e3a5a),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(e.sets,
                                          style: const TextStyle(
                                              color: Color(0xFFaaccee),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── MODAL HELPERS ────────────────────────────────────────────
class _ModalField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _ModalField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF4a6a7a)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2a3a4a))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2a3a4a))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF1e88e5))),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: const Color(0xFF2a3a4a)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF131e2e),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          items: items
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}