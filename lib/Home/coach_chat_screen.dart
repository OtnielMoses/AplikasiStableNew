import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config.dart';
import 'personal_trainer_screen.dart';

class ChatMessage {
  final int id;
  final String sender;
  final String text;
  final DateTime createdAt;

  const ChatMessage({
    this.id = 0,
    required this.sender,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final rawSender = '${json['sender'] ?? ''}'.toLowerCase();
    return ChatMessage(
      id: _toInt(json['id'] ?? json['ID']),
      sender: rawSender == 'client' ? 'user' : rawSender,
      text: '${json['message'] ?? json['Message'] ?? json['text'] ?? json['content'] ?? ''}',
      createdAt: DateTime.tryParse(
            '${json['created_at'] ?? json['CreatedAt'] ?? json['timestamp'] ?? ''}',
          ) ??
          DateTime.now(),
    );
  }

  String get stableKey {
    if (id > 0) return 'id:$id';
    return '$sender|$text|${createdAt.millisecondsSinceEpoch ~/ 1000}';
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }
}

class CoachChatScreen extends StatefulWidget {
  final ActiveChatSession session;

  const CoachChatScreen({super.key, required this.session});

  @override
  State<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends State<CoachChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  WebSocketChannel? _channel;
  Timer? _timer;
  Timer? _messagePollingTimer;
  Duration _remaining = Duration.zero;
  bool _connected = false;
  bool _loading = true;
  final List<ChatMessage> _messages = [];
  final Set<String> _messageKeys = {};

  @override
  void initState() {
    super.initState();
    _remaining = widget.session.expiresAt.difference(DateTime.now());
    _loadSession();
    _connectWebSocket();
    _startTimer();
    _startMessagePolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messagePollingTimer?.cancel();
    _channel?.sink.close();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String get _wsBase {
    final uri = Uri.parse(AppConfig.baseUrl);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    final host = kIsWeb
        ? uri.host
        : Platform.isAndroid && uri.host == 'localhost'
            ? '10.0.2.2'
            : uri.host;
    final port = uri.hasPort ? ':${uri.port}' : '';
    return '$scheme://$host$port';
  }

  String get _apiPath {
    return Uri.parse(AppConfig.baseUrl).path.replaceAll(RegExp(r'/$'), '');
  }

  Future<void> _loadSession({bool showLoading = false}) async {
    if (showLoading && mounted) setState(() => _loading = true);

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/trainer-chat/sessions/${widget.session.sessionId}'),
      );
      final body = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = body['data'] ?? body;
        final messages = data['messages'] is List ? data['messages'] as List : <dynamic>[];
        final parsedMessages = messages
            .whereType<Map<String, dynamic>>()
            .map(ChatMessage.fromJson)
            .where((message) => message.text.trim().isNotEmpty)
            .toList();

        _mergeMessages(parsedMessages);
      }
    } catch (_) {
      // Chat tetap bisa jalan lewat WebSocket meski history gagal dimuat.
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _scrollToBottom();
      }
    }
  }

  void _mergeMessages(List<ChatMessage> incoming) {
    var changed = false;

    for (final message in incoming) {
      if (_messageKeys.contains(message.stableKey)) continue;
      _messageKeys.add(message.stableKey);
      _messages.add(message);
      changed = true;
    }

    if (!changed) return;

    _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (mounted) setState(() {});
    _scrollToBottom();
  }

  void _connectWebSocket() {
    final url =
        '$_wsBase$_apiPath/trainer-chat/sessions/${widget.session.sessionId}/ws?role=user';

    try {
      final channel = WebSocketChannel.connect(Uri.parse(url));
      _channel = channel;
      setState(() => _connected = true);

      channel.stream.listen(
        (event) {
          final data = jsonDecode(event);
          if (data['type'] != 'message') return;

          final sender = '${data['sender'] ?? ''}';
          final text = '${data['message'] ?? data['content'] ?? ''}';
          if (text.isEmpty) return;

          if (sender == 'user') return;

          _mergeMessages([
            ChatMessage(
              sender: sender,
              text: text,
              createdAt: DateTime.now(),
            ),
          ]);
        },
        onDone: () => setState(() => _connected = false),
        onError: (_) => setState(() => _connected = false),
      );
    } catch (_) {
      setState(() => _connected = false);
    }
  }

  void _startMessagePolling() {
    _messagePollingTimer?.cancel();
    _messagePollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_remaining.inSeconds > 0) {
        _loadSession();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final diff = widget.session.expiresAt.difference(DateTime.now());
      if (diff.isNegative || diff.inSeconds <= 0) {
        _timer?.cancel();
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('stable_active_trainer_chat');
        if (mounted) setState(() => _remaining = Duration.zero);
        return;
      }
      if (mounted) setState(() => _remaining = diff);
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _remaining.inSeconds <= 0) return;

    _messageController.clear();
    final message = ChatMessage(sender: 'user', text: text, createdAt: DateTime.now());
    _mergeMessages([message]);

    final wsSent = _sendWebSocket(text);
    await _sendMessageRest(text);

    if (!wsSent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesan disimpan, realtime sedang reconnect.')),
      );
    }
  }

  bool _sendWebSocket(String text) {
    try {
      _channel?.sink.add(jsonEncode({'type': 'message', 'message': text}));
      return _connected;
    } catch (_) {
      return false;
    }
  }

  Future<void> _sendMessageRest(String text) async {
    try {
      await http.post(
        Uri.parse('${AppConfig.baseUrl}/trainer-chat/sessions/${widget.session.sessionId}/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sender': 'user', 'message': text}),
      );
    } catch (_) {
      return;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  String _formatRemaining() {
    final minutes = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _formatTime(DateTime value) {
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final ended = _remaining.inSeconds <= 0;
    return Scaffold(
      backgroundColor: const Color(0xFF06141B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF06141B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.session.trainerName,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            ),
            Text(
              '${_connected ? 'Online' : 'Connecting'} - ${_formatRemaining()}',
              style: const TextStyle(color: Color(0xFF9BA8AB), fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Belum ada pesan. Mulai tanya trainer kamu sekarang.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF9BA8AB)),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.sender == 'user';
                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.76,
                              ),
                              decoration: BoxDecoration(
                                color: isMe ? const Color(0xFF4A90D9) : const Color(0xFF11212D),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFF253745)),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.text,
                                    style: const TextStyle(color: Colors.white, height: 1.45),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _formatTime(message.createdAt),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.68),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          if (ended)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF11212D),
              child: const Text(
                'Sesi chat sudah berakhir.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF9BA8AB)),
              ),
            )
          else
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF11212D),
                  border: Border(top: BorderSide(color: Color(0xFF253745))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Tulis pesan...',
                          hintStyle: const TextStyle(color: Color(0xFF9BA8AB)),
                          filled: true,
                          fillColor: const Color(0xFF06141B),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFF253745)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      onPressed: _sendMessage,
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFF4A90D9)),
                      icon: const Icon(Icons.send, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
