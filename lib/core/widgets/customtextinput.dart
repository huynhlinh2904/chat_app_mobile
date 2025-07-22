import 'package:flutter/material.dart';

class CustomTextInput extends StatelessWidget {
  final String hintText;
  final IconData leading;
  final ValueChanged<String> onChanged;
  final bool obscure;
  final TextInputType keyboard;

  const CustomTextInput({
    Key? key,
    required this.hintText,
    required this.leading,
    required this.onChanged,
    this.obscure = false,
    this.keyboard = TextInputType.text, required Function(dynamic val) userTyped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.only(left: 10),
      width: MediaQuery.of(context).size.width * 0.70,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        onChanged: onChanged,
        keyboardType: keyboard,
        obscureText: obscure,
        decoration: InputDecoration(
          icon: Icon(
            leading,
            color: Colors.deepPurple,
          ),
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(fontFamily: 'Poppins'),
        ),
      ),
    );
  }
}
