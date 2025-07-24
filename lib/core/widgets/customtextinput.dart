import 'package:flutter/material.dart';

class CustomTextInput extends StatelessWidget {
  final String hintText;
  final IconData leading;
  final bool obscure;
  final TextInputType keyboard;
  final void Function(String)? onChanged;
  final TextEditingController? controller;

  const CustomTextInput({
    super.key,
    required this.hintText,
    required this.leading,
    required this.obscure,
    required this.keyboard,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(leading),
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
