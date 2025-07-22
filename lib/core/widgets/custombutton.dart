import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Color textColor;
  final Color mainColor;
  final String text;
  final VoidCallback onPress;

  const CustomButton({
    Key? key,
    required this.textColor,
    required this.mainColor,
    required this.text,
    required this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: mainColor, // màu nền
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onPress,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          padding: const EdgeInsets.all(15),
          child: Center(
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Poppins',
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
