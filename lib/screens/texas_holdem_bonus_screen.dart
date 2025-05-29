import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart' as playing_cards;
import 'package:ultimate_texas_holdem_poc/games/texas_holdem_bonus_poker.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/deck_interface.dart' as uth_deck;
import 'package:ultimate_texas_holdem_poc/interfaces/playing_card_interface.dart';
import 'package:ultimate_texas_holdem_poc/widgets/card_place_holder_widget.dart';
import 'package:ultimate_texas_holdem_poc/widgets/bet_circle_widget.dart';
import 'package:ultimate_texas_holdem_poc/widgets/payout_column_widget.dart';
import 'package:ultimate_texas_holdem_poc/utility/player.dart';
import 'package:ultimate_texas_holdem_poc/widgets/chip_widget.dart';
import 'package:ultimate_texas_holdem_poc/wrapper/playing_card_wrapper.dart';

class TexasHoldemBonusScreen extends StatefulWidget {
  final uth_deck.IDeck deck;
  const TexasHoldemBonusScreen({required this.deck, super.key});

  @override
  State<TexasHoldemBonusScreen> createState() => _TexasHoldemBonusScreenState();
}

class _TexasHoldemBonusScreenState extends State<TexasHoldemBonusScreen> {
  late final uth_deck.IDeck deck;
  final texasHoldemBonus = TexasHoldemBonus();
  BetCircle anteCircle = const BetCircle(label: 'ANTE');
  BetCircle flopCircle = const BetCircle(label: 'FLOP');
  BetCircle turnCircle = const BetCircle(label: 'TURN');
  BetCircle riverCircle = const BetCircle(label: 'RIVER');
  bool didFold = false;
  @override
  void initState() {
    super.initState();
    deck = widget.deck;
    texasHoldemBonus.player1 = Player(name: 'Player 1', bankroll: 1000);
  }

  void _dealHands() {
    setState(() {
      deck.shuffle();
      // // temp player cards: queen of hearts and queen of spades
      // List<IPlayingCard> tempPlayerCards = [
      //   PlayingCardWrapper(
      //     playing_cards.PlayingCard(
      //       playing_cards.Suit.diamonds,
      //       playing_cards.CardValue.three,
      //     ),
      //   ),
      //   PlayingCardWrapper(
      //     playing_cards.PlayingCard(
      //       playing_cards.Suit.hearts,
      //       playing_cards.CardValue.three,
      //     ),
      //   ),
      // ];
      // //temp dealer cards
      // List<IPlayingCard> tempDealerCards = [
      //   PlayingCardWrapper(
      //     playing_cards.PlayingCard(
      //       playing_cards.Suit.diamonds,
      //       playing_cards.CardValue.five,
      //     ),
      //   ),
      //   PlayingCardWrapper(
      //     playing_cards.PlayingCard(
      //       playing_cards.Suit.spades,
      //       playing_cards.CardValue.ace,
      //     ),
      //   ),
      // ];
      // //temp community cards
      // List<IPlayingCard> tempCommunityCards = [
      //   PlayingCardWrapper(
      //     playing_cards.PlayingCard(
      //       playing_cards.Suit.hearts,
      //       playing_cards.CardValue.eight,
      //     ),
      //   ),
      //   PlayingCardWrapper(
      //     playing_cards.PlayingCard(
      //       playing_cards.Suit.hearts,
      //       playing_cards.CardValue.seven,
      //     ),
      //   ),
      //   PlayingCardWrapper(
      //     playing_cards.PlayingCard(
      //       playing_cards.Suit.clubs,
      //       playing_cards.CardValue.three,
      //     ),
      //   ),
      //   PlayingCardWrapper(
      //     playing_cards.PlayingCard(
      //       playing_cards.Suit.hearts,
      //       playing_cards.CardValue.four,
      //     ),
      //   ),
      //   PlayingCardWrapper(
      //     playing_cards.PlayingCard(
      //       playing_cards.Suit.spades,
      //       playing_cards.CardValue.seven,
      //     ),
      //   ),
      // ];

      texasHoldemBonus.player1Cards = deck.draw(2);
      texasHoldemBonus.dealer = deck.draw(2);
      texasHoldemBonus.community = deck.draw(5);
      texasHoldemBonus.cardsDealt = true;
      texasHoldemBonus.showBacks = true;
      texasHoldemBonus.communityShowBacks = [true, true, true, true, true];
      texasHoldemBonus.twoX = true;
    });
  }

