import 'package:flutter/material.dart';
import 'package:ultimate_texas_holdem_poc/widgets/chip_widget.dart';

class BetCircle extends StatelessWidget {
  final String label;
  final ChipWidget? chipWidget;

  const BetCircle({
    super.key,
    required this.label,
    this.chipWidget,
  });
  // Add import for ChipImageType and ChipWidget if needed, but omitted here per instructions.
  ChipWidget? buildChipWidget(double value) {
    ChipImageType? imageType;
    if (value == 1) {
      imageType = ChipImageType.white;
    } else if (value < 10) {
      imageType = ChipImageType.red;
    } else if (value < 25) {
      imageType = ChipImageType.ten;
    } else if (value < 100) {
      imageType = ChipImageType.green;
    } else if (value < 1000) {
      imageType = ChipImageType.black;
    } else {
      imageType = null;
    }

    if (imageType != null) {
      return ChipWidget(value: value, imageType: imageType);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        if (chipWidget != null) chipWidget!,
      ],
    );
  }
}
