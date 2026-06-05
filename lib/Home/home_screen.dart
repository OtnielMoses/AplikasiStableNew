import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  WorkoutDay? _todayWorkout;
  bool _isLoadingWorkout = true;
  String _userName = "Guest";
  String _userInitial = "G";

  final List<String> levels = ["Beginner", "Intermediate", "Advance"];
  late PageController _pageController;

  final List<Map<String, String>> workouts = [
    {
      "title": "ARM BEGINNER",
      "level": "Beginner",
      "duration": "60 min",
      "exercises": "12",
      "image": "assets/arm1.png"
    },
    {
      "title": "PUSH BEGINNER",
      "level": "Beginner",
      "duration": "60 min",
      "exercises": "12",
      "image": "assets/chest1.png"
    },
    {
      "title": "PULL BEGINNER",
      "level": "Beginner",
      "duration": "60 min",
      "exercises": "12",
      "image": "assets/back1.png"
    },
    {
      "title": "LEG BEGINNER",
      "level": "Beginner",
      "duration": "60 min",
      "exercises": "12",
      "image": "assets/leg1.png"
    },
    {
      "title": "ARM INTERMEDIATE",
      "level": "Intermediate",
      "duration": "70 min",
      "exercises": "14",
      "image": "assets/arm2.png"
    },
    {
      "title": "PUSH INTERMEDIATE",
      "level": "Intermediate",
      "duration": "70 min",
      "exercises": "14",
      "image": "assets/chest2.png"
    },
    {
      "title": "PULL INTERMEDIATE",
      "level": "Intermediate",
      "duration": "70 min",
      "exercises": "14",
      "image": "assets/back2.png"
    },
    {
      "title": "LEG INTERMEDIATE",
      "level": "Intermediate",
      "duration": "70 min",
      "exercises": "14",
      "image": "assets/leg2.png"
    },
    {
      "title": "ARM ADVANCE",
      "level": "Advance",
      "duration": "80 min",
      "exercises": "16",
      "image": "assets/arm3.png"
    },
    {
      "title": "PUSH ADVANCE",
      "level": "Advance",
      "duration": "80 min",
      "exercises": "16",
      "image": "assets/chest3.png"
    },
    {
      "title": "PULL ADVANCE",
      "level": "Advance",
      "duration": "80 min",
      "exercises": "16",
      "image": "assets/back.webp"
    },
    {
      "title": "LEG ADVANCE",
      "level": "Advance",
      "duration": "80 min",
      "exercises": "16",
      "image": "assets/leg3.png"
    },
  ];

  final List<Map<String, dynamic>> challenges = [
    {
      "title": "Push Day",
      "subtitle": "Chest & Triceps",
      "description":
          "Bangun kekuatan dada, bahu, dan trisep dengan program push day terbaik.",
      "duration": "35 Min",
      "level": "Beginner",
      "gradientColors": [
        Color(0xFF1E3A5F),
        Color(0xFF1A5496),
        Color(0xFF2B7DE9)
      ],
      "accentColor": Color(0xFF2B7DE9),
    },
    {
      "title": "Pull Day",
      "subtitle": "Back & Biceps",
      "description":
          "Perkuat otot punggung dan lengan dengan latihan pull yang intens.",
      "duration": "40 Min",
      "level": "Intermediate",
      "gradientColors": [
        Color(0xFF2D1B69),
        Color(0xFF4A2DB5),
        Color(0xFF6C5CE7)
      ],
      "accentColor": Color(0xFF6C5CE7),
    },
    {
      "title": "Leg Day",
      "subtitle": "Lower Body",
      "description":
          "Bangun kekuatan kaki dan glutes dengan squat & deadlift intensif.",
      "duration": "45 Min",
      "level": "Advanced",
      "gradientColors": [
        Color(0xFF0A2E2E),
        Color(0xFF0F5050),
        Color(0xFF1D9E75)
      ],
      "accentColor": Color(0xFF1D9E75),
    },
    {
      "title": "Full Body\nBlast",
      "subtitle": "Total Conditioning",
      "description":
          "Latihan seluruh tubuh yang komprehensif untuk kebugaran optimal.",
      "duration": "50 Min",
      "level": "Advanced",
      "gradientColors": [
        Color(0xFF2E1A0A),
        Color(0xFF7A3A10),
        Color(0xFFD4803A)
      ],
      "accentColor": Color(0xFFD4803A),
    },
    {
      "title": "HIIT\nCardio",
      "subtitle": "Fat Burner",
      "description":
          "Bakar lemak maksimal dengan interval training intensitas tinggi.",
      "duration": "25 Min",
      "level": "Intermediate",
      "gradientColors": [
        Color(0xFF3A0A0A),
        Color(0xFF8B2200),
        Color(0xFFD85A30)
      ],
      "accentColor": Color(0xFFD85A30),
    },
  ];

  @override
  void initState() {
    super.initState();
    currentDate = DateTime.now();
    _generateWeekDays();
    _loadUserData();
    _pageController =
        PageController(initialPage: levels.indexOf(selectedLevel));
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
      final workout = await WorkoutStorage.getWorkoutForDay(
          DateFormat('EEEE').format(DateTime.now()));
      if (mounted)
        setState(() {
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
            color: Color(0xFF1A1C24),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text("Set Timer",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              Expanded(
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration:
                      Duration(hours: hours, minutes: minutes),
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
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4FF33),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Confirm",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
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
        const SnackBar(
            content: Text("Please set timer first"),
            backgroundColor: Color(0xFFFF453A)),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutSessionScreen(
          workout: workout,
          initialDuration:
              Duration(minutes: _timerMinutes, seconds: _timerSeconds),
        ),
      ),
    ).then((_) => _loadTodayWorkout());
  }

  Future<void> _refreshData() async => _loadTodayWorkout();

  void _showChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1C24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Chat Support",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Describe your problem...",
            hintStyle: const TextStyle(color: Color(0xFF6B6F7A)),
            filled: true,
            fillColor: const Color(0xFF2A2D35),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel",
                  style: TextStyle(color: Color(0xFF8E8E93)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Message sent. We'll respond soon."),
                    backgroundColor: Color(0xFF34C759)),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4FF33),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text("Send"),
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
      backgroundColor: const Color(0xFF0A0C10),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 28),
                      _buildSectionTitle("Have a plan?"),
                      const SizedBox(height: 16),
                      _buildTimerCard(),
                      const SizedBox(height: 16),
                      _buildCreateWorkoutButton(),
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
                    onPageChanged: (index) =>
                        setState(() => selectedLevel = levels[index]),
                    itemCount: levels.length,
                    itemBuilder: (context, index) {
                      final filtered = workouts
                          .where((w) => w["level"] == levels[index])
                          .toList();
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
          final List<Color> gradientColors =
              (c['gradientColors'] as List).cast<Color>();
          final Color accentColor = c['accentColor'] as Color;
          final String duration = c['duration'] as String;
          final String level = c['level'] as String;
          final String title = c['title'] as String;
          final String description = c['description'] as String;

          return Container(
            width: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _CardGeoPainter(accentColor: accentColor),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildCardChip(
                                duration,
                                Colors.white.withOpacity(0.15),
                                Colors.white.withOpacity(0.9),
                                border: Colors.white.withOpacity(0.2)),
                            const SizedBox(width: 8),
                            _buildCardChip(
                                level.toUpperCase(),
                                accentColor.withOpacity(0.2),
                                const Color(0xFFD4FF33),
                                border:
                                    const Color(0xFFD4FF33).withOpacity(0.4)),
                          ],
                        ),
                        const Spacer(),
                        Text(title,
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 0.95,
                                letterSpacing: 0.5)),
                        const SizedBox(height: 10),
                        Text(description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.75),
                                height: 1.4)),
                        const SizedBox(height: 16),
                        _buildChallengeCTA(accentColor),
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

  Widget _buildCardChip(String text, Color bg, Color textColor,
      {required Color border}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.5)),
    );
  }

  Widget _buildChallengeCTA(Color accentColor) {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(100)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('START NOW',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: accentColor)),
                Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                        color: accentColor, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_forward,
                        color: Colors.white, size: 16)),
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
          color: const Color(0xFF1A1C24),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD4FF33).withOpacity(0.3)),
        ),
        child: const Center(
            child: Text("Tidak menemukan latihan mu? Chat Admin",
                style: TextStyle(fontSize: 13, color: Color(0xFFD4FF33)))),
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
                _pageController.animateToPage(index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFFD4FF33) : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : const Color(0xFF2A2D35)),
              ),
              child: Center(
                  child: Text(level,
                      style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : const Color(0xFF8E8E93),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 14))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayActivitySection() {
    if (_isLoadingWorkout) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
            color: const Color(0xFF1A1C24),
            borderRadius: BorderRadius.circular(20)),
        child: const Center(
            child: CircularProgressIndicator(color: Color(0xFFD4FF33))),
      );
    }
    if (_todayWorkout != null) return _buildTodayWorkoutCard(_todayWorkout!);
    return _buildEmptyWorkoutCard();
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  colors: [Color(0xFFD4FF33), Color(0xFFA8CC29)])),
          child: Center(
              child: Text(_userInitial,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_userName,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              const Text("Have a productive workout day!",
                  style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93))),
            ],
          ),
        ),
        GestureDetector(
          onTap: _showChatDialog,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color(0xFF1A1C24),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.chat_bubble_outline,
                size: 22, color: Color(0xFFD4FF33)),
          ),
        ),
      ],
    );
  }

  Widget _buildChipsRow() {
    return _horizontalScroll(
      spacing: 10,
      children: [
        _buildChip("Advanced", const Color(0xFF6C5CE7)),
        _buildChip("Training Days", const Color(0xFFD4FF33)),
        _buildChip("Community", const Color(0xFF4A90E2)),
      ],
    );
  }

  Widget _horizontalScroll({
    required List<Widget> children,
    double spacing = 0,
  }) {
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
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500, color: color)),
    );
  }

  Widget _buildDateSection(String dayName, String formattedDate) {
    return Center(
      child: Column(
        children: [
          Text(dayName.toUpperCase(),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD4FF33),
                  letterSpacing: 1)),
          const SizedBox(height: 6),
          Text(formattedDate,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
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
              onTap: () => setState(() {
                selectedDayIndex = i;
                currentDate = date;
              }),
              child: Container(
                width: 68,
                height: 84,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isSelected
                      ? const Color(0xFFD4FF33)
                      : const Color(0xFF1A1C24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(DateFormat('E').format(date),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.black
                                : const Color(0xFF8E8E93))),
                    const SizedBox(height: 6),
                    Text(date.day.toString(),
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.black : Colors.white)),
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
    return Text(title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white));
  }

  Widget _buildTodayWorkoutCard(WorkoutDay workout) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1A1C24), Color(0xFF23262F)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4FF33).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color(0xFFD4FF33).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.fitness_center,
                    color: Color(0xFFD4FF33), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(workout.sectionName,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Text("${workout.exercises.length} exercises",
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF8E8E93))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: workout.bodyParts
                .map((part) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0xFF2A2D35),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(part,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFFD4FF33))),
                    ))
                .toList(),
          ),
          const SizedBox(height: 14),
          _buildStartButton(() => _startWorkout(workout)),
        ],
      ),
    );
  }

  Widget _buildEmptyWorkoutCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: const Color(0xFF1A1C24),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          const Icon(Icons.calendar_today, size: 40, color: Color(0xFF4A4E59)),
          const SizedBox(height: 12),
          const Text("No workout planned for today",
              style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93))),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: widget.onCreateWorkout,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4FF33),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text("Create Plan",
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard() {
    return Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: [
        BoxShadow(
            color: const Color(0xFFD4FF33).withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 2)
      ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.asset('assets/time.jpg',
                height: 120, width: double.infinity, fit: BoxFit.cover),
            Container(
                height: 120,
                decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7).withOpacity(0.85))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("WORKOUT TIMER",
                          style: TextStyle(
                              color: Color(0xFFD4FF33),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(
                          _isTimerSet
                              ? "${(_timerMinutes ~/ 60).toString().padLeft(2, '0')}:${(_timerMinutes % 60).toString().padLeft(2, '0')}"
                              : "00:00",
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: _showTimerPicker,
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                            color: Color(0xFFD4FF33), width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40))),
                    child: const Text("SET",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateWorkoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onCreateWorkout,
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4FF33),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16))),
        child: const Text("Create Workout",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildWorkoutCard(Map<String, String> workout) {
    final level = workout["level"]!;
    final levelColor = level == "Beginner"
        ? const Color(0xFF4A90E2)
        : level == "Intermediate"
            ? const Color(0xFF6C5CE7)
            : const Color(0xFFFF453A);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: [
        BoxShadow(
            color: levelColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4))
      ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(workout["image"]!,
                    height: 140, width: double.infinity, fit: BoxFit.cover),
                Container(
                    height: 140,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7)
                        ]))),
                Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: levelColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: levelColor, width: 1.5)),
                        child: const Icon(Icons.flash_on,
                            color: Colors.white, size: 18))),
                Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: levelColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: levelColor,
                                  blurRadius: 6,
                                  spreadRadius: 1)
                            ]),
                        child: Text(level,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)))),
              ],
            ),
            Container(
              color: const Color(0xFF1A1C24),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout["title"]!,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildSportyIcon(Icons.timer_outlined,
                          workout["duration"]!, levelColor),
                      const SizedBox(width: 16),
                      _buildSportyIcon(Icons.repeat,
                          "${workout["exercises"]} ex", levelColor),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildSportyStartButton(() {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportyIcon(IconData icon, String text, Color color) {
    return Row(children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(fontSize: 12, color: Colors.white70))
    ]);
  }

  Widget _buildSportyStartButton(VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.play_arrow, size: 18),
        label: const Text("START",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4FF33),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          elevation: 4,
          shadowColor: const Color(0xFFD4FF33).withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildStartButton(VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFD4FF33),
            side: const BorderSide(color: Color(0xFFD4FF33)),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        child: const Text("Start",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
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
    final w = size.width;
    final h = size.height;

    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 36;
    canvas.drawCircle(Offset(w * 0.85, h * 0.22), w * 0.52, circlePaint);

    final circlePaint2 = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(w * 0.85, h * 0.22), w * 0.34, circlePaint2);

    final bandPaint = Paint()
      ..color = Colors.white.withOpacity(0.055)
      ..style = PaintingStyle.fill;
    final band1 = Path()
      ..moveTo(0, h * 0.62)
      ..lineTo(w * 0.28, h * 0.38)
      ..lineTo(w * 0.28 + 18, h * 0.38)
      ..lineTo(18, h * 0.62)
      ..close();
    canvas.drawPath(band1, bandPaint);

    final band2 = Paint()..color = Colors.white.withOpacity(0.035);
    final band2Path = Path()
      ..moveTo(0, h * 0.70)
      ..lineTo(w * 0.22, h * 0.50)
      ..lineTo(w * 0.22 + 12, h * 0.50)
      ..lineTo(12, h * 0.70)
      ..close();
    canvas.drawPath(band2Path, band2..style = PaintingStyle.fill);

    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        canvas.drawCircle(
            Offset(22.0 + col * 18, 26.0 + row * 18), 2.2, dotPaint);
      }
    }

    final barPaint = Paint()
      ..color = accentColor.withOpacity(0.5)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, h * 0.77, w * 0.38, 4), const Radius.circular(2)),
        barPaint);

    final crossPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(w * 0.88, h * 0.87), Offset(w * 0.96, h * 0.87), crossPaint);
    canvas.drawLine(
        Offset(w * 0.92, h * 0.83), Offset(w * 0.92, h * 0.91), crossPaint);

    final linePaint = Paint()
      ..color = const Color(0xFFD4FF33).withOpacity(0.15)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(w * 0.60, h * 0.08), Offset(w * 0.82, h * 0.02), linePaint);
    final linePaint2 = Paint()
      ..color = const Color(0xFFD4FF33).withOpacity(0.08)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(w * 0.63, h * 0.12), Offset(w * 0.88, h * 0.06), linePaint2);
  }

  @override
  bool shouldRepaint(_CardGeoPainter old) => old.accentColor != accentColor;
}
