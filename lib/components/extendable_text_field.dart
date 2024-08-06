import 'package:flutter/material.dart';

class ExtendableTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final int minLines; // Add minLines parameter

  const ExtendableTextField({
    required this.hint,
    required this.controller,
    required this.focusNode,
    required this.minLines, // Initialize minLines
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      minLines: minLines,
      maxLines: null, // Allows the TextField to expand vertically
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.all(16),
      ),
    );
  }
}
