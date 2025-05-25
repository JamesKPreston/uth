import 'package:flutter/material.dart';

class ChipWidget extends StatelessWidget {
  final double value;
  final double size;
  final String? label;

  const ChipWidget({
    Key? key,
    required this.value,
    this.size = 48,
    this.label,
  }) : super(key: key);

  String _getAssetPath() {
    if (value >= 100) {
      return 'assets/black_chip.png';
    } else if (value >= 25) {
      return 'assets/green_chip.png';
    } else if (value >= 5) {
      return 'assets/red_chip.png';
    } else {
      return 'assets/white_chip.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          _getAssetPath(),
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
        Text(
          label != null ? '$label' : value.toStringAsFixed(0),
          style: TextStyle(
            color: Colors.black,
            fontSize: size * 0.25,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: const Offset(1, 1),
                blurRadius: 2,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
