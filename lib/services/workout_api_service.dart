import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutApiService {
  static const String apiBase = "http://localhost:8080/api/v1";

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Map<String, dynamic>? _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<int?> getCurrentUserId() async {
    final token = await _getToken();
    if (token == null) return null;
    final payload = _decodeJwt(token);
    final id = payload?['id'] ?? payload?['user_id'] ?? payload?['sub'] ?? payload?['ID'];
    if (id == null) return null;
    if (id is int) return id;
    return int.tryParse(id.toString());
  }

  static Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static String formatDateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// GET /workout-schedule/week?user_id=
  static Future<Map<String, dynamic>> getWeeklySchedule() async {
    final userId = await getCurrentUserId();
    if (userId == null) return {};

    try {
      final response = await http.get(
        Uri.parse('$apiBase/workout-schedule/week?user_id=$userId'),
        headers: await _headers(),
      );
      if (response.statusCode != 200) return {};

      final result = jsonDecode(response.body);
      final data = result['data'] ?? result;
      return (data['schedule'] ?? data ?? {}) as Map<String, dynamic>;
    } catch (error) {
      // eslint-style note: kalau backend belum jalan / network error, fallback kosong
      return {};
    }
  }

  /// GET /workout-progress?user_id=&date=&scope=
  static Future<List<String>> getCompletedIds(DateTime date, String scope) async {
    final userId = await getCurrentUserId();
    if (userId == null) return [];

    try {
      final dateKey = formatDateKey(date);
      final response = await http.get(
        Uri.parse(
          '$apiBase/workout-progress?user_id=$userId&date=$dateKey&scope=${Uri.encodeComponent(scope)}',
        ),
        headers: await _headers(),
      );
      if (response.statusCode != 200) return [];

      final result = jsonDecode(response.body);
      final data = result['data'] ?? result;
      final ids = data['completed_ids'] ?? data['completedIDs'] ?? [];
      return List<String>.from(ids);
    } catch (error) {
      return [];
    }
  }

  /// PUT /workout-progress
  static Future<bool> saveCompletedIds(
    DateTime date,
    String scope,
    List<String> completedIds,
  ) async {
    final userId = await getCurrentUserId();
    if (userId == null) return false;

    try {
      final response = await http.put(
        Uri.parse('$apiBase/workout-progress'),
        headers: await _headers(),
        body: jsonEncode({
          'user_id': userId,
          'date': formatDateKey(date),
          'scope': scope,
          'completed_ids': completedIds,
        }),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (error) {
      return false;
    }
  }

  /// GET /daily-challenge/today?user_id=
  static Future<Map<String, dynamic>?> getDailyChallenge() async {
    final userId = await getCurrentUserId();
    if (userId == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$apiBase/daily-challenge/today?user_id=$userId'),
        headers: await _headers(),
      );
      if (response.statusCode != 200) return null;

      final result = jsonDecode(response.body);
      return (result['data'] ?? result) as Map<String, dynamic>;
    } catch (error) {
      return null;
    }
  }

  /// POST /daily-challenge/complete
  static Future<Map<String, dynamic>?> completeDailyChallenge(int repetitions) async {
    final userId = await getCurrentUserId();
    if (userId == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$apiBase/daily-challenge/complete'),
        headers: await _headers(),
        body: jsonEncode({'user_id': userId, 'repetitions': repetitions}),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) return null;

      final result = jsonDecode(response.body);
      return (result['data'] ?? result) as Map<String, dynamic>;
    } catch (error) {
      return null;
    }
  }
}