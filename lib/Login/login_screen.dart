import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Email dan password wajib diisi.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      final data = _decodeBody(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = data['message'] ?? data['error'] ?? 'Login gagal.';
        _showMessage(message.toString());
        return;
      }

      await _saveAuthResponse(data);
      _goToHome();
    } on TimeoutException {
      _showMessage('Request timeout. Coba lagi.');
    } catch (error) {
      _showMessage('Tidak bisa connect ke server.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> loginWithGoogle() async {
    if (_isGoogleLoading) return;

    setState(() => _isGoogleLoading = true);

    try {
      final callbackUrl = await FlutterWebAuth2.authenticate(
        url: '${AppConfig.baseUrl}/auth/google/login?source=mobile',
        callbackUrlScheme: 'stable',
      );

      final uri = Uri.parse(callbackUrl);
      final token = uri.queryParameters['token'];
      final error = uri.queryParameters['error'];

      if (error != null && error.isNotEmpty) {
        _showMessage('Google login gagal.');
        return;
      }

      if (token == null || token.isEmpty) {
        _showMessage('Token Google login tidak ditemukan.');
        return;
      }

      await _saveTokenAndFetchUser(token);
      _goToHome();
    } catch (error) {
      final message = error.toString().toLowerCase();

      if (message.contains('cancel') || message.contains('canceled')) {
        return;
      }

      _showMessage('Google login gagal connect ke server.');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Map<String, dynamic> _decodeBody(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {};
  }

  Future<void> _saveAuthResponse(Map<String, dynamic> response) async {
    final data = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : response;

    final token = '${data['token'] ?? ''}';
    final user = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : <String, dynamic>{};

    if (token.isEmpty) {
      throw Exception('Token tidak ditemukan dari server.');
    }

    final role = '${user['role'] ?? user['Role'] ?? ''}'.toUpperCase();

    if (role == 'TRAINER') {
      throw Exception('Akun trainer hanya bisa login melalui website.');
    }

    await _saveAuth(token: token, user: user);
  }

  Future<void> _saveTokenAndFetchUser(String token) async {
    final payload = _parseJwt(token);
    final userId =
        payload['id'] ?? payload['user_id'] ?? payload['sub'] ?? payload['ID'];
    final role = '${userId['role'] ?? userId['Role'] ?? ''}'.toUpperCase();

    if (role == 'TRAINER') {
      throw Exception('Akun trainer hanya bisa login melalui website.');
    }
    
    Map<String, dynamic> user = {};
    if (userId != null) {
      try {
        final response = await http.get(
          Uri.parse('${AppConfig.baseUrl}/users/$userId'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final body = _decodeBody(response.body);
          final data = body['data'] ?? body;
          if (data is Map<String, dynamic>) user = data;
        }
      } catch (_) {
        user = {};
      }
    }

    if (user.isEmpty) {
      user = {
        'id': userId,
        'username': payload['username'] ?? payload['name'] ?? '',
        'email': payload['email'] ?? '',
        'role': payload['role'] ?? 'USER',
      };
    }

    await _saveAuth(token: token, user: user);
  }

  Future<void> _saveAuth({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final id = user['id'] ?? user['ID'] ?? user['user_id'] ?? user['UserID'];
    final username = user['username'] ??
        user['Username'] ??
        user['name'] ??
        user['Name'] ??
        '';
    final email = user['email'] ?? user['Email'] ?? '';
    final role = user['role'] ?? user['Role'] ?? 'USER';

    await prefs.setString('token', token);
    if (id != null) {
      final parsedId = id is int ? id : int.tryParse(id.toString());
      if (parsedId != null) {
        await prefs.setInt('user_id', parsedId);
        await prefs.setString('id', parsedId.toString());
      }
    }
    await prefs.setString('username', username.toString());
    await prefs.setString('name', username.toString());
    await prefs.setString('email', email.toString());
    await prefs.setString('role', role.toString());
    await prefs.setBool('remember_me', _rememberMe);
  }

  Map<String, dynamic> _parseJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};

      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      return {};
    }

    return {};
  }

  void _goToHome() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06141B),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Welcome Stablers!',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              _label('EMAIL'),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 20),
              _label('PASSWORD'),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _isLoading ? null : login(),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white54,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                      activeColor: const Color(0xFF4A90D9),
                      checkColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Remember me',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _isLoading || _isGoogleLoading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8EDF2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Color(0xFF06141B),
                            strokeWidth: 2.6,
                          ),
                        )
                      : const Text(
                          'SIGN IN',
                          style: TextStyle(
                            color: Color(0xFF06141B),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 28),
              const Row(
                children: [
                  Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: OutlinedButton(
                  onPressed:
                      _isLoading || _isGoogleLoading ? null : loginWithGoogle,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFF11212D),
                    side: const BorderSide(color: Color(0xFF253745)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isGoogleLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.6,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.g_mobiledata,
                                color: Colors.white, size: 30),
                            SizedBox(width: 12),
                            Text(
                              'Continue with Google',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'New to STABLE? ',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text(
                        'Create an account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String value) {
    return Text(
      value,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 13,
        letterSpacing: 0.5,
      ),
    );
  }

  InputDecoration _inputDecoration({Widget? suffix}) {
    return InputDecoration(
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFF11212D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF253745)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF4A90D9)),
      ),
    );
  }
}
