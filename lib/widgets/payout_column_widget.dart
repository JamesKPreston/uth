import 'package:flutter/material.dart';

class PayoutColumn extends StatelessWidget {
  final String title;
  final Map<String, String> payouts;

  const PayoutColumn({
    super.key,
    required this.title,
    required this.payouts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) {
            // Find the max width of the keys for alignment
            final keyTexts = payouts.keys
                .map((k) => TextPainter(
                      text: TextSpan(text: k, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      textDirection: TextDirection.ltr,
                    )..layout())
                .toList();
            final maxKeyWidth =
                keyTexts.isNotEmpty ? keyTexts.map((tp) => tp.width).reduce((a, b) => a > b ? a : b) : 0.0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: payouts.entries
                  .map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: maxKeyWidth + 8, // 8px padding after key
                              child: Text(
                                e.key,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Builder(
                              builder: (context) {
                                double valueColWidth = constraints.maxWidth.isFinite
                                    ? constraints.maxWidth - (maxKeyWidth + 8 + 2 + 8)
                                    : 120.0; // fallback width if unbounded
                                valueColWidth = valueColWidth > 0 ? valueColWidth : 60.0;
                                return SizedBox(
                                  width: valueColWidth,
                                  child: Text(
                                    e.value,
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
