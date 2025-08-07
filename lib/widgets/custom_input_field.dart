import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final String? errorText;
  final int? maxLength;
  final FocusNode? focusNode;

  const CustomInputField({
    super.key,
    required this.label,
    this.obscure = false,
    this.keyboardType,
    this.controller,
    this.onChanged,
    this.errorText,
    this.maxLength,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscure,
            keyboardType: keyboardType,
            maxLength: maxLength,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: label,
              errorText: errorText,
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
