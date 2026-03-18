import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class GradientText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final TextAlign textAlign;
  final Gradient gradient;

  const GradientText(
    this.text, {
    super.key,
    required this.fontSize,
    this.fontWeight = FontWeight.w900,
    this.letterSpacing = 5.0,
    this.textAlign = TextAlign.left,
    this.gradient = const LinearGradient(
      colors: [Colors.white, Colors.grey],
    ),
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: ResponsiveHelper.fontSize(context, fontSize),
          fontWeight: fontWeight,
          letterSpacing: ResponsiveHelper.isSmall(context)
              ? letterSpacing * 0.5
              : letterSpacing,
        ),
      ),
    );
  }
}