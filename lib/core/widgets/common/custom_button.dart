import 'package:flutter/material.dart';
import 'package:stable_app/core/constants/app_colors.dart';
import 'package:stable_app/core/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final bool isText;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.isText = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = isText
        ? TextButton(
            onPressed: isLoading ? null : onPressed,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(text),
          )
        : isOutlined
            ? OutlinedButton(
                onPressed: isLoading ? null : onPressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: textColor ?? AppColors.primary,
                  side: BorderSide(color: backgroundColor ?? AppColors.primary),
                  minimumSize: Size(width ?? double.infinity, height ?? 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : icon != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Icon(icon!), const SizedBox(width: 8), Text(text)],
                          )
                        : Text(text),
              )
            : ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor ?? AppColors.primary,
                  foregroundColor: textColor ?? Colors.black,
                  minimumSize: Size(width ?? double.infinity, height ?? 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : icon != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Icon(icon!), const SizedBox(width: 8), Text(text)],
                          )
                        : Text(text),
              );

    return SizedBox(width: width, child: button);
  }
}