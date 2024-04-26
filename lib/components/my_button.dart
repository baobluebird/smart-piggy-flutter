import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final bool checkButton;
  final Color customColor;
  final String text;
  final void Function()? onTap;

  const MyButton({
    super.key,
    required this.customColor,
    required this.text,
    required this.onTap, this.checkButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 25),
          decoration: BoxDecoration(
            color: customColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: checkButton ? const CircularProgressIndicator():Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ));
  }
}