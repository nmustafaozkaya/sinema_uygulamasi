import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/constant/app_text_style.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const RoundedButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.8,

      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: color,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            foregroundColor: Colors.white,
          ),
          child: Text(text, style: AppTextStyle.MIDDLE_BUTTON_TEXT),
        ),
      ),
    );
  }
}
