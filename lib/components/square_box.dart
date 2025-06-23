import 'package:flutter/material.dart';

class SquareBox extends StatelessWidget {
  final String imagePath;

  const SquareBox({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.asset(imagePath, height: 32),
    );
  }
}
