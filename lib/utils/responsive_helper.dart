import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Cek apakah layar kecil (HP kecil)
  static bool isSmall(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;

  // Cek apakah layar sedang (HP normal)
  static bool isMedium(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= 360 && w < 600;
  }

  // Cek apakah layar besar (tablet/desktop)
  static bool isLarge(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  // Ukuran font responsif
  static double fontSize(BuildContext context, double base) {
    if (isSmall(context)) return base * 0.7;
    if (isMedium(context)) return base * 0.85;
    return base;
  }

  // Padding horizontal responsif
  static double hPadding(BuildContext context) {
    if (isSmall(context)) return 10;
    if (isMedium(context)) return 20;
    return 50;
  }

  // Tinggi gambar responsif
  static double imageHeight(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    if (isSmall(context)) return h * 0.3;
    if (isMedium(context)) return h * 0.4;
    return h * 0.5;
  }

  // Margin kiri teks responsif
  static double textLeft(BuildContext context) {
    if (isSmall(context)) return 20;
    if (isMedium(context)) return 40;
    return 80;
  }
}