  // void _handleBet() {
  //   final betAmount = (texasHoldemBonus.totalAnte);
  //   _handleCheck();
  //   if (texasHoldemBonus.player1.bankroll >= betAmount) {
  //     setState(() {
  //       texasHoldemBonus.player1.bankroll -= texasHoldemBonus.playBet;
  //       texasHoldemBonus.currentBet = betAmount;
  //       texasHoldemBonus.gameEnded = true;
  //       texasHoldemBonus.showBacks = false;
  //     });
  //     _evaluateHands();
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Insufficient funds for bet'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   }
  // }

  void _evaluateHands() {
    var h1 = texasHoldemBonus.evaluate([...texasHoldemBonus.community, ...texasHoldemBonus.player1Cards]);
    var h2 = texasHoldemBonus.evaluate([...texasHoldemBonus.community, ...texasHoldemBonus.dealer]);
    final winners = texasHoldemBonus.winners([h1, h2]);

    setState(() {
      texasHoldemBonus.showBacks = false;
      texasHoldemBonus.player1Hand = h1.description;
      texasHoldemBonus.dealerHand = h2.description;

      if (winners.length == 2) {
        texasHoldemBonus.result = 'Tie: ${h1.name}';
        // Return ante, blind, and bet amount on tie
        texasHoldemBonus.player1.bankroll += texasHoldemBonus.totalAnte + texasHoldemBonus.playBet;
      } else {
        final winnerCards = winners[0].pokerCards;
        final player1Cards = h1.pokerCards;

        final isPlayer1Winner = winnerCards
            .every((card) => player1Cards.any((p1Card) => p1Card.value == card.value && p1Card.suit == card.suit));

        if (isPlayer1Winner) {
          var ante = texasHoldemBonus.ante.payout(h1, texasHoldemBonus.totalAnte);
          var bonus = texasHoldemBonus.bonus.payout(h1, texasHoldemBonus.totalAnte);
          var winnings = ante +
              bonus +
              (texasHoldemBonus.totalFlop * 2) +
              (texasHoldemBonus.totalTurn * 2) +
              (texasHoldemBonus.totalRiver * 2);
          texasHoldemBonus.result = 'Player 1 wins $winnings with ${h1.description}';
          texasHoldemBonus.player1.bankroll += winnings;
        } else {
          texasHoldemBonus.result = 'Dealer wins with ${h2.description}';
        }
      }
    });
  }

  void _handleCheck() {
    setState(() {
      texasHoldemBonus.checkRound++;
      texasHoldemBonus.twoX = false;
      texasHoldemBonus.oneX = true;
      if (texasHoldemBonus.checkRound == 1) {
        // Show first 3 community cards
        for (int i = 0; i < 3; i++) {
          texasHoldemBonus.communityShowBacks[i] = false;
        }
      } else if (texasHoldemBonus.checkRound == 2) {
        // Show turn
        for (int i = 3; i < 4; i++) {
          texasHoldemBonus.communityShowBacks[i] = false;
        }
      } else if (texasHoldemBonus.checkRound == 3) {
        // Fold was clicked
        if (!didFold) {
          _evaluateHands();
        }
        texasHoldemBonus.communityShowBacks[4] = false;
        texasHoldemBonus.gameEnded = true;
        texasHoldemBonus.showBacks = false; // Show all cards face up
        // Ensure all community cards are shown
        for (int i = 0; i < 5; i++) {
          texasHoldemBonus.communityShowBacks[i] = false;
        }
      }
    });
  }

