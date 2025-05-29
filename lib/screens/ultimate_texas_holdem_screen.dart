import 'package:flutter/material.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/deck_interface.dart' as uth_deck;
import 'package:ultimate_texas_holdem_poc/widgets/card_place_holder_widget.dart';
import 'package:ultimate_texas_holdem_poc/widgets/bet_circle_widget.dart';
import 'package:ultimate_texas_holdem_poc/widgets/payout_column_widget.dart';
import 'package:ultimate_texas_holdem_poc/utility/player.dart';
import 'package:ultimate_texas_holdem_poc/widgets/chip_widget.dart';
import 'package:ultimate_texas_holdem_poc/games/ultimate_texas_holdem.dart';

class UltimateTexasHoldemScreen extends StatefulWidget {
  final uth_deck.IDeck deck;
  const UltimateTexasHoldemScreen({required this.deck, super.key});

  @override
  State<UltimateTexasHoldemScreen> createState() => _UltimateTexasHoldemScreenState();
}

class _UltimateTexasHoldemScreenState extends State<UltimateTexasHoldemScreen> {
  late final uth_deck.IDeck deck;
  final ultimateTexasHoldem = UltimateTexasHoldem();
  BetCircle tripsCircle = const BetCircle(label: 'TRIPS');
  BetCircle anteCircle = const BetCircle(label: 'ANTE');
  BetCircle blindCircle = const BetCircle(label: 'BLIND');
  BetCircle playCircle = const BetCircle(label: 'PLAY');
  @override
  void initState() {
    super.initState();
    deck = widget.deck;
    ultimateTexasHoldem.player1 = Player(name: 'Player 1', bankroll: 1000);
  }

  void _dealHands() {
    setState(() {
      deck.shuffle();
      // // temp player cards: queen of hearts and queen of spades
      // List<IPlayingCard> tempPlayerCards = [
      //   PlayingCardWrapper(
      //     playing_cards.PlayingCard(
      //       playing_cards.Suit.spades,
      //       playing_cards.CardValue.ace,
      //     ),
      //   ),
      //   PlayingCardWrapper(
      //     playing_cards.PlayingCard(
      //       playing_cards.Suit.clubs,
      //       playing_cards.CardValue.king,
      //     ),
      //   ),
      // ];
      // //temp dealer cards
      // List<IPlayingCard> tempDealerCards = [
      //   PlayingCardWrapper(
      //     playing_cards.PlayingCard(
      //       playing_cards.Suit.diamonds,
      //       playing_cards.CardValue.ace,
      //     ),
      //   ),
      //   PlayingCardWrapper(
      //     playing_cards.PlayingCard(
      //       playing_cards.Suit.clubs,
      //       playing_cards.CardValue.two,
      //     ),
      //   ),
      // ];
      // //temp community cards
      // List<IPlayingCard> tempCommunityCards = [
      //   PlayingCardWrapper(
      //     playing_cards.PlayingCard(
      //       playing_cards.Suit.hearts,
      //       playing_cards.CardValue.six,
      //     ),
      //   ),
      //   PlayingCardWrapper(
      //     playing_cards.PlayingCard(
      //       playing_cards.Suit.diamonds,
      //       playing_cards.CardValue.six,
      //     ),
      //   ),
      //   PlayingCardWrapper(
      //     playing_cards.PlayingCard(
      //       playing_cards.Suit.clubs,
      //       playing_cards.CardValue.six,
      //     ),
      //   ),
      //   PlayingCardWrapper(
      //     playing_cards.PlayingCard(
      //       playing_cards.Suit.spades,
      //       playing_cards.CardValue.six,
      //     ),
      //   ),
      //   PlayingCardWrapper(
      //     playing_cards.PlayingCard(
      //       playing_cards.Suit.hearts,
      //       playing_cards.CardValue.ace,
      //     ),
      //   ),
      // ];

      ultimateTexasHoldem.player1Cards = deck.draw(2);
      ultimateTexasHoldem.dealer = deck.draw(2);
      ultimateTexasHoldem.community = deck.draw(5);
      ultimateTexasHoldem.cardsDealt = true;
      ultimateTexasHoldem.showBacks = true;
      ultimateTexasHoldem.communityShowBacks = [true, true, true, true, true];
    });
  }

