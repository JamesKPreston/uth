import 'package:flutter/material.dart';
import 'package:ultimate_texas_holdem_poc/bets/ante.dart';
import 'package:ultimate_texas_holdem_poc/bets/blind.dart';
import 'package:ultimate_texas_holdem_poc/bets/trips.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/deck_interface.dart' as uth_deck;
import 'package:ultimate_texas_holdem_poc/interfaces/playing_card_interface.dart';
import 'package:ultimate_texas_holdem_poc/widgets/card_place_holder_widget.dart';
import 'package:ultimate_texas_holdem_poc/widgets/bet_circle_widget.dart';
import 'package:ultimate_texas_holdem_poc/widgets/payout_column_widget.dart';
import 'package:ultimate_texas_holdem_poc/wrapper/playing_card_wrapper.dart';
import 'package:ultimate_texas_holdem_poc/player.dart';
import 'package:ultimate_texas_holdem_poc/widgets/chip_widget.dart';

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
  List<bool> communityShowBacks = [true, true, true, true, true]; // Track individual showBack states
  List<PlayingCardWrapper> tempPlayer = [];
  List<PlayingCardWrapper> tempDealer = [];
  bool showBacks = true;
  String? player1Hand = '';
  String? dealerHand = '';
  String result = '';
  String? selectedBetMultiplier;
  List<String> availableMultipliers = ['4x', '3x'];
  int checkRound = 0;
  bool gameEnded = false;
  bool cardsDealt = false;
  final TextEditingController anteController = TextEditingController(text: '15');
  double anteAmount = 15;
  double currentBet = 0;
  double totalAnteBlind = 0; // Track total ante + blind amount
  double trips = 0;
  BetCircle tripsCircle = const BetCircle(label: 'TRIPS');
  BetCircle anteCircle = const BetCircle(label: 'ANTE');
  BetCircle blindCircle = const BetCircle(label: 'BLIND');
  BetCircle playCircle = const BetCircle(label: 'PLAY');
  @override
  void initState() {
    super.initState();
    deck = widget.deck;
    player1 = Player(name: 'Player 1', bankroll: 1000);
    selectedBetMultiplier = '4x';
  }

  void _dealHands() {
    setState(() {
      deck.shuffle();
      player1Cards = deck.draw(2);
      dealer = deck.draw(2);
      community = deck.draw(5);
      cardsDealt = true;
      showBacks = true;
      communityShowBacks = [true, true, true, true, true];
    });
  }

  void _handleBet() {
    final betAmount = (totalAnteBlind / 2) * double.parse(selectedBetMultiplier?.replaceAll('x', '') ?? '1');

    if (player1.bankroll >= betAmount) {
      setState(() {
        player1.bankroll -= betAmount;
        currentBet = betAmount;
        gameEnded = true;
        showBacks = false;
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
    var h1 = deck.evaluate([...community, ...player1Cards]);
    var h2 = deck.evaluate([...community, ...dealer]);
    final winners = deck.winners([h1, h2]);

    setState(() {
      showBacks = false;
      player1Hand = h1.description;
      dealerHand = h2.description;

      if (winners.length == 2) {
        result = 'Tie: ${h1.name}';
        // Return ante, blind, and bet amount on tie
        player1.bankroll += totalAnteBlind + currentBet - 5;
      } else {
        final winnerCards = winners[0].pokerCards;
        final player1Cards = h1.pokerCards;

        final isPlayer1Winner = winnerCards
            .every((card) => player1Cards.any((p1Card) => p1Card.value == card.value && p1Card.suit == card.suit));

        if (isPlayer1Winner) {
          // h1 = deck.evaluate(tempPlayer);
          // h2 = deck.evaluate(tempDealer);
          var ante = Ante().payout(h2, totalAnteBlind / 2);
          print('Ante payout: $ante');
          var blind = Blind().payout(h1, totalAnteBlind / 2);
          print('Blind payout: $blind');
          var tripsBet = Trips().payout(h1, trips);
          print('Trips payout: $tripsBet');
          print('Current bet: $currentBet');
          var winnings = ante + blind + (currentBet * 2) + tripsBet;
          print('Total winnings: $winnings');
          result = 'Player 1 wins $winnings with ${h1.description}';
          // Return ante, blind, and 2x bet amount on win
          player1.bankroll += winnings;
        } else {
          result = 'Dealer wins with ${h2.description}';
          // No return on loss
        }
      }
    });
  }

  void _handleCheck() {
    setState(() {
      checkRound++;
      if (checkRound == 1) {
        // Show first 3 community cards
        for (int i = 0; i < 3; i++) {
          communityShowBacks[i] = false;
        }
        availableMultipliers = ['2x'];
        selectedBetMultiplier = '2x';
      } else if (checkRound == 2) {
        // Show remaining 2 community cards
        for (int i = 3; i < 5; i++) {
          communityShowBacks[i] = false;
        }
        availableMultipliers = ['1x'];
        selectedBetMultiplier = '1x';
      } else if (checkRound == 3) {
        // Fold was clicked
        gameEnded = true;
        showBacks = false; // Show all cards face up
        // Ensure all community cards are shown
        for (int i = 0; i < 5; i++) {
          communityShowBacks[i] = false;
        }
      }
    });
  }

  void _resetGame() {
    setState(() {
      // Reset all state variables
      showBacks = true;
      communityShowBacks = [true, true, true, true, true];
      player1Hand = '';
      dealerHand = '';
      result = '';
      selectedBetMultiplier = '4x';
      availableMultipliers = ['3x', '4x'];
      checkRound = 0;
      gameEnded = false;
      currentBet = 0;
      cardsDealt = false;

      // Clear out the ante, blind, and trips bet values and circles
      totalAnteBlind = 0;
      trips = 0;
      anteCircle = const BetCircle(label: 'ANTE');
      blindCircle = const BetCircle(label: 'BLIND');
      tripsCircle = const BetCircle(label: 'TRIPS');

      // Clear cards
      community.clear();
      player1Cards.clear();
      dealer.clear();
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Draggable(
                      data: (totalAnteBlind / 2 * 4).toString(),
                      feedback: Material(
                        color: Colors.transparent,
                        child: ChipWidget(value: totalAnteBlind / 2 * 4, label: '4x'),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: ChipWidget(value: totalAnteBlind / 2 * 4, label: '4x'),
                      ),
                      child: ChipWidget(
                        value: totalAnteBlind / 2 * 4,
                        label: '4x',
                      ),
                    ),
                    Draggable(
                      data: (totalAnteBlind / 2 * 3).toString(),
                      feedback: Material(
                        color: Colors.transparent,
                        child: ChipWidget(value: totalAnteBlind / 2 * 3, label: '3x'),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: ChipWidget(value: totalAnteBlind / 2 * 3, label: '3x'),
                      ),
                      child: ChipWidget(
                        value: totalAnteBlind / 2 * 3,
                        label: '3x',
                      ),
                    ),
                    Draggable(
                      data: (totalAnteBlind / 2 * 2).toString(),
                      feedback: Material(
                        color: Colors.transparent,
                        child: ChipWidget(value: totalAnteBlind / 2 * 2, label: '2x'),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: ChipWidget(value: totalAnteBlind / 2 * 2, label: '2x'),
                      ),
                      child: ChipWidget(
                        value: totalAnteBlind / 2 * 2,
                        label: '2x',
                      ),
                    ),
                    Draggable(
                      data: (totalAnteBlind / 2).toString(),
                      feedback: Material(
                        color: Colors.transparent,
                        child: ChipWidget(value: totalAnteBlind / 2, label: '1x'),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: ChipWidget(value: totalAnteBlind / 2, label: '1x'),
                      ),
                      child: ChipWidget(
                        value: totalAnteBlind / 2,
                        label: '1x',
                      ),
                    ),
                    const Draggable(
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
                    const Draggable(
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
                    const Draggable(
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
                    const Draggable(
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
                    const Draggable(
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
                // CARDS ROW
                if (cardsDealt)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dealer cards
                      Column(
                        children: [
                          Text(
                            dealerHand ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
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
                            children: List.generate(
                                5,
                                (x) => CardPlaceholder(
                                    card: community[x], showBack: gameEnded ? false : communityShowBacks[x])),
                          ),
                        ],
                      ),
                      // Player cards
                      Column(
                        children: [
                          Text(
                            player1Hand ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              CardPlaceholder(card: player1Cards[0], showBack: false),
                              CardPlaceholder(card: player1Cards[1], showBack: false),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text('Player', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),

                const SizedBox(height: 8),

                // Game Result
                if (result.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      result,
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
                        const PayoutColumn(
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
                        const SizedBox(width: 12),
                        DragTarget<double>(
                          onWillAcceptWithDetails: (details) => true,
                          onAcceptWithDetails: (details) {
                            setState(() {
                              trips += details.data;
                              player1.bankroll -= details.data;
                            });
                            tripsCircle =
                                BetCircle(label: 'TRIPS', chipWidget: tripsCircle.buildChipWidget(details.data));
                          },
                          builder: (context, candidateData, rejectedData) {
                            return tripsCircle;
                          },
                        ),
                        //const BetCircle(label: 'TRIPS'),
                        // Center betting circles
                        Row(
                          children: [
                            const SizedBox(width: 120),
                            DragTarget<double>(
                              onWillAcceptWithDetails: (details) => true,
                              onAcceptWithDetails: (details) {
                                setState(() {
                                  totalAnteBlind += details.data * 2;
                                  player1.bankroll -= details.data * 2;
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
                                  totalAnteBlind += details.data * 2;
                                  player1.bankroll -= details.data * 2;
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
                            const SizedBox(width: 150),
                          ],
                        ),
                        // Right side with BLIND payout
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
                    DragTarget<String>(
                      onWillAcceptWithDetails: (details) => true,
                      onAcceptWithDetails: (details) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Dropped value: ${details.data}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        // setState(() {
                        //   selectedBetMultiplier = details.data;
                        // });
                      },
                      builder: (context, candidateData, rejectedData) {
                        return playCircle;
                      },
                    ),
                    //const BetCircle(label: 'PLAY'),
                    const SizedBox(height: 8),
                  ],
                ),
                // Game controls
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
                        onPressed: cardsDealt && checkRound < 3 ? _handleCheck : null,
                        child: Text(checkRound < 2 ? 'Check' : 'Fold'),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: selectedBetMultiplier ?? availableMultipliers.first,
                        items: availableMultipliers
                            .map((multiplier) => DropdownMenuItem(
                                  value: multiplier,
                                  child: Text(multiplier),
                                ))
                            .toList(),
                        onChanged: cardsDealt
                            ? (value) {
                                setState(() {
                                  selectedBetMultiplier = value;
                                });
                              }
                            : null,
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: cardsDealt ? _handleBet : null,
                        child: Text(
                            'Bet ${(totalAnteBlind / 2) * double.parse(selectedBetMultiplier?.replaceAll('x', '') ?? '1')}'),
                      ),
                      if (!cardsDealt) ...[
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: totalAnteBlind > 0 ? _dealHands : null,
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

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Total Bet: \$${(totalAnteBlind + trips).toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // BALANCE
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '\$${player1.bankroll.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
