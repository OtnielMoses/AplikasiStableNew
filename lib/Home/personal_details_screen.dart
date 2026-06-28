import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  static String get apiBase {
    if (kIsWeb) return 'http://localhost:8080/api/v1';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080/api/v1';
    return 'http://localhost:8080/api/v1';
  }

  final ImagePicker _picker = ImagePicker();

  bool _loading = true;
  bool _saving = false;
  File? _profileImageFile;

  int? _userId;
  String _token = '';
  String _name = '';
  String _email = '';
  String _gender = '';
  String _weight = '';
  String _height = '';
  String _fitnessLevel = '';
  String _mainGoal = '';
  String _workoutDays = '';
  String _profileImage = '';
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      if (_token.isNotEmpty) 'Authorization': 'Bearer $_token',
    };
  }

  Future<void> _loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    _userId =
        prefs.getInt('user_id') ??
        int.tryParse(prefs.getString('user_id') ?? '') ??
        int.tryParse(prefs.getString('id') ?? '');

    _name = prefs.getString('username') ?? prefs.getString('name') ?? '';
    _email = prefs.getString('email') ?? '';
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    await _loadAuth();

    if (_userId == null) {
      setState(() => _loading = false);
      _showMessage('User belum login.');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$apiBase/profile/$_userId'),
        headers: _headers,
      );
      final body = jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(body['message'] ?? 'Gagal memuat profile.');
      }

      final data = body['data'] ?? body;
      _applyProfile(data);
      await _cacheProfile(data);
    } catch (error) {
      _showMessage('Tidak bisa memuat profile: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyProfile(dynamic data) {
    setState(() {
      _name = '${data['username'] ?? data['name'] ?? _name}';
      _email = '${data['email'] ?? _email}';
      _gender = '${data['gender'] ?? ''}';
      _weight = _formatNumber(data['weight']);
      _height = _formatNumber(data['height']);
      _fitnessLevel = '${data['fitness_level'] ?? ''}';
      _mainGoal = '${data['main_goal'] ?? ''}';
      _workoutDays = _formatNumber(data['workout_days']);
      _profileImage = '${data['profile_image'] ?? data['avatar_url'] ?? ''}';
      _streak = _toInt(data['current_streak']);
    });
  }

  Future<void> _cacheProfile(dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', '${data['username'] ?? data['name'] ?? _name}');
    await prefs.setString('name', '${data['username'] ?? data['name'] ?? _name}');
    await prefs.setString('email', '${data['email'] ?? _email}');
  }

  String _formatNumber(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }

  int? _nullableInt(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return null;
    return int.tryParse(cleaned);
  }

  Future<void> _saveProfile(Map<String, dynamic> payload) async {
    if (_userId == null || _saving) return;

    setState(() => _saving = true);
    try {
      final response = await http.patch(
        Uri.parse('$apiBase/profile/$_userId'),
        headers: _headers,
        body: jsonEncode(payload),
      );
      final body = jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(body['message'] ?? body['error'] ?? 'Gagal menyimpan data.');
      }

      final data = body['data'] ?? body;
      _applyProfile(data);
      await _cacheProfile(data);
      _showMessage('Profile berhasil disimpan.');
    } catch (error) {
      _showMessage('Gagal menyimpan profile: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 900,
    );
    if (image == null || _userId == null) return;

    final file = File(image.path);
    setState(() => _profileImageFile = file);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiBase/profile/$_userId/avatar'),
      );
      if (_token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      request.files.add(await http.MultipartFile.fromPath('avatar', file.path));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final body = jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(body['message'] ?? body['error'] ?? 'Upload avatar gagal.');
      }

      final data = body['data'] ?? body;
      _applyProfile(data);
      _showMessage('Foto profile berhasil diupload.');
    } catch (error) {
      _showMessage('Upload profile gagal: $error');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showPicker(
    String title,
    List<String> options,
    ValueChanged<String> onSelected,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF11212D),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map(
                (option) => ListTile(
                  title: Text(option, style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    onSelected(option);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _editText(
    String label,
    String currentValue,
    ValueChanged<String> onSave,
  ) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF11212D),
        title: Text('Edit $label', style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: const TextStyle(color: Color(0xFF8E8E93)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onSave(controller.text.trim());
            },
            child: const Text('Save'),
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

  ImageProvider? _avatarImage() {
    if (_profileImageFile != null) return FileImage(_profileImageFile!);
    if (_profileImage.isNotEmpty) {
      final url = _profileImage.startsWith('http')
          ? _profileImage
          : '${apiBase.replaceAll('/api/v1', '')}$_profileImage';
      return NetworkImage(url);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06141B),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadProfile,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            _buildStatsRow(),
                            const SizedBox(height: 32),
                            _buildSectionTitle('Personal Information'),
                            const SizedBox(height: 12),
                            _buildInfoCard(),
                            const SizedBox(height: 32),
                            _buildSectionTitle('Fitness Profile'),
                            const SizedBox(height: 12),
                            _buildFitnessCard(),
                            const SizedBox(height: 32),
                            _buildLogoutButton(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    final image = _avatarImage();
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
                color: const Color(0xFF11212D),
                border: Border.all(color: const Color(0xFF253745), width: 2),
                image: image != null
                    ? DecorationImage(image: image, fit: BoxFit.cover)
                    : null,
              ),
              child: image == null
                  ? const Icon(Icons.person, size: 48, color: Color(0xFF9BA8AB))
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _name.isEmpty ? 'Guest User' : _name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _email.isEmpty ? 'No email set' : _email,
            style: const TextStyle(fontSize: 13, color: Color(0xFF9BA8AB)),
          ),
          if (_saving) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(minHeight: 2),
          ],
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: const Color(0xFF253745),
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
        color: const Color(0xFF11212D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF253745)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(_streak.toString(), 'Streak'),
          _buildStatItem(_rankFromStreak(_streak), 'Rank'),
          _buildStatItem(_workoutDays.isEmpty ? '-' : _workoutDays, 'Days / Week'),
        ],
      ),
    );
  }

  String _rankFromStreak(int streak) {
    if (streak >= 30) return 'Gym Rat';
    if (streak >= 14) return 'Pro';
    if (streak >= 7) return 'Bronze';
    return 'Newbie';
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9BA8AB))),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF9BA8AB),
      ),
    );
  }

  Widget _buildInfoCard() {
    return _buildCard([
      _buildListItem(
        Icons.person_outline,
        'Name',
        _name,
        true,
        () => _editText('Name', _name, (value) {
          if (value.isNotEmpty) _saveProfile({'username': value});
        }),
      ),
      _divider(),
      _buildListItem(Icons.email_outlined, 'Email', _email, false, () {}),
      _divider(),
      _buildListItem(
        Icons.wc,
        'Gender',
        _gender,
        true,
        () => _showPicker('Gender', ['Male', 'Female'], (value) {
          _saveProfile({'gender': value});
        }),
      ),
      _divider(),
      _buildListItem(
        Icons.monitor_weight_outlined,
        'Weight',
        _weight.isEmpty ? '' : '$_weight kg',
        true,
        () => _editText('Weight', _weight, (value) {
          _saveProfile({'weight': _nullableInt(value)});
        }),
      ),
      _divider(),
      _buildListItem(
        Icons.height,
        'Height',
        _height.isEmpty ? '' : '$_height cm',
        true,
        () => _editText('Height', _height, (value) {
          _saveProfile({'height': _nullableInt(value)});
        }),
      ),
    ]);
  }

  Widget _buildFitnessCard() {
    return _buildCard([
      _buildListItem(
        Icons.fitness_center,
        'Fitness Level',
        _fitnessLevel,
        true,
        () => _showPicker('Fitness Level', ['Beginner', 'Intermediate', 'Advanced'], (value) {
          _saveProfile({'fitness_level': value});
        }),
      ),
      _divider(),
      _buildListItem(
        Icons.flag_outlined,
        'Main Goal',
        _mainGoal,
        true,
        () => _showPicker(
          'Main Goal',
          ['Build Muscle', 'Lose Fat', 'Increase Endurance', 'Improve Flexibility'],
          (value) => _saveProfile({'main_goal': value}),
        ),
      ),
      _divider(),
      _buildListItem(
        Icons.access_time,
        'Workout Days',
        _workoutDays.isEmpty ? '' : '$_workoutDays days',
        true,
        () => _showPicker(
          'Workout Days',
          ['1', '2', '3', '4', '5', '6', '7'],
          (value) => _saveProfile({'workout_days': int.tryParse(value)}),
        ),
      ),
    ]);
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF11212D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF253745)),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, color: Color(0xFF253745));
  }

  Widget _buildListItem(
    IconData icon,
    String label,
    String value,
    bool editable,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: editable ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF9BA8AB)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
            Flexible(
              child: Text(
                value.isEmpty ? 'Tap to fill' : value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: value.isEmpty ? const Color(0xFF9BA8AB) : Colors.white,
                  fontStyle: value.isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
            if (editable) ...[
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 18, color: Color(0xFF9BA8AB)),
            ],
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
          foregroundColor: const Color(0xFFFF6B6B),
          side: const BorderSide(color: Color(0xFFFF6B6B), width: 1),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          'Log Out',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
