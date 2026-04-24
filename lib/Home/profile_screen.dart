import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  File? _profileImage;
  String _name = "John Graham";
  String _gender = "Male";
  String _ageGroup = "35 - 44";
  String _weight = "78 kg";
  String _height = "175 cm";
  String _fitnessLevel = "Beginner";
  String _mainGoal = "Build Muscle";
  String _workoutDays = "3 Days / Week";

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _profileImage = File(image.path));
    }
  }

  void _editText(String label, String currentValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: currentValue);
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

  void _editGender() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Gender"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ["Male", "Female", "Other"].map((opt) => ListTile(
            title: Text(opt),
            onTap: () {
              setState(() => _gender = opt);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _editAgeGroup() {
    final List<String> options = ["18 - 24", "25 - 34", "35 - 44", "45 - 54", "55+"];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Age Group"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) => ListTile(
            title: Text(opt),
            onTap: () {
              setState(() => _ageGroup = opt);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _editFitnessLevel() {
    final List<String> options = ["Beginner", "Intermediate", "Advanced"];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Fitness Level"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) => ListTile(
            title: Text(opt),
            onTap: () {
              setState(() => _fitnessLevel = opt);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _editMainGoal() {
    final List<String> options = ["Build Muscle", "Lose Fat", "Increase Endurance", "Improve Flexibility"];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Main Goal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) => ListTile(
            title: Text(opt),
            onTap: () {
              setState(() => _mainGoal = opt);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _editWorkoutDays() {
    final List<String> options = ["1 Day / Week", "2 Days / Week", "3 Days / Week", "4 Days / Week", "5 Days / Week", "6 Days / Week", "7 Days / Week"];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Workout Days"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) => ListTile(
            title: Text(opt),
            onTap: () {
              setState(() => _workoutDays = opt);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Align(alignment: Alignment.centerLeft, child: Text("Personal Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24))),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.grey[800],
                        image: _profileImage != null ? DecorationImage(image: FileImage(_profileImage!), fit: BoxFit.cover) : null,
                      ),
                      child: _profileImage == null ? const Icon(Icons.person, size: 80, color: Colors.white54) : null,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Color(0xFFD4FF33), shape: BoxShape.circle),
                        child: const Icon(Icons.edit_outlined, color: Colors.black, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            _buildDetailRow("Name", _name, onTap: () => _editText("Name", _name, (val) => setState(() => _name = val))),
            _buildDetailRow("Gender", _gender, onTap: _editGender),
            _buildDetailRow("Age Group", _ageGroup, onTap: _editAgeGroup),
            _buildDetailRow("Weight", _weight, onTap: () => _editText("Weight", _weight, (val) => setState(() => _weight = val))),
            _buildDetailRow("Height", _height, onTap: () => _editText("Height", _height, (val) => setState(() => _height = val))),
            _buildDetailRow("Fitness Level", _fitnessLevel, onTap: _editFitnessLevel),
            _buildDetailRow("Main Goal", _mainGoal, onTap: _editMainGoal),
            _buildDetailRow("Workout Days", _workoutDays, onTap: _editWorkoutDays),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(color: const Color(0xFF1F222A), borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(value, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}