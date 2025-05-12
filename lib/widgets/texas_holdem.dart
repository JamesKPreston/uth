import 'dart:math';
import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:poker_solver/poker_solver.dart';
import 'package:ultimate_texas_holdem_poc/utility/poker_hand.dart';
import 'package:ultimate_texas_holdem_poc/deck.dart';

class TexasHoldemDemo extends StatefulWidget {
  const TexasHoldemDemo({super.key});

  @override
  TexasHoldemDemoState createState() => TexasHoldemDemoState();
}

class TexasHoldemDemoState extends State<TexasHoldemDemo> {
  Deck deck = Deck();
  List<PlayingCard> deckOld = [];
  List<PlayingCard> player1 = [];
  List<PlayingCard> dealer = [];
  List<PlayingCard> community = [];
  List<PlayingCard> burnPile = [];
  bool showBacks = true;
  String? player1Hand = '';
  String? dealerHand = '';
  String result = '';
  String? selectedBetMultiplier;
  List<String> availableMultipliers = ['4x', '3x'];
  int checkRound = 0;
  bool gameEnded = false;

  @override
  void initState() {
    super.initState();
    _dealHands();
  }

  void _dealHands() {
    deck.shuffle();
    player1 = deck.draw(2);
    dealer = deck.draw(2);
    community = deck.draw(5);

    setState(() {});
  }

  void _evaluateHands() {
    final h1 = PokerHand().evaluate([...community, ...player1]);
    final h2 = PokerHand().evaluate([...community, ...dealer]);
    final winners = Hand.winners([h1, h2]);

    setState(() {
      showBacks = false;
      // store each player's best hand name
      player1Hand = h1.descr;
      dealerHand = h2.descr;

      if (winners.length == 2) {
        result = 'Tie: ${h1.name}';
      } else if (winners[0] == h1) {
        result = 'Player 1 wins with ${h1.descr}';
      } else {
        result = 'Dealer wins with ${h2.descr}';
      }
    });
  }

  void _handleBet() {
    setState(() {
      gameEnded = true;
      showBacks = false; // Show all cards face up
    });
    _evaluateHands();
  }

  void _handleCheck() {
    setState(() {
      checkRound++;
      if (checkRound == 1) {
        // Show first 3 community cards and update dropdown to 2x
        // for (int i = 0; i < 3; i++) {
        //   community[i] = community[i];
        // }
        availableMultipliers = ['2x'];
        selectedBetMultiplier = '2x';
      } else if (checkRound == 2) {
        // Show remaining 2 community cards and update dropdown to 1x
        // for (int i = 3; i < 5; i++) {
        //   community[i] = community[i];
        // }
        availableMultipliers = ['1x'];
        selectedBetMultiplier = '1x';
      } else if (checkRound == 3) {
        // Fold was clicked
        gameEnded = true;
        showBacks = false; // Show all cards face up
      }
    });
  }

  void _resetGame() {
    setState(() {
      // Reset all state variables
      showBacks = true;
      player1Hand = '';

      dealerHand = '';
      result = '';
      selectedBetMultiplier = '4x';
      availableMultipliers = ['3x', '4x'];
      checkRound = 0;
      gameEnded = false;

      // Clear and re deal cards
      community.clear();
      burnPile.clear();
      player1.clear();
      dealer.clear();
      _dealHands();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Texas Hold\'em POC'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hole cards & best hand
              Text(
                'Player 1: $player1Hand',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: player1
                    .map((c) => SizedBox(
                          width: 100,
                          height: 100 * (89.0 / 64.0),
                          child: PlayingCardView(card: c, showBack: false),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Text(
                'Dealer: $dealerHand',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: dealer
                    .map((c) => SizedBox(
                          width: 100,
                          height: 100 * (89.0 / 64.0),
                          child: PlayingCardView(card: c, showBack: showBacks),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              // Community cards
              const Text('Community Cards:', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: community.asMap().entries.map((entry) {
                  final index = entry.key;
                  final card = entry.value;
                  if (gameEnded) {
                    return SizedBox(
                      width: 100,
                      height: 100 * (89.0 / 64.0),
                      child: PlayingCardView(
                        card: card,
                        showBack: false,
                      ),
                    );
                  } else {
                    return SizedBox(
                      width: 100,
                      height: 100 * (89.0 / 64.0),
                      child: PlayingCardView(
                        card: card,
                        showBack: index < 3 ? checkRound < 1 : checkRound < 2,
                      ),
                    );
                  }
                }).toList(),
              ),
              const SizedBox(height: 24),
              // Add these buttons before the Evaluate button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (gameEnded)
                    ElevatedButton(
                      onPressed: _resetGame,
                      child: const Text('Deal Again'),
                    )
                  else ...[
                    ElevatedButton(
                      onPressed: checkRound < 3 ? _handleCheck : null,
                      child: Text(checkRound < 2 ? 'Check' : 'Fold'),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: selectedBetMultiplier ?? availableMultipliers.first,
                      items: availableMultipliers
                          .map((multiplier) => DropdownMenuItem(
                                value: multiplier,
                                child: Text(multiplier),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedBetMultiplier = value;
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _handleBet,
                      child: const Text('Bet'),
                    ),
                  ],
                ],
              ),
              if (result.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(result, style: const TextStyle(fontSize: 16)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