  void _resetGame() {
    setState(() {
      // Reset all state variables
      texasHoldemBonus.showBacks = true;
      texasHoldemBonus.communityShowBacks = [true, true, true, true, true];
      texasHoldemBonus.player1Hand = '';
      texasHoldemBonus.dealerHand = '';
      texasHoldemBonus.result = '';
      texasHoldemBonus.checkRound = 0;
      texasHoldemBonus.gameEnded = false;
      texasHoldemBonus.currentBet = 0;
      texasHoldemBonus.cardsDealt = false;
      texasHoldemBonus.playBet = 0;

      // Clear out the ante, blind, and trips bet values and circles
      texasHoldemBonus.totalAnte = 0;
      anteCircle = const BetCircle(label: 'ANTE');
      flopCircle = const BetCircle(label: 'FLOP');
      turnCircle = const BetCircle(label: 'TURN');
      riverCircle = const BetCircle(label: 'RIVER');
      // Clear cards
      texasHoldemBonus.community.clear();
      texasHoldemBonus.player1Cards.clear();
      texasHoldemBonus.dealer.clear();
      texasHoldemBonus.twoX = false;
      texasHoldemBonus.oneX = false;
    });
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
                // TOP ROW: Total Bet | Chips | Bankroll
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Total Bet (left)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Total Bet: \$${(texasHoldemBonus.totalAnte + texasHoldemBonus.totalFlop + texasHoldemBonus.totalTurn + texasHoldemBonus.totalRiver).toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Chips (center)
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Draggable(
                          data: 1.0,
                          feedback: Material(
                            color: Colors.transparent,
                            child: ChipWidget(value: 1),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.5,
                            child: ChipWidget(value: 1),
                          ),
                          child: ChipWidget(
                            value: 1,
                          ),
                        ),
                        Draggable(
                          data: 5.0,
                          feedback: Material(
                            color: Colors.transparent,
                            child: ChipWidget(
                              value: 5,
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.5,
                            child: ChipWidget(
                              value: 5,
                            ),
                          ),
                          child: ChipWidget(
                            value: 5,
                          ),
                        ),
                        Draggable(
                          data: 10.0,
                          feedback: Material(
                            color: Colors.transparent,
                            child: ChipWidget(
                              value: 10,
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.5,
                            child: ChipWidget(
                              value: 10,
                            ),
                          ),
                          child: ChipWidget(
                            value: 10,
                          ),
                        ),
                        Draggable(
                          data: 25.0,
                          feedback: Material(
                            color: Colors.transparent,
                            child: ChipWidget(
                              value: 25,
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.5,
                            child: ChipWidget(
                              value: 25,
                            ),
                          ),
                          child: ChipWidget(
                            value: 25,
                          ),
                        ),
                        Draggable(
                          data: 100.0,
                          feedback: Material(
                            color: Colors.transparent,
                            child: ChipWidget(
                              value: 100,
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.5,
                            child: ChipWidget(
                              value: 100,
                            ),
                          ),
                          child: ChipWidget(
                            value: 100,
                          ),
                        ),
                      ],
                    ),
                    // Bankroll (right)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        '\$${texasHoldemBonus.player1.bankroll.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // CARDS ROW
                if (texasHoldemBonus.cardsDealt)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dealer cards
                      Column(
                        children: [
                          Text(
                            texasHoldemBonus.dealerHand ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              CardPlaceholder(card: texasHoldemBonus.dealer[0], showBack: texasHoldemBonus.showBacks),
                              CardPlaceholder(card: texasHoldemBonus.dealer[1], showBack: texasHoldemBonus.showBacks),
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
                            children: List.generate(
                                5,
                                (x) => CardPlaceholder(
                                    card: texasHoldemBonus.community[x],
                                    showBack:
                                        texasHoldemBonus.gameEnded ? false : texasHoldemBonus.communityShowBacks[x])),
                          ),
                        ],
                      ),
                      // Player cards
                      Column(
                        children: [
                          Text(
                            texasHoldemBonus.player1Hand ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              CardPlaceholder(card: texasHoldemBonus.player1Cards[0], showBack: false),
                              CardPlaceholder(card: texasHoldemBonus.player1Cards[1], showBack: false),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text('Player', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                // Game Result
                if (texasHoldemBonus.result.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      texasHoldemBonus.result,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                // CENTER BET SPOTS
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Centered ANTE and BLIND circles
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DragTarget<double>(
                                onWillAcceptWithDetails: (details) => true,
                                onAcceptWithDetails: (details) {
                                  setState(() {
                                    texasHoldemBonus.totalAnte += details.data;
                                    texasHoldemBonus.player1.bankroll -= details.data;
                                  });
                                  anteCircle =
                                      BetCircle(label: 'ANTE', chipWidget: anteCircle.buildChipWidget(details.data));
                                },
                                builder: (context, candidateData, rejectedData) {
                                  return anteCircle;
                                },
                              ),
                              DragTarget<String>(
                                onWillAcceptWithDetails: (details) => true,
                                onAcceptWithDetails: (details) {
                                  setState(() {
                                    texasHoldemBonus.totalFlop += double.parse(details.data);
                                    texasHoldemBonus.player1.bankroll -= double.parse(details.data);
                                    _handleCheck();
                                  });
                                  flopCircle = BetCircle(
                                      label: 'FLOP',
                                      chipWidget: flopCircle.buildChipWidget(double.parse(details.data)));
                                },
                                builder: (context, candidateData, rejectedData) {
                                  return flopCircle;
                                },
                              ),
                              DragTarget<String>(
                                onWillAcceptWithDetails: (details) => true,
                                onAcceptWithDetails: (details) {
                                  setState(() {
                                    texasHoldemBonus.totalTurn += double.parse(details.data);
                                    texasHoldemBonus.player1.bankroll -= double.parse(details.data);
                                    _handleCheck();
                                  });
                                  turnCircle = BetCircle(
                                      label: 'TURN',
                                      chipWidget: turnCircle.buildChipWidget(double.parse(details.data)));
                                },
                                builder: (context, candidateData, rejectedData) {
                                  return turnCircle;
                                },
                              ),
                              DragTarget<String>(
                                onWillAcceptWithDetails: (details) => true,
                                onAcceptWithDetails: (details) {
                                  setState(() {
                                    texasHoldemBonus.totalRiver += double.parse(details.data);
                                    texasHoldemBonus.player1.bankroll -= double.parse(details.data);
                                    _handleCheck();
                                  });
                                  riverCircle = BetCircle(
                                      label: 'RIVER',
                                      chipWidget: riverCircle.buildChipWidget(double.parse(details.data)));
                                },
                                builder: (context, candidateData, rejectedData) {
                                  return riverCircle;
                                },
                              ),
                              const SizedBox(width: 20),
                            ],
                          ),
                        ),
                        // Empty space on the right
                        const SizedBox(width: 48),
                      ],
                    ),
                  ],
                ),

                // Payout tables row below the play button
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF006400),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (texasHoldemBonus.gameEnded)
                ElevatedButton(
                  onPressed: _resetGame,
                  child: const Text('Deal Again'),
                )
              else ...[
                if (texasHoldemBonus.cardsDealt) ...[
                  ElevatedButton(
                    onPressed: texasHoldemBonus.checkRound < 3
                        ? () {
                            if (texasHoldemBonus.checkRound >= 2) {
                              setState(() {
                                didFold = true;
                              });
                            }
                            _handleCheck();
                          }
                        : null,
                    child: Text(texasHoldemBonus.checkRound < 2 ? 'Check' : 'Fold'),
                  ),
                  const SizedBox(width: 8),
                ],
                if (texasHoldemBonus.cardsDealt) ...[
                  if (texasHoldemBonus.twoX) ...[
                    Draggable(
                      data: (texasHoldemBonus.totalAnte * 2).toString(),
                      feedback: Material(
                        color: Colors.transparent,
                        child: ChipWidget(value: texasHoldemBonus.totalAnte * 2, label: '2x'),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: ChipWidget(value: texasHoldemBonus.totalAnte * 2, label: '2x'),
                      ),
                      child: ChipWidget(
                        value: texasHoldemBonus.totalAnte * 2,
                        label: '2x',
                      ),
                    ),
                  ],
                  if (texasHoldemBonus.oneX) ...[
                    Draggable(
                      data: (texasHoldemBonus.totalAnte).toString(),
                      feedback: Material(
                        color: Colors.transparent,
                        child: ChipWidget(value: texasHoldemBonus.totalAnte, label: '1x'),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: ChipWidget(value: texasHoldemBonus.totalAnte, label: '1x'),
                      ),
                      child: ChipWidget(
                        value: texasHoldemBonus.totalAnte,
                        label: '1x',
                      ),
                    ),
                  ],
                ],
                if (!texasHoldemBonus.cardsDealt) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: texasHoldemBonus.totalAnte > 0 ? _dealHands : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Deal Cards',
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
