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
  final TextEditingController anteController = TextEditingController(text: '15');
  double anteAmount = 15;
  double currentBet = 0;
  double totalAnteBlind = 0; // Track total ante + blind amount
  double trips = 0;
  BetCircle tripsCircle = const BetCircle(label: 'TRIPS');
  BetCircle anteCircle = const BetCircle(label: 'ANTE');
  BetCircle blindCircle = const BetCircle(label: 'BLIND');
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

  void _handleBet() {
    final betAmount = anteAmount * double.parse(selectedBetMultiplier?.replaceAll('x', '') ?? '1');
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
          var blind = Blind().payout(h1, totalAnteBlind / 2);
          var tripsBet = Trips().payout(h1, trips);
          var winnings = ante + blind + (currentBet * 2) + tripsBet;
          result = 'Player 1 wins $winnings with ${h1.description}';
          // Return ante, blind, and 2x bet amount on win
          player1.bankroll += totalAnteBlind + (currentBet * 2);
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
      communityShowBacks = [true, true, true, true, true]; // Reset community card states
      player1Hand = '';
      dealerHand = '';
      result = '';
      selectedBetMultiplier = '4x';
      availableMultipliers = ['3x', '4x'];
      checkRound = 0;
      gameEnded = false;
      currentBet = 0;
      trips = 5;

      // Clear and re deal cards
      community.clear();
      player1Cards.clear();
      dealer.clear();
      deck.shuffle();
      _dealHands();
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
                            const SizedBox(width: 150),
                            DragTarget<double>(
                              onWillAcceptWithDetails: (details) => true,
                              onAcceptWithDetails: (details) {
                                setState(() {
                                  totalAnteBlind += details.data * 2;
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
                    const BetCircle(label: 'PLAY'),
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
                        onPressed: checkRound < 3 ? _handleCheck : null,
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
                        onChanged: (value) {
                          setState(() {
                            selectedBetMultiplier = value;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _handleBet,
                        child: Text(
                            'Bet ${(totalAnteBlind / 2) * double.parse(selectedBetMultiplier?.replaceAll('x', '') ?? '1')}'),
                      ),
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
