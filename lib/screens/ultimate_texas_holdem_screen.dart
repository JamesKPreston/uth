import 'package:flutter/material.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/deck_interface.dart' as uth_deck;
import 'package:ultimate_texas_holdem_poc/interfaces/playing_card_interface.dart';
import 'package:ultimate_texas_holdem_poc/widgets/card_place_holder_widget.dart';
import 'package:ultimate_texas_holdem_poc/widgets/bet_circle_widget.dart';
import 'package:ultimate_texas_holdem_poc/widgets/payout_column_widget.dart';
import 'package:ultimate_texas_holdem_poc/wrapper/playing_card_wrapper.dart';
import 'package:ultimate_texas_holdem_poc/player.dart';

class UltimateTexasHoldemScreen extends StatefulWidget {
  final uth_deck.IDeck deck;
  const UltimateTexasHoldemScreen({required this.deck, super.key});

  @override
  State<UltimateTexasHoldemScreen> createState() => _UltimateTexasHoldemScreenState();
}

class _UltimateTexasHoldemScreenState extends State<UltimateTexasHoldemScreen> {
  late final uth_deck.IDeck deck;
  late Player player1;
  List<IPlayingCard> player1Cards = [];
  List<IPlayingCard> dealer = [];
  List<IPlayingCard> community = [];
  List<PlayingCardWrapper> tempPlayer = [];
  List<PlayingCardWrapper> tempDealer = [];
  bool showBacks = false;
  String? player1Hand = '';
  String? dealerHand = '';
  String result = '';
  String? selectedBetMultiplier;
  List<String> availableMultipliers = ['4x', '3x'];
  int checkRound = 0;
  bool gameEnded = false;
  final TextEditingController anteController = TextEditingController(text: '15');
  double anteAmount = 15;
  double currentBet = 0;
  double totalAnteBlind = 0; // Track total ante + blind amount
  double trips = 5;
  @override
  void initState() {
    super.initState();
    deck = widget.deck;
    player1 = Player(name: 'Player 1', bankroll: 1000);
    _dealHands();
  }

  void _dealHands() {
    deck.shuffle();
    player1Cards = deck.draw(2);
    dealer = deck.draw(2);
    community = deck.draw(5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF006400), // felt green
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                const SizedBox(height: 12),
                // // Dealer cards
                // Column(
                //   children: [
                //     Text(
                //       'Dealer: $dealerHand',
                //       style: const TextStyle(fontWeight: FontWeight.bold),
                //     ),
                //     Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: dealer
                //           .map((c) => SizedBox(
                //                 width: 70,
                //                 height: 70 * (89.0 / 64.0),
                //                 child: playing_cards.PlayingCardView(card: c.toPlayingCard(), showBack: showBacks),
                //               ))
                //           .toList(),
                //     ),
                //   ],
                // ),

                // // Community cards
                // Column(
                //   children: [
                //     const Text('Community Cards:', style: TextStyle(fontWeight: FontWeight.bold)),
                //     Wrap(
                //       alignment: WrapAlignment.center,
                //       spacing: 4,
                //       runSpacing: 4,
                //       children: community.asMap().entries.map((entry) {
                //         final index = entry.key;
                //         final card = entry.value;
                //         if (gameEnded) {
                //           return SizedBox(
                //             width: 70,
                //             height: 70 * (89.0 / 64.0),
                //             child: playing_cards.PlayingCardView(
                //               card: card.toPlayingCard(),
                //               showBack: false,
                //             ),
                //           );
                //         } else {
                //           return SizedBox(
                //             width: 70,
                //             height: 70 * (89.0 / 64.0),
                //             child: playing_cards.PlayingCardView(
                //               card: card.toPlayingCard(),
                //               showBack: index < 3 ? checkRound < 1 : checkRound < 2,
                //             ),
                //           );
                //         }
                //       }).toList(),
                //     ),
                //   ],
                // ),

                // // Player cards
                // Column(
                //   children: [
                //     Text(
                //       'Player 1: $player1Hand',
                //       style: const TextStyle(fontWeight: FontWeight.bold),
                //     ),
                //     Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: player1Cards
                //           .map((c) => SizedBox(
                //                 width: 70,
                //                 height: 70 * (89.0 / 64.0),
                //                 child: playing_cards.PlayingCardView(card: c.toPlayingCard(), showBack: false),
                //               ))
                //           .toList(),
                //     ),
                //   ],
                // ),

                // CARDS ROW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dealer cards
                    Column(
                      children: [
                        Row(
                          children: [
                            CardPlaceholder(card: dealer[0], showBack: showBacks),
                            CardPlaceholder(card: dealer[1], showBack: showBacks),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('Dealer', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    // Community cards
                    Column(
                      children: [
                        const Text(
                          'Community Board',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(5, (x) => CardPlaceholder(card: community[x], showBack: showBacks)),
                        ),
                      ],
                    ),
                    // Player cards
                    Column(
                      children: [
                        Row(
                          children: [
                            CardPlaceholder(card: player1Cards[0], showBack: showBacks),
                            CardPlaceholder(card: player1Cards[1], showBack: showBacks),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('Player', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // CENTER BET SPOTS
                const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PayoutColumn(
                          title: 'TRIPS',
                          payouts: {
                            'Royal Flush': '50 to 1',
                            'Straight Flush': '40 to 1',
                            'Quads': '30 to 1',
                            'Full House': '8 to 1',
                            'Flush': '6 to 1',
                            'Straight': '5 to 1',
                            'Trips': '3 to 1',
                          },
                        ),
                        SizedBox(width: 12),
                        BetCircle(label: 'TRIPS'),
                        // Center betting circles
                        Row(
                          children: [
                            SizedBox(width: 150),
                            BetCircle(label: 'ANTE'),
                            SizedBox(width: 20),
                            BetCircle(label: 'BLIND'),
                            SizedBox(width: 150),
                          ],
                        ),
                        // Right side with BLIND payout
                        PayoutColumn(
                          title: 'BLIND',
                          payouts: {
                            'Royal Flush': '500 to 1',
                            'Straight Flush': '50 to 1',
                            'Quads': '10 to 1',
                            'Full House': '3 to 1',
                            'Other Hands': 'Push*',
                          },
                        ),
                      ],
                    ),
                    BetCircle(label: 'PLAY'),
                  ],
                ),

                const SizedBox(height: 12),

                // BALANCE
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '\$1285',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
