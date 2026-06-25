import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  File? _profileImage;
  String _name = "";
  String _email = "";
  String _gender = "";
  String _ageGroup = "";
  String _weight = "";
  String _height = "";
  String _fitnessLevel = "";
  String _mainGoal = "";
  String _workoutDays = "";

  final ImagePicker _picker = ImagePicker();
  int _workoutsCount = 0;
  int _daysActive = 0;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadStats();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('username') ?? "";
      _email = prefs.getString('email') ?? "";
    });
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _workoutsCount = prefs.getInt('total_workouts') ?? 0;
      _daysActive = prefs.getInt('days_active') ?? 0;
      _streak = prefs.getInt('streak') ?? 0;
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _profileImage = File(image.path));
  }

  void _showPicker(String title, List<String> options, Function(String) onSelected) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) => ListTile(
            title: Text(opt),
            onTap: () {
              onSelected(opt);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _editText(String label, String currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $label"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter $label"),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildStatsRow(),
                    const SizedBox(height: 32),
                    _buildSectionTitle("Personal Information"),
                    const SizedBox(height: 12),
                    _buildInfoCard(),
                    const SizedBox(height: 32),
                    _buildSectionTitle("Fitness Profile"),
                    const SizedBox(height: 12),
                    _buildFitnessCard(),
                    const SizedBox(height: 32),
                    _buildLogoutButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A1D24),
                border: Border.all(color: const Color(0xFF2A2D35), width: 2),
                image: _profileImage != null
                    ? DecorationImage(image: FileImage(_profileImage!), fit: BoxFit.cover)
                    : null,
              ),
              child: _profileImage == null
                  ? const Icon(Icons.person, size: 48, color: Color(0xFF6B6F7A))
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _name.isEmpty ? "Guest User" : _name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            _email.isEmpty ? "No email set" : _email,
            style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: const Color(0xFF1C1F26),
            margin: const EdgeInsets.symmetric(horizontal: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF12151C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(_workoutsCount.toString(), "Workouts"),
          _buildStatItem(_daysActive.toString(), "Days Active"),
          _buildStatItem(_streak.toString(), "Streak"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93)),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF12151C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildListItem(Icons.person_outline, "Name", _name, true, () => _editText("Name", _name, (val) => setState(() => _name = val))),
          const Divider(height: 1, color: Color(0xFF1C1F26)),
          _buildListItem(Icons.email_outlined, "Email", _email, false, () {}),
          const Divider(height: 1, color: Color(0xFF1C1F26)),
          _buildListItem(Icons.wc, "Gender", _gender, true, () => _showPicker("Gender", ["Male", "Female", "Other"], (val) => setState(() => _gender = val))),
          const Divider(height: 1, color: Color(0xFF1C1F26)),
          _buildListItem(Icons.calendar_today, "Age Group", _ageGroup, true, () => _showPicker("Age Group", ["18-24", "25-34", "35-44", "45-54", "55+"], (val) => setState(() => _ageGroup = val))),
          const Divider(height: 1, color: Color(0xFF1C1F26)),
          _buildListItem(Icons.monitor_weight_outlined, "Weight", _weight, true, () => _editText("Weight", _weight, (val) => setState(() => _weight = val))),
          const Divider(height: 1, color: Color(0xFF1C1F26)),
          _buildListItem(Icons.height, "Height", _height, true, () => _editText("Height", _height, (val) => setState(() => _height = val))),
        ],
      ),
    );
  }

  Widget _buildFitnessCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF12151C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildListItemWithPicker(Icons.fitness_center, "Fitness Level", _fitnessLevel, ["Beginner", "Intermediate", "Advanced"], (val) => setState(() => _fitnessLevel = val)),
          const Divider(height: 1, color: Color(0xFF1C1F26)),
          _buildListItemWithPicker(Icons.flag_outlined, "Main Goal", _mainGoal, ["Build Muscle", "Lose Fat", "Increase Endurance", "Improve Flexibility"], (val) => setState(() => _mainGoal = val)),
          const Divider(height: 1, color: Color(0xFF1C1F26)),
          _buildListItemWithPicker(Icons.access_time, "Workout Days", _workoutDays, ["1 Day", "2 Days", "3 Days", "4 Days", "5 Days", "6 Days", "7 Days"], (val) => setState(() => _workoutDays = val)),
        ],
      ),
    );
  }

  Widget _buildListItem(IconData icon, String label, String value, bool editable, VoidCallback onTap) {
    return InkWell(
      onTap: editable ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF6B6F7A)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 15, color: Colors.white)),
            ),
            Text(
              value.isEmpty ? "Not set" : value,
              style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
            ),
            if (editable) ...[
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 18, color: Color(0xFF4A4E59)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListItemWithPicker(IconData icon, String label, String value, List<String> options, Function(String) onSelected) {
    return InkWell(
      onTap: () => _showPicker(label, options, onSelected),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF6B6F7A)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 15, color: Colors.white)),
            ),
            Text(
              value.isEmpty ? "Not set" : value,
              style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFF4A4E59)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _logout,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFF453A),
          side: const BorderSide(color: Color(0xFFFF453A), width: 1),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("Log Out", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }
}