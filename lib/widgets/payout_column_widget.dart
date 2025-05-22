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
        ...payouts.entries.map((e) => Text(
              '${e.key.padRight(14)} ${e.value}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            )),
      ],
    );
  }
}
