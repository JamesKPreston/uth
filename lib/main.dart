import 'package:flutter/material.dart';
import 'package:ultimate_texas_holdem_poc/deck.dart';
import 'widgets/texas_holdem.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Texas Hold\'em POC',
      home: TexasHoldemDemo(deck: Deck()),
    );
  }
}
