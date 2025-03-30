
import 'package:flutter/material.dart';

class CustomSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final Function(String)? onChanged;
  final bool? autofocus;
  final VoidCallback? onClear;
  final InputDecoration? decoration;
  final Color? backgroundColor;

  const CustomSearchField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.autofocus = false,
    this.onClear,
    this.decoration,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      // Container to wrap the search field and provide box shadow.
      decoration: BoxDecoration(
        color: Colors.white, // White background for the search box.
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha:0.2)
                : Colors.grey.withValues(alpha:0.3),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        autofocus: autofocus ?? false,
        onChanged: onChanged,
        style: TextStyle(
          color: isDarkMode
              ? Colors.white
              : Colors
                  .black, 
        ),
        decoration: decoration ??
            InputDecoration(
              hintText: hintText ?? 'Search...',
              hintStyle: TextStyle(
                color: isDarkMode
                    ? Colors.white.withValues(alpha:0.7)
                    : Colors.black.withValues(alpha:0.6),
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: isDarkMode
                    ? Colors.white
                    : Colors
                        .black, 
              ),
              suffixIcon: controller?.text.isNotEmpty ?? false
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: isDarkMode
                            ? Colors.white.withValues(alpha:0.8)
                            : Colors.black.withValues(alpha:0.8),
                      ),
                      onPressed: onClear,
                    )
                  : null,
              filled: true,
              fillColor: backgroundColor ??
                  Colors.white, // White background for the search box
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDarkMode
                      ? Colors.white70
                      : Colors.black26, // Border color changes for dark mode
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.white70 : Colors.black26,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.white : Colors.deepOrange.shade400,
                  width: 0.1,
                ),
              ),
              // Add box shadow
              contentPadding:
                  EdgeInsets.symmetric(vertical: 15.0, horizontal: 12.0),
            ),
      ),
    );
  }
}
