import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../config.dart';
import 'personal_trainer_screen.dart';

class CoachCheckoutScreen extends StatefulWidget {
  final Coach coach;

  const CoachCheckoutScreen({super.key, required this.coach});

  @override
  State<CoachCheckoutScreen> createState() => _CoachCheckoutScreenState();
}

class _CoachCheckoutScreenState extends State<CoachCheckoutScreen> {
  WebViewController? _webViewController;
  Timer? _pollingTimer;
  int? _sessionId;
  bool _loading = true;
  String _message = 'Membuat pembayaran...';

  @override
  void initState() {
    super.initState();
    _createCheckout();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _createCheckout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ??
          int.tryParse(prefs.getString('user_id') ?? '');
      final name = prefs.getString('name') ??
          prefs.getString('username') ??
          'User STABLE';
      final email = prefs.getString('email') ?? '';

      if (userId == null) {
        throw Exception('Silakan login ulang sebelum membeli sesi.');
      }

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/trainer-chat/checkout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'trainer_id': widget.coach.id,
          'customer_name': name,
          'customer_email': email,
        }),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
            body['message'] ?? body['error'] ?? 'Gagal membuat pembayaran.');
      }

      final data = body['data'] ?? body;
      final redirectUrl = '${data['redirect_url'] ?? ''}';
      _sessionId = _toInt(data['session_id']);

      if (_sessionId == null || redirectUrl.isEmpty) {
        throw Exception('Data pembayaran dari server tidak lengkap.');
      }

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) => _checkSessionStatus(),
            onWebResourceError: (_) {
              _checkSessionStatus();
            },
            onNavigationRequest: (request) {
              final url = request.url;

              final isFinishRedirect = url.contains('127.0.0.1:5501') ||
                  url.contains('localhost:5501') ||
                  url.contains('/page/trainer.html') ||
                  url.contains('order_id=');

              if (isFinishRedirect) {
                setState(() {
                  _message = 'Pembayaran terdeteksi. Memverifikasi status...';
                  _loading = true;
                });

                _markSessionPaidForDev().then((_) => _checkSessionStatus());

                return NavigationDecision.prevent;
              }

              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(redirectUrl));

      _startPolling();

      if (!mounted) return;
      setState(() {
        _webViewController = controller;
        _loading = false;
        _message = 'Selesaikan pembayaran Midtrans.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkSessionStatus();
    });
  }

  Future<void> _markSessionPaidForDev() async {
    final sessionId = _sessionId;
    if (sessionId == null) return;

    await http.post(
      Uri.parse(
          '${AppConfig.baseUrl}/trainer-chat/sessions/$sessionId/dev-paid'),
    );
  }

  Future<void> _checkSessionStatus() async {
    final sessionId = _sessionId;
    if (sessionId == null) return;

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/trainer-chat/sessions/$sessionId'),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) return;

      final body = jsonDecode(response.body);
      final data = body['data'] ?? body;
      final status = '${data['status'] ?? ''}'.toLowerCase();

      if (status != 'paid') return;

      final expiresAtRaw = data['expires_at'];
      final expiresAt = expiresAtRaw == null || '$expiresAtRaw'.isEmpty
          ? DateTime.now().add(const Duration(minutes: 10))
          : DateTime.parse('$expiresAtRaw');

      _pollingTimer?.cancel();
      if (!mounted) return;

      Navigator.pop(
        context,
        ActiveChatSession(
          sessionId: sessionId,
          trainerId: _toInt(data['trainer_id']) ?? widget.coach.id,
          trainerName: '${data['trainer_name'] ?? widget.coach.name}',
          trainerSpecialty:
              '${data['trainer_specialty'] ?? widget.coach.specialty}',
          expiresAt: expiresAt,
        ),
      );
    } catch (_) {
      return;
    }
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06141B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF06141B),
        elevation: 0,
        title: const Text('Payment', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_message,
                      style: const TextStyle(color: Color(0xFF9BA8AB))),
                ],
              ),
            )
          : _webViewController == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.white, size: 48),
                        const SizedBox(height: 14),
                        Text(
                          _message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: _createCheckout,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : WebViewWidget(controller: _webViewController!),
    );
  }
}
