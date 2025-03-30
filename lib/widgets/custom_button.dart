
import 'package:flutter/material.dart';
// import '../theme/theme.dart';

enum ButtonType { primary, outline }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Widget? icon;
  final bool isLoading;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.borderRadius,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final Color defaultBackgroundColor = type == ButtonType.primary
        ? Colors.deepOrange.shade400
        : Colors.transparent;
    final Color defaultTextColor =
        type == ButtonType.primary ? Colors.white : Colors.deepOrange.shade400;
    final Color defaultBorderColor = Colors.deepOrange.shade400;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? defaultBackgroundColor,
          foregroundColor: textColor ?? defaultTextColor,
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 8),
            side: BorderSide(
              color: type == ButtonType.outline
                  ? (borderColor ?? defaultBorderColor)
                  : Colors.transparent,
            ),
          ),
        ).copyWith(
          elevation: WidgetStateProperty.all(
              5), // Adding a subtle elevation (shadow)
          shadowColor: WidgetStateProperty.all(
              isDarkMode ? Colors.black45 : Colors.grey.withValues(alpha:0.3)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize ?? 16,
                      fontWeight: fontWeight ?? FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
