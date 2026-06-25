import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stable_app/core/constants/app_colors.dart';
import 'package:stable_app/core/constants/app_text_styles.dart';
import 'package:stable_app/core/utils/formatter.dart';
import 'package:stable_app/core/widgets/common/custom_button.dart';
import 'personal_trainer_screen.dart';
import 'coach_chat_screen.dart';

class CoachCheckoutScreen extends StatefulWidget {
  final Coach coach;
  const CoachCheckoutScreen({super.key, required this.coach});

  @override
  State<CoachCheckoutScreen> createState() => _CoachCheckoutScreenState();
}

class _CoachCheckoutScreenState extends State<CoachCheckoutScreen> {
  final int price = 20000; // fixed 20k

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Hire Coach"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context, false), // return false jika batal
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoachCard(),
            const SizedBox(height: 24),
            _buildPriceSection(),
            const SizedBox(height: 24),
            _buildPaymentMethodSection(),
            const Spacer(),
            CustomButton(
              text: "Pay Now",
              onPressed: () => _showPaymentDialog(context),
              width: double.infinity,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCoachCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2D35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[800],
              ),
              child: const Icon(Icons.person, size: 32, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.coach.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.coach.specialty,
                    style: const TextStyle(
                      color: Color(0xFFD4FF33),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Consultation Fee",
            style: AppTextStyles.bodyLarge,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatter.formatPrice(price),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                "15 min session",
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Payment Method",
          style: AppTextStyles.bodyLarge,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.qr_code_scanner, size: 28, color: Colors.black),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "QRIS",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Scan QR code with any payment app",
                      style: TextStyle(fontSize: 12, color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Icon(Icons.check, size: 14, color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              "Payment QRIS",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.qr_code, size: 160, color: Colors.black),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Scan this QR code using your payment app to complete transaction",
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessDialog(context);
            },
            child: const Text("I've Paid", style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: AppColors.textHint)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    _setSessionActive();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check_circle, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 12),
            const Text(
              "Payment Successful!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You've hired ${widget.coach.name}.",
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "You will be connected to chat. Session lasts 15 minutes.",
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
        actions: [
          CustomButton(
            text: "Start Chat",
            onPressed: () {
              // Kembalikan true ke halaman sebelumnya (PersonalTrainerScreen) agar refresh
              Navigator.pop(context, true); // tutup dialog sukses
              // Navigasi ke chat screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => CoachChatScreen(
                    coach: widget.coach,
                    sessionDuration: const Duration(minutes: 15),
                    isResuming: false,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _setSessionActive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isChatSessionActive', true);
    await prefs.setString('currentCoachId', widget.coach.id);
  }
}