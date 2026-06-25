import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'personal_trainer_screen.dart';

class CoachChatScreen extends StatefulWidget {
  final Coach coach;
  final Duration sessionDuration;
  final bool isResuming;

  const CoachChatScreen({
    super.key,
    required this.coach,
    required this.sessionDuration,
    this.isResuming = false,
  });

  @override
  State<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends State<CoachChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  late Duration _remaining;
  Timer? _timer;
  bool _isSessionEnded = false;
  bool _isRatingDialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadRemainingTime();
    _loadMessages();
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh waktu saat aplikasi kembali ke foreground
      _loadRemainingTime();
    }
  }

  Future<void> _loadRemainingTime() async {
    final prefs = await SharedPreferences.getInstance();
    final endTime = prefs.getString('sessionEndTime');
    if (endTime != null) {
      final endDateTime = DateTime.parse(endTime);
      final now = DateTime.now();
      if (endDateTime.isAfter(now)) {
        setState(() {
          _remaining = endDateTime.difference(now);
        });
      } else {
        // Session sudah habis
        _endSession();
      }
    } else {
      // Jika tidak ada endTime, set default
      setState(() {
        _remaining = widget.sessionDuration;
      });
      _saveEndTime();
    }
  }

  Future<void> _saveEndTime() async {
    final prefs = await SharedPreferences.getInstance();
    final endTime = DateTime.now().add(widget.sessionDuration);
    await prefs.setString('sessionEndTime', endTime.toIso8601String());
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isSessionEnded) {
        setState(() {
          if (_remaining.inSeconds > 0) {
            _remaining = _remaining - const Duration(seconds: 1);
          } else {
            _timer?.cancel();
            _endSession();
          }
        });
      }
    });
  }

  Future<void> _endSession() async {
    if (_isSessionEnded) return;
    setState(() {
      _isSessionEnded = true;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isChatSessionActive');
    await prefs.remove('currentCoachId');
    await prefs.remove('sessionEndTime');
    if (mounted && !_isRatingDialogShown) {
      _isRatingDialogShown = true;
      _showRatingDialog();
    }
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1C24),
        title: const Text(
          "Session Ended",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Your 15-minute session is over. Please rate your coach:",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    Icons.star,
                    color: index < 3 ? Colors.orange : Colors.grey,
                  ),
                  onPressed: () {
                    // TODO: simpan rating
                    Navigator.pop(context);
                    // Kembali ke list coach
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const PersonalTrainerScreen()),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('chat_history_${widget.coach.id}');
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      setState(() {
        _messages.clear();
        _messages.addAll(decoded.map((e) => Map<String, dynamic>.from(e)).toList());
      });
      _scrollToBottom();
    } else {
      if (!widget.isResuming) {
        _addMessage("Halo! Saya ${widget.coach.name}, siap membantu Anda. Ada yang bisa saya bantu?", false);
      }
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_messages);
    await prefs.setString('chat_history_${widget.coach.id}', encoded);
  }

  void _addMessage(String text, bool isMe) {
    setState(() {
      _messages.add({
        'text': text,
        'isMe': isMe,
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
    _saveMessages();
    _scrollToBottom();
  }

  void _sendMessage() {
    if (_isSessionEnded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session ended. You cannot send messages.")),
      );
      return;
    }
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    _addMessage(text, true);
    _simulateCoachReply();
  }

  void _simulateCoachReply() {
    if (_isSessionEnded) return;
    final List<String> replies = [
      "Baik, saya catat.",
      "Teruskan latihan Anda.",
      "Jangan lupa istirahat.",
      "Apakah ada yang ingin ditanyakan?",
      "Saya siap membantu.",
    ];
    final reply = replies[DateTime.now().millisecondsSinceEpoch % replies.length];
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && !_isSessionEnded) {
        _addMessage(reply, false);
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0C10),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            // Kembali ke home screen (index 0)
            _timer?.cancel();
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4FF33).withOpacity(0.2),
              ),
              child: Center(
                child: Text(
                  widget.coach.name[0],
                  style: const TextStyle(
                    color: Color(0xFFD4FF33),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.coach.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _isSessionEnded
                        ? "Session Ended"
                        : "${_remaining.inMinutes}:${(_remaining.inSeconds % 60).toString().padLeft(2, '0')}",
                    style: TextStyle(
                      color: _isSessionEnded ? Colors.red : const Color(0xFFD4FF33),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Opsi clear chat
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSessionEnded)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.red.withOpacity(0.3),
              child: const Center(
                child: Text(
                  "Session Ended",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['isMe'] as bool;
                final text = msg['text'] as String;
                final time = DateTime.parse(msg['timestamp'] as String);
                final formattedTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFFD4FF33) : const Color(0xFF1A1C24),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                        bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text,
                          style: TextStyle(
                            color: isMe ? Colors.black : Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            color: isMe ? Colors.black54 : Colors.grey[500],
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1C24),
              border: Border(top: BorderSide(color: const Color(0xFF2A2D35))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: _isSessionEnded ? "Session ended" : "Tulis pesan...",
                      hintStyle: const TextStyle(color: Color(0xFF8E8E93)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF2A2D35),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    enabled: !_isSessionEnded,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _isSessionEnded ? Colors.grey : const Color(0xFFD4FF33),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.black,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}