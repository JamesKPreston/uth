import 'package:flutter/material.dart';

class CardPlaceholder extends StatelessWidget {
  const CardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white24,
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
