import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import 'coach_chat_screen.dart';
import 'coach_checkout_screen.dart';

class Coach {
  final int id;
  final String name;
  final String specialty;
  final String experience;
  final double rating;
  final String imageUrl;
  final String bio;
  final int price;
  final bool online;
  final List<String> tags;

  const Coach({
    required this.id,
    required this.name,
    required this.specialty,
    required this.experience,
    required this.rating,
    required this.imageUrl,
    required this.bio,
    required this.price,
    required this.online,
    required this.tags,
  });

  factory Coach.fromJson(Map<String, dynamic> json) {
    return Coach(
      id: _toInt(json['id'] ?? json['ID']),
      name: '${json['name'] ?? json['Name'] ?? 'Trainer'}',
      specialty:
          '${json['specialty'] ?? json['Specialty'] ?? json['specialization'] ?? 'Personal Trainer'}',
      experience: '${json['experience'] ?? json['Experience'] ?? '-'}',
      rating: double.tryParse('${json['rating'] ?? json['Rating'] ?? '0'}') ?? 0,
      imageUrl: _resolveImage('${json['photo'] ?? json['Photo'] ?? ''}'),
      bio: '${json['bio'] ?? json['Bio'] ?? 'Trainer STABLE siap membantu konsultasi latihan kamu.'}',
      price: _toInt(json['price'] ?? json['Price'] ?? 29000),
      online: _toBool(json['is_online'] ?? json['online'] ?? json['Online']),
      tags: _toTags(json['tags'] ?? json['Tags'] ?? json['categories'] ?? json['Categories']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    return '$value'.toLowerCase() == 'true' || '$value' == '1';
  }

  static List<String> _toTags(dynamic value) {
    if (value is List) return value.map((item) => '$item').toList();
    return '$value'
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static String _resolveImage(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    final origin = AppConfig.baseUrl.replaceAll('/api/v1', '');
    return '$origin$path';
  }
}

class ActiveChatSession {
  final int sessionId;
  final int trainerId;
  final String trainerName;
  final String trainerSpecialty;
  final DateTime expiresAt;

  const ActiveChatSession({
    required this.sessionId,
    required this.trainerId,
    required this.trainerName,
    required this.trainerSpecialty,
    required this.expiresAt,
  });

  factory ActiveChatSession.fromJson(Map<String, dynamic> json) {
    return ActiveChatSession(
      sessionId: Coach._toInt(json['session_id']),
      trainerId: Coach._toInt(json['trainer_id']),
      trainerName: '${json['trainer_name'] ?? 'Trainer'}',
      trainerSpecialty: '${json['trainer_specialty'] ?? 'Personal Trainer'}',
      expiresAt: DateTime.parse('${json['expires_at']}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'trainer_id': trainerId,
      'trainer_name': trainerName,
      'trainer_specialty': trainerSpecialty,
      'expires_at': expiresAt.toIso8601String(),
    };
  }
}

class PersonalTrainerScreen extends StatefulWidget {
  const PersonalTrainerScreen({super.key});

  @override
  State<PersonalTrainerScreen> createState() => _PersonalTrainerScreenState();
}

class _PersonalTrainerScreenState extends State<PersonalTrainerScreen> {
  List<Coach> _coaches = [];
  ActiveChatSession? _activeSession;
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage() async {
    setState(() => _loading = true);
    await Future.wait([_loadActiveSession(), _loadTrainers()]);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('stable_active_trainer_chat');
    if (raw == null) {
      _activeSession = null;
      return;
    }

    try {
      final session = ActiveChatSession.fromJson(jsonDecode(raw));
      if (DateTime.now().isAfter(session.expiresAt)) {
        await prefs.remove('stable_active_trainer_chat');
        _activeSession = null;
        return;
      }
      _activeSession = session;
    } catch (_) {
      await prefs.remove('stable_active_trainer_chat');
      _activeSession = null;
    }
  }

  Future<void> _loadTrainers() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/trainer-chat/trainers'));
      final body = jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(body['message'] ?? 'Gagal memuat trainer.');
      }

      final data = body['data'] ?? body;
      final list = data is List ? data : <dynamic>[];
      _coaches = list
          .whereType<Map<String, dynamic>>()
          .map(Coach.fromJson)
          .toList();
    } catch (error) {
      _coaches = [];
      _showMessage('Tidak bisa memuat trainer.');
    }
  }

  List<Coach> get _filteredCoaches {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _coaches;
    return _coaches.where((coach) {
      return coach.name.toLowerCase().contains(q) ||
          coach.specialty.toLowerCase().contains(q) ||
          coach.tags.join(' ').toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _openCheckout(Coach coach) async {
    if (_activeSession != null && _activeSession!.trainerId == coach.id) {
      await _resumeSession();
      return;
    }

    if (!coach.online) {
      _showMessage('Trainer sedang offline.');
      return;
    }

    final result = await Navigator.push<ActiveChatSession>(
      context,
      MaterialPageRoute(
        builder: (_) => CoachCheckoutScreen(coach: coach),
      ),
    );

    if (result != null) {
      await _saveActiveSession(result);
      setState(() => _activeSession = result);
      await _resumeSession();
    }
  }

  Future<void> _saveActiveSession(ActiveChatSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stable_active_trainer_chat', jsonEncode(session.toJson()));
  }

  Future<void> _resumeSession() async {
    final session = _activeSession;
    if (session == null) return;

    if (DateTime.now().isAfter(session.expiresAt)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('stable_active_trainer_chat');
      setState(() => _activeSession = null);
      _showMessage('Sesi chat sudah berakhir.');
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoachChatScreen(session: session),
      ),
    );
    await _loadActiveSession();
    if (mounted) setState(() {});
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final coaches = _filteredCoaches;
    return Scaffold(
      backgroundColor: const Color(0xFF06141B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF06141B),
        elevation: 0,
        title: const Text(
          'Trainer Chat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPage,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_activeSession != null) _ResumeSessionCard(onTap: _resumeSession),
                  TextField(
                    onChanged: (value) => setState(() => _query = value),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Cari trainer atau goal...',
                      hintStyle: const TextStyle(color: Color(0xFF9BA8AB)),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF9BA8AB)),
                      filled: true,
                      fillColor: const Color(0xFF11212D),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF253745)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (coaches.isEmpty)
                    const _EmptyTrainerState()
                  else
                    ...coaches.map(
                      (coach) => _CoachCard(
                        coach: coach,
                        isResumable: _activeSession?.trainerId == coach.id,
                        onPressed: () => _openCheckout(coach),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _ResumeSessionCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ResumeSessionCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF11212D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4A90D9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer, color: Color(0xFF4A90D9)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Kamu masih punya sesi chat aktif.',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(onPressed: onTap, child: const Text('Lanjut')),
        ],
      ),
    );
  }
}

class _EmptyTrainerState extends StatelessWidget {
  const _EmptyTrainerState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF11212D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF253745)),
      ),
      child: const Text(
        'Belum ada trainer yang tersedia atau semua trainer sedang offline.',
        style: TextStyle(color: Color(0xFF9BA8AB)),
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  final Coach coach;
  final bool isResumable;
  final VoidCallback onPressed;

  const _CoachCard({
    required this.coach,
    required this.isResumable,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF11212D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF253745)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: const Color(0xFF253745),
                backgroundImage: coach.imageUrl.isNotEmpty ? NetworkImage(coach.imageUrl) : null,
                child: coach.imageUrl.isEmpty
                    ? Text(
                        _initials(coach.name),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coach.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coach.specialty,
                      style: const TextStyle(color: Color(0xFF9BA8AB), fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: coach.online ? const Color(0xFF5DD66B) : const Color(0xFF9BA8AB),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          coach.online ? 'Online' : 'Offline',
                          style: const TextStyle(color: Color(0xFF9BA8AB), fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(coach.bio, style: const TextStyle(color: Color(0xFFB8C3C7), height: 1.5)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: coach.tags
                .map(
                  (tag) => Chip(
                    label: Text(tag),
                    backgroundColor: const Color(0xFF172837),
                    labelStyle: const TextStyle(color: Colors.white, fontSize: 11),
                    side: const BorderSide(color: Color(0xFF253745)),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFFFD166), size: 18),
              const SizedBox(width: 4),
              Text('${coach.rating}', style: const TextStyle(color: Colors.white)),
              const SizedBox(width: 14),
              Text(coach.experience, style: const TextStyle(color: Color(0xFF9BA8AB))),
              const Spacer(),
              Text(
                _formatRupiah(coach.price),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: coach.online || isResumable ? onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90D9),
                disabledBackgroundColor: const Color(0xFF172837),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isResumable ? 'Lanjut Chat' : coach.online ? 'Bayar & Chat 10 Menit' : 'Offline',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    return name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();
  }

  String _formatRupiah(int value) {
    final text = value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return 'Rp $text';
  }
}
