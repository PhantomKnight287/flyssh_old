import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final bool? obscureText;
  final Widget? suffixIcon;
  final TextStyle? hintStyle;
  final int? maxLines;
  final int? minLines;
  final bool? readOnly;
  final Function(String)? onChanged;

  const InputField({
    required this.hintText,
    required this.keyboardType,
    required this.controller,
    this.validator,
    this.prefixIcon,
    this.obscureText,
    this.suffixIcon,
    this.hintStyle,
    super.key,
    this.maxLines,
    this.minLines,
    this.onChanged,
    this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readOnly ?? false,
      keyboardType: keyboardType,
      controller: controller,
      obscureText: obscureText ?? false,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        contentPadding: const EdgeInsets.all(8.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        prefixIconColor: AdaptiveTheme.of(context).mode.isDark ? Colors.grey : Colors.black,
        fillColor: AdaptiveTheme.of(context).mode.isLight ? Colors.grey.shade200 : Colors.grey.shade800,
        filled: true,
        hintStyle: hintStyle,
        suffixIcon: suffixIcon,
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