  void _handleBet() {
    final betAmount = (ultimateTexasHoldem.totalAnteBlind / 2) + ultimateTexasHoldem.playBet;

    if (ultimateTexasHoldem.player1.bankroll >= betAmount) {
      setState(() {
        ultimateTexasHoldem.player1.bankroll -= ultimateTexasHoldem.playBet;
        ultimateTexasHoldem.currentBet = betAmount;
        ultimateTexasHoldem.gameEnded = true;
        ultimateTexasHoldem.showBacks = false;
      });
      _evaluateHands();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient funds for bet'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _evaluateHands() {
    var h1 = ultimateTexasHoldem.evaluate([...ultimateTexasHoldem.community, ...ultimateTexasHoldem.player1Cards]);
    var h2 = ultimateTexasHoldem.evaluate([...ultimateTexasHoldem.community, ...ultimateTexasHoldem.dealer]);
    final winners = ultimateTexasHoldem.winners([h1, h2]);

    setState(() {
      ultimateTexasHoldem.showBacks = false;
      ultimateTexasHoldem.player1Hand = h1.description;
      ultimateTexasHoldem.dealerHand = h2.description;

      if (winners.length == 2) {
        ultimateTexasHoldem.result = 'Tie: ${h1.name}';
        // Return ante, blind, and bet amount on tie
        ultimateTexasHoldem.player1.bankroll += ultimateTexasHoldem.totalAnteBlind + ultimateTexasHoldem.playBet;
      } else {
        final winnerCards = winners[0].pokerCards;
        final player1Cards = h1.pokerCards;

        final isPlayer1Winner = winnerCards
            .every((card) => player1Cards.any((p1Card) => p1Card.value == card.value && p1Card.suit == card.suit));

        if (isPlayer1Winner) {
          var ante = ultimateTexasHoldem.ante.payout(h2, ultimateTexasHoldem.totalAnteBlind / 2);
          var blind = ultimateTexasHoldem.blind.payout(h1, ultimateTexasHoldem.totalAnteBlind / 2);
          var tripsBet = ultimateTexasHoldem.trips.payout(h1, ultimateTexasHoldem.tripsBet);
          var winnings = ante + blind + (ultimateTexasHoldem.playBet * 2) + tripsBet;
          ultimateTexasHoldem.result = 'Player 1 wins $winnings with ${h1.description}';
          ultimateTexasHoldem.player1.bankroll += winnings;
        } else {
          ultimateTexasHoldem.result = 'Dealer wins with ${h2.description}';
        }
      }
    });
  }

  void _handleCheck() {
    setState(() {
      ultimateTexasHoldem.checkRound++;
      if (ultimateTexasHoldem.checkRound == 1) {
        // Show first 3 community cards
        for (int i = 0; i < 3; i++) {
          ultimateTexasHoldem.communityShowBacks[i] = false;
        }
        ultimateTexasHoldem.fourX = false;
        ultimateTexasHoldem.threeX = false;
        ultimateTexasHoldem.twoX = true;
        ultimateTexasHoldem.oneX = false;
      } else if (ultimateTexasHoldem.checkRound == 2) {
        // Show remaining 2 community cards
        for (int i = 3; i < 5; i++) {
          ultimateTexasHoldem.communityShowBacks[i] = false;
        }
        ultimateTexasHoldem.fourX = false;
        ultimateTexasHoldem.threeX = false;
        ultimateTexasHoldem.twoX = false;
        ultimateTexasHoldem.oneX = true;
      } else if (ultimateTexasHoldem.checkRound == 3) {
        // Fold was clicked
        ultimateTexasHoldem.gameEnded = true;
        ultimateTexasHoldem.showBacks = false; // Show all cards face up
        // Ensure all community cards are shown
        for (int i = 0; i < 5; i++) {
          ultimateTexasHoldem.communityShowBacks[i] = false;
        }
      }
    });
  }

  void _resetGame() {
    setState(() {
      // Reset all state variables
      ultimateTexasHoldem.showBacks = true;
      ultimateTexasHoldem.communityShowBacks = [true, true, true, true, true];
      ultimateTexasHoldem.player1Hand = '';
      ultimateTexasHoldem.dealerHand = '';
      ultimateTexasHoldem.result = '';
      ultimateTexasHoldem.checkRound = 0;
      ultimateTexasHoldem.gameEnded = false;
      ultimateTexasHoldem.currentBet = 0;
      ultimateTexasHoldem.cardsDealt = false;
      ultimateTexasHoldem.playBet = 0;

      // Clear out the ante, blind, and trips bet values and circles
      ultimateTexasHoldem.totalAnteBlind = 0;
      ultimateTexasHoldem.tripsBet = 0;
      anteCircle = const BetCircle(label: 'ANTE');
      blindCircle = const BetCircle(label: 'BLIND');
      tripsCircle = const BetCircle(label: 'TRIPS');
      playCircle = const BetCircle(label: 'PLAY');
      // Clear cards
      ultimateTexasHoldem.community.clear();
      ultimateTexasHoldem.player1Cards.clear();
      ultimateTexasHoldem.dealer.clear();
      ultimateTexasHoldem.fourX = true;
      ultimateTexasHoldem.threeX = true;
      ultimateTexasHoldem.twoX = false;
      ultimateTexasHoldem.oneX = false;
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
                        'Total Bet: \$${(ultimateTexasHoldem.totalAnteBlind + ultimateTexasHoldem.tripsBet + ultimateTexasHoldem.playBet).toStringAsFixed(0)}',
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
                        '\$${ultimateTexasHoldem.player1.bankroll.toStringAsFixed(2)}',
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
                if (ultimateTexasHoldem.cardsDealt)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dealer cards
                      Column(
                        children: [
                          Text(
                            ultimateTexasHoldem.dealerHand ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              CardPlaceholder(
                                  card: ultimateTexasHoldem.dealer[0], showBack: ultimateTexasHoldem.showBacks),
                              CardPlaceholder(
                                  card: ultimateTexasHoldem.dealer[1], showBack: ultimateTexasHoldem.showBacks),
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
                                    card: ultimateTexasHoldem.community[x],
                                    showBack: ultimateTexasHoldem.gameEnded
                                        ? false
                                        : ultimateTexasHoldem.communityShowBacks[x])),
                          ),
                        ],
                      ),
                      // Player cards
                      Column(
                        children: [
                          Text(
                            ultimateTexasHoldem.player1Hand ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              CardPlaceholder(card: ultimateTexasHoldem.player1Cards[0], showBack: false),
                              CardPlaceholder(card: ultimateTexasHoldem.player1Cards[1], showBack: false),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text('Player', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                // Game Result
                if (ultimateTexasHoldem.result.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      ultimateTexasHoldem.result,
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
                        // TRIPS circle on the far left
                        DragTarget<double>(
                          onWillAcceptWithDetails: (details) => !ultimateTexasHoldem.cardsDealt,
                          onAcceptWithDetails: (details) {
                            if (!ultimateTexasHoldem.cardsDealt) {
                              setState(() {
                                ultimateTexasHoldem.tripsBet += details.data;
                                ultimateTexasHoldem.player1.bankroll -= details.data;
                              });
                              tripsCircle =
                                  BetCircle(label: 'TRIPS', chipWidget: tripsCircle.buildChipWidget(details.data));
                            }
                          },
                          builder: (context, candidateData, rejectedData) {
                            return tripsCircle;
                          },
                        ),
                        // Centered ANTE and BLIND circles
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DragTarget<double>(
                                onWillAcceptWithDetails: (details) => true,
                                onAcceptWithDetails: (details) {
                                  setState(() {
                                    ultimateTexasHoldem.totalAnteBlind += details.data * 2;
                                    ultimateTexasHoldem.player1.bankroll -= details.data * 2;
                                  });
                                  anteCircle =
                                      BetCircle(label: 'ANTE', chipWidget: anteCircle.buildChipWidget(details.data));
                                  blindCircle =
                                      BetCircle(label: 'BLIND', chipWidget: blindCircle.buildChipWidget(details.data));
                                },
                                builder: (context, candidateData, rejectedData) {
                                  return anteCircle;
                                },
                              ),
                              const SizedBox(width: 20),
                              DragTarget<double>(
                                onWillAcceptWithDetails: (details) => true,
                                onAcceptWithDetails: (details) {
                                  setState(() {
                                    ultimateTexasHoldem.totalAnteBlind += details.data * 2;
                                    ultimateTexasHoldem.player1.bankroll -= details.data * 2;
                                  });
                                  anteCircle =
                                      BetCircle(label: 'ANTE', chipWidget: anteCircle.buildChipWidget(details.data));
                                  blindCircle =
                                      BetCircle(label: 'BLIND', chipWidget: blindCircle.buildChipWidget(details.data));
                                },
                                builder: (context, candidateData, rejectedData) {
                                  return blindCircle;
                                },
                              ),
                            ],
                          ),
                        ),
                        // Empty space on the right
                        const SizedBox(width: 48),
                      ],
                    ),
                  ],
                ),
                // Play bet circle below the bet spots (restored)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0, bottom: 0.0),
                  child: DragTarget<String>(
                    onWillAcceptWithDetails: (details) => true,
                    onAcceptWithDetails: (details) {
                      setState(() {
                        double value = double.tryParse(details.data) ?? 0.0;
                        playCircle = BetCircle(label: 'PLAY', chipWidget: playCircle.buildChipWidget(value));
                        ultimateTexasHoldem.playBet = value;
                      });
                      _handleBet();
                    },
                    builder: (context, candidateData, rejectedData) {
                      return playCircle;
                    },
                  ),
                ),
                // Payout tables row below the play button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.scale(
                      scale: 0.85,
                      alignment: Alignment.topLeft,
                      child: const PayoutColumn(
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
                    ),
                    const PayoutColumn(
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
              if (ultimateTexasHoldem.gameEnded)
                ElevatedButton(
                  onPressed: _resetGame,
                  child: const Text('Deal Again'),
                )
              else ...[
                if (ultimateTexasHoldem.cardsDealt) ...[
                  ElevatedButton(
                    onPressed: ultimateTexasHoldem.checkRound < 3 ? _handleCheck : null,
                    child: Text(ultimateTexasHoldem.checkRound < 2 ? 'Check' : 'Fold'),
                  ),
                  const SizedBox(width: 8),
                ],
                if (ultimateTexasHoldem.cardsDealt) ...[
                  if (ultimateTexasHoldem.fourX) ...[
                    Draggable(
                      data: (ultimateTexasHoldem.totalAnteBlind / 2 * 4).toString(),
                      feedback: Material(
                        color: Colors.transparent,
                        child: ChipWidget(value: ultimateTexasHoldem.totalAnteBlind / 2 * 4, label: '4x'),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: ChipWidget(value: ultimateTexasHoldem.totalAnteBlind / 2 * 4, label: '4x'),
                      ),
                      child: ChipWidget(
                        value: ultimateTexasHoldem.totalAnteBlind / 2 * 4,
                        label: '4x',
                      ),
                    )
                  ],
                  if (ultimateTexasHoldem.threeX) ...[
                    Draggable(
                      data: (ultimateTexasHoldem.totalAnteBlind / 2 * 3).toString(),
                      feedback: Material(
                        color: Colors.transparent,
                        child: ChipWidget(value: ultimateTexasHoldem.totalAnteBlind / 2 * 3, label: '3x'),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: ChipWidget(value: ultimateTexasHoldem.totalAnteBlind / 2 * 3, label: '3x'),
                      ),
                      child: ChipWidget(
                        value: ultimateTexasHoldem.totalAnteBlind / 2 * 3,
                        label: '3x',
                      ),
                    ),
                  ],
                  if (ultimateTexasHoldem.twoX) ...[
                    Draggable(
                      data: (ultimateTexasHoldem.totalAnteBlind / 2 * 2).toString(),
                      feedback: Material(
                        color: Colors.transparent,
                        child: ChipWidget(value: ultimateTexasHoldem.totalAnteBlind / 2 * 2, label: '2x'),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: ChipWidget(value: ultimateTexasHoldem.totalAnteBlind / 2 * 2, label: '2x'),
                      ),
                      child: ChipWidget(
                        value: ultimateTexasHoldem.totalAnteBlind / 2 * 2,
                        label: '2x',
                      ),
                    ),
                  ],
                  if (ultimateTexasHoldem.oneX) ...[
                    Draggable(
                      data: (ultimateTexasHoldem.totalAnteBlind / 2).toString(),
                      feedback: Material(
                        color: Colors.transparent,
                        child: ChipWidget(value: ultimateTexasHoldem.totalAnteBlind / 2, label: '1x'),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: ChipWidget(value: ultimateTexasHoldem.totalAnteBlind / 2, label: '1x'),
                      ),
                      child: ChipWidget(
                        value: ultimateTexasHoldem.totalAnteBlind / 2,
                        label: '1x',
                      ),
                    ),
                  ],
                ],
                if (!ultimateTexasHoldem.cardsDealt) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: ultimateTexasHoldem.totalAnteBlind > 0 ? _dealHands : null,
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
