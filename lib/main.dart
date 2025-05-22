import 'package:flutter/material.dart';
import 'package:ultimate_texas_holdem_poc/deck.dart';
import 'screens/texas_holdem.dart';
import 'screens/ultimate_texas_holdem_screen.dart';

void main() {
  runApp(const UTH());
}

class UTH extends StatelessWidget {
  const UTH({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Texas Hold\'em POC',
      home: UltimateTexasHoldemScreen(deck: Deck()),
      // home: UltimateTexasHoldem(deck: Deck()),
    );
  }
}
