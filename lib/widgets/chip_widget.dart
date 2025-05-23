import 'package:flutter/material.dart';

enum ChipImageType {
  red,
  green,
  black,
  ten,
  white,
}

class ChipWidget extends StatelessWidget {
  final double value;
  final ChipImageType imageType;
  final double size;

  const ChipWidget({
    Key? key,
    required this.value,
    required this.imageType,
    this.size = 48,
  }) : super(key: key);

  String _getAssetPath() {
    switch (imageType) {
      case ChipImageType.red:
        return 'assets/red_chip.png';
      case ChipImageType.green:
        return 'assets/green_chip.png';
      case ChipImageType.black:
        return 'assets/black_chip.png';
      case ChipImageType.ten:
        return 'assets/10_chip.png';
      case ChipImageType.white:
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
      ],
    );
  }
}
