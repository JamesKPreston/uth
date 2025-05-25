import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart' as playing_cards;
import 'package:ultimate_texas_holdem_poc/bets/ante.dart';
import 'package:ultimate_texas_holdem_poc/bets/blind.dart';
import 'package:ultimate_texas_holdem_poc/bets/trips.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/deck_interface.dart' as uth_deck;
import 'package:ultimate_texas_holdem_poc/interfaces/playing_card_interface.dart';
import 'package:ultimate_texas_holdem_poc/wrapper/playing_card_wrapper.dart';
import 'package:ultimate_texas_holdem_poc/player.dart';

class UltimateTexasHoldem extends StatefulWidget {
  final uth_deck.IDeck deck;
  const UltimateTexasHoldem({required this.deck, super.key});

  @override
  UltimateTexasHoldemState createState() => UltimateTexasHoldemState();
}

class UltimateTexasHoldemState extends State<UltimateTexasHoldem> {
  late final uth_deck.IDeck deck;
  late Player player1;
  List<IPlayingCard> player1Cards = [];
  List<IPlayingCard> dealer = [];
  List<IPlayingCard> community = [];
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
  double trips = 5;

  @override
  void initState() {
    super.initState();
    deck = widget.deck;
    player1 = Player(name: 'Player 1', bankroll: 1000);
    selectedBetMultiplier = availableMultipliers.first; // Set initial multiplier
    _dealHands();
  }

  void _dealHands() {
    // Subtract ante and blind before dealing
    if (player1.bankroll >= (anteAmount * 2)) {
      setState(() {
        player1.bankroll -= (anteAmount * 2) + trips; // Subtract both ante and blind
        totalAnteBlind = anteAmount * 2;
        currentBet = 0;
      });
    } else {
      // Handle insufficient funds
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient funds for ante and blind'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

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
    // Hardcoded player hand: Flush (e.g., all hearts)
    tempPlayer
        .add(PlayingCardWrapper(playing_cards.PlayingCard(playing_cards.Suit.hearts, playing_cards.CardValue.ace)));
    tempPlayer
        .add(PlayingCardWrapper(playing_cards.PlayingCard(playing_cards.Suit.diamonds, playing_cards.CardValue.ace)));
    tempPlayer
        .add(PlayingCardWrapper(playing_cards.PlayingCard(playing_cards.Suit.spades, playing_cards.CardValue.ace)));
    tempPlayer
        .add(PlayingCardWrapper(playing_cards.PlayingCard(playing_cards.Suit.hearts, playing_cards.CardValue.jack)));
    tempPlayer
        .add(PlayingCardWrapper(playing_cards.PlayingCard(playing_cards.Suit.hearts, playing_cards.CardValue.nine)));

    tempDealer
        .add(PlayingCardWrapper(playing_cards.PlayingCard(playing_cards.Suit.spades, playing_cards.CardValue.eight)));
    tempDealer
        .add(PlayingCardWrapper(playing_cards.PlayingCard(playing_cards.Suit.diamonds, playing_cards.CardValue.eight)));
    tempDealer
        .add(PlayingCardWrapper(playing_cards.PlayingCard(playing_cards.Suit.clubs, playing_cards.CardValue.four)));
    tempDealer
        .add(PlayingCardWrapper(playing_cards.PlayingCard(playing_cards.Suit.hearts, playing_cards.CardValue.jack)));
    tempDealer
        .add(PlayingCardWrapper(playing_cards.PlayingCard(playing_cards.Suit.clubs, playing_cards.CardValue.two)));

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
  void dispose() {
    anteController.dispose();
    super.dispose();
  }

  void _updateAnteAmount(String value) {
    if (value.isEmpty) {
      setState(() {
        anteAmount = 0;
      });
      return;
    }
    final newAmount = double.tryParse(value);
    if (newAmount != null && newAmount >= 0) {
      setState(() {
        anteAmount = newAmount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Texas Hold\'em POC'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Top section - Player info and controls
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bankroll info
                Text(
                  '${player1.name}\'s Bankroll: \$${player1.bankroll.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                // Ante controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ante/Blind: \$${anteAmount.toStringAsFixed(2)} each',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 80,
                          // INSERT_YOUR_CODE
                          child: DragTarget<String>(
                            onWillAcceptWithDetails: (details) => true,
                            onAcceptWithDetails: (details) {
                              double newAmount = 0;
                              switch (details.data) {
                                case 'red_chip':
                                  newAmount = 5;
                                  break;
                                case 'green_chip':
                                  newAmount = 25;
                                  break;
                              }
                              newAmount = anteAmount + newAmount;
                              anteController.text = newAmount.toString();
                              _updateAnteAmount(newAmount.toString());
                            },
                            builder: (context, candidateData, rejectedData) {
                              return TextField(
                                controller: anteController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Ante/Blind',
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                                onChanged: _updateAnteAmount,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Draggable<String>(
                      data: 'red_chip',
                      feedback: Material(
                        color: Colors.transparent,
                        child: Image.asset('assets/red_chip.png', width: 50),
                      ),
                      childWhenDragging: Container(),
                      child: Image.asset('assets/red_chip.png', width: 50),
                    ),
                    // Image.asset('assets/red_chip.png', width: 50, height: 50),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Dealer cards
            Column(
              children: [
                Text(
                  'Dealer: $dealerHand',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: dealer
                      .map((c) => SizedBox(
                            width: 70,
                            height: 70 * (89.0 / 64.0),
                            child: playing_cards.PlayingCardView(card: c.toPlayingCard(), showBack: showBacks),
                          ))
                      .toList(),
                ),
              ],
            ),

            // Community cards
            Column(
              children: [
                const Text('Community Cards:', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: community.asMap().entries.map((entry) {
                    final index = entry.key;
                    final card = entry.value;
                    if (gameEnded) {
                      return SizedBox(
                        width: 70,
                        height: 70 * (89.0 / 64.0),
                        child: playing_cards.PlayingCardView(
                          card: card.toPlayingCard(),
                          showBack: false,
                        ),
                      );
                    } else {
                      return SizedBox(
                        width: 70,
                        height: 70 * (89.0 / 64.0),
                        child: playing_cards.PlayingCardView(
                          card: card.toPlayingCard(),
                          showBack: index < 3 ? checkRound < 1 : checkRound < 2,
                        ),
                      );
                    }
                  }).toList(),
                ),
              ],
            ),

            // Player cards
            Column(
              children: [
                Text(
                  'Player 1: $player1Hand',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: player1Cards
                      .map((c) => SizedBox(
                            width: 70,
                            height: 70 * (89.0 / 64.0),
                            child: playing_cards.PlayingCardView(card: c.toPlayingCard(), showBack: false),
                          ))
                      .toList(),
                ),
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
                    child: Text('Bet ${anteAmount * double.parse(selectedBetMultiplier?.replaceAll('x', '') ?? '1')}'),
                  ),
                ],
              ],
            ),

            // Result
            if (result.isNotEmpty)
              Text(
                result,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
