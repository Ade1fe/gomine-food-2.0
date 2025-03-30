
import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType keyboardType;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final InputDecoration? decoration;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2), // Shadow position
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
        maxLines: maxLines,
        minLines: minLines,
        enabled: enabled,
        style: AppTextStyles.body.copyWith(
          color: Colors.black,
        ),
        decoration: decoration ??
            InputDecoration(
              hintText: hintText,
              labelText: labelText,
              hintStyle: AppTextStyles.body.copyWith(color: Colors.black),
              labelStyle: AppTextStyles.body.copyWith(
                color: isDarkMode ? AppColors.primary : AppColors.secondary,
              ),
              prefixIcon: prefixIcon != null
                  ? IconTheme(
                      data: IconThemeData(
                          color:
                              Colors.deepOrange), // Set prefix icon color here
                      child: prefixIcon!,
                    )
                  : null,
              suffixIcon: suffixIcon != null
                  ? IconTheme(
                      data: IconThemeData(
                          color:
                              Colors.deepOrange), // Set suffix icon color here
                      child: suffixIcon!,
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), // Rounded corners
                borderSide: BorderSide.none, // Removing default border color
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.deepOrange.shade700.withValues(alpha:0.6),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.deepOrange.shade400,
                  width: 1,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              errorStyle: AppTextStyles.caption.copyWith(color: Colors.red),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 15, horizontal: 12),
            ),
      ),
    );
  }
}
