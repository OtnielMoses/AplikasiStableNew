import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF0A0C10);
  static const Color surface = Color(0xFF1A1C24);
  static const Color surfaceVariant = Color(0xFF12151C);
  static const Color surfaceElevated = Color(0xFF23262F);
  
  // Primary accent
  static const Color primary = Color(0xFF27AEF3);
  static const Color primaryDark = Color(0xFF1A8FCC);
  static const Color primaryLight = Color(0xFF5DC4F6);
  
  // Secondary accents
  static const Color secondary = Color(0xFF27AEF2);
  static const Color purple = Color(0xFF6C5CE7);
  static const Color blue = Color(0xFF4A90E2);
  static const Color red = Color(0xFFFF453A);
  static const Color green = Color(0xFF34C759);
  static const Color orange = Color(0xFFFF9500);
  static const Color yellow = Color(0xFFFFD60A);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFE0E0E0);
  static const Color textHint = Color(0xFF8E8E93);
  static const Color textDisabled = Color(0xFF6B6F7A);
  
  // Borders & dividers
  static const Color border = Color(0xFF2A2D35);
  static const Color borderLight = Color(0xFF30333B);
  static const Color divider = Color(0xFF1C1F26);
  
  // Status
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF453A);
  static const Color warning = Color(0xFFFFD60A);
  
  // Membership level colors
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color gold = Color(0xFFD4AF37);
  
  // Transparency helpers
  static Color withOpacity(Color color, double opacity) => color.withOpacity(opacity);
}