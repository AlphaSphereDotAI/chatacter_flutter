import 'package:flutter/material.dart';
import 'package:chatacter/styles/app_colors.dart';

class AppTextfield extends StatelessWidget {
  final String hint;
  final TextEditingController? controller; // Make controller nullable
  final bool enabled;
  final String? Function(String?)? validator; // Add validator parameter

  const AppTextfield({
    super.key,
    required this.hint,
    this.controller, // Remove 'required' keyword
    this.enabled = true,
    this.validator = null, // Make default value null
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      cursorColor: AppColors.fieldCursorColor,
      decoration: InputDecoration(
        hintText: hint,
        labelText: hint,
        labelStyle: TextStyle(color: AppColors.white),
        border: const UnderlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        focusedBorder: const UnderlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.transparent)),
        filled: true,
        fillColor: AppColors.fieldColor,
      ),
      validator: validator, // Use the validator
    );
  }
}
