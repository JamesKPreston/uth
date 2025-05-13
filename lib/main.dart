import 'package:flutter/material.dart';
import 'package:ultimate_texas_holdem_poc/deck.dart';
import 'widgets/texas_holdem.dart';

void main() {
  runApp(const UTH());
}

class UTH extends StatelessWidget {
  const UTH({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Texas Hold\'em POC',
      home: UltimateTexasHoldem(deck: Deck()),
    );
  }
}
