// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:playing_cards/playing_cards.dart';
// import 'package:playing_cards_layouts/playing_cards_layouts.dart';
// import 'package:poker_solver/poker_solver.dart';

// class TexasHoldemDemo extends StatefulWidget {
//   const TexasHoldemDemo({super.key});

//   @override
//   TexasHoldemDemoState createState() => TexasHoldemDemoState();
// }

// class TexasHoldemDemoState extends State<TexasHoldemDemo> {
//   List<PlayingCard> deck = [];
//   List<PlayingCard> player1 = [];
//   List<PlayingCard> player2 = [];
//   List<PlayingCard> community = [];
//   List<PlayingCard> burnPile = [];
//   List<Map<String, dynamic>> communityLayouts = [];
//   String? player1Hand = '';
//   String? player2Hand = '';
//   String result = '';

//   @override
//   void initState() {
//     super.initState();
//     _dealHands();
//   }

//   void _dealHands() {
//     // build & shuffle
//     deck = List.from(standardFiftyFourCardDeck())
//       ..removeWhere(
//           (c) => c.value == CardValue.joker_1 || c.value == CardValue.joker_2)
//       ..shuffle(Random());

//     // deal hole cards
//     player1 = [deck.removeAt(0), deck.removeAt(0)];
//     player2 = [deck.removeAt(0), deck.removeAt(0)];

//     // flop
//     burnPile.add(deck.removeAt(0));
//     community.addAll([deck.removeAt(0), deck.removeAt(0), deck.removeAt(0)]);
//     // turn
//     burnPile.add(deck.removeAt(0));
//     community.add(deck.removeAt(0));
//     // river
//     burnPile.add(deck.removeAt(0));
//     community.add(deck.removeAt(0));

//     // create a List<Map> for handCards: each map needs a 'card'
//     communityLayouts = handCards(
//       community.map((c) => {'card': c}).toList(),
//       {
//         "flow": "horizontal",
//         "spacing": -0.2,
//         "width": 80.0,
//       },
//     );

//     setState(() {});
//   }

//   void _evaluateHands() {
//     final comm = community.map(_cardToCode).toList();
//     final h1 = Hand.solveHand([...player1.map(_cardToCode), ...comm]);
//     final h2 = Hand.solveHand([...player2.map(_cardToCode), ...comm]);
//     final winners = Hand.winners([h1, h2]);

//     setState(() {
//       // store each player's best hand name
//       player1Hand = h1.descr;
//       player2Hand = h2.descr;

//       if (winners.length == 2) {
//         result = 'Tie: ${h1.name}';
//       } else if (winners[0] == h1) {
//         result = 'Player 1 wins with ${h1.descr}';
//       } else {
//         result = 'Player 2 wins with ${h2.descr}';
//       }
//     });
//   }

//   String _cardToCode(PlayingCard c) {
//     const valueMap = {
//       CardValue.two: '2',
//       CardValue.three: '3',
//       CardValue.four: '4',
//       CardValue.five: '5',
//       CardValue.six: '6',
//       CardValue.seven: '7',
//       CardValue.eight: '8',
//       CardValue.nine: '9',
//       CardValue.ten: 'T',
//       CardValue.jack: 'J',
//       CardValue.queen: 'Q',
//       CardValue.king: 'K',
//       CardValue.ace: 'A',
//     };
//     const suitMap = {
//       Suit.clubs: 'c',
//       Suit.diamonds: 'd',
//       Suit.hearts: 'h',
//       Suit.spades: 's',
//     };
//     return valueMap[c.value]! + suitMap[c.suit]!;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Texas Hold\'em POC')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Hole cards & best hand
//             Text(
//               'Player 1: $player1Hand',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Row(
//               children: player1
//                   .map((c) => SizedBox(
//                         width: 160,
//                         height: 160 * (89.0 / 64.0),
//                         child: PlayingCardView(card: c),
//                       ))
//                   .toList(),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Player 2: $player2Hand',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             Row(
//               children: player2
//                   .map((c) => SizedBox(
//                         width: 160,
//                         height: 160 * (89.0 / 64.0),
//                         child: PlayingCardView(card: c),
//                       ))
//                   .toList(),
//             ),
//             const SizedBox(height: 24),

//             // Burn pile
//             const Text('Burn Pile:',
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             Row(
//               children: burnPile
//                   .map((_) => SizedBox(
//                         width: 160,
//                         height: 160 * (89.0 / 64.0),
//                         child: PlayingCardView(card: _, showBack: true),
//                       ))
//                   .toList(),
//             ),
//             const SizedBox(height: 24),

//             // Community cards
//             const Text('Community Cards:',
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             Row(
//               children: community
//                   .map((c) => SizedBox(
//                         width: 160,
//                         height: 160 * (89.0 / 64.0),
//                         child: PlayingCardView(card: c),
//                       ))
//                   .toList(),
//             ),
//             const SizedBox(height: 24),

//             ElevatedButton(
//               onPressed: _evaluateHands,
//               child: const Text('Evaluate Hands'),
//             ),
//             if (result.isNotEmpty) ...[
//               const SizedBox(height: 12),
//               Text(result, style: const TextStyle(fontSize: 16)),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
