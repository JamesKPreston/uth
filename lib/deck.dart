import 'package:playing_cards/playing_cards.dart';
import 'package:poker_solver/game.dart';
import 'package:poker_solver/hand.dart';
import 'dart:math';

import 'package:ultimate_texas_holdem_poc/interfaces/deck_interface.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/hand_interface.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/playing_card_interface.dart';
import 'package:ultimate_texas_holdem_poc/utility/poker_hands.dart';
import 'package:ultimate_texas_holdem_poc/wrapper/playing_card_wrapper.dart';
import 'package:ultimate_texas_holdem_poc/wrapper/hand_wrapper.dart';
import 'package:playing_cards/playing_cards.dart' as playing_cards;

class Deck implements IDeck {
  List<IPlayingCard> _cards = [];

  Deck() {
    _cards = standardFiftyTwoCardDeck().toIPlayingCard();
  }

  @override
  void shuffle() {
    _cards = standardFiftyTwoCardDeck().toIPlayingCard();
    _cards.shuffle(Random());
  }

  @override
  List<IPlayingCard> draw(int count) {
    List<IPlayingCard> cardsToDraw = [];
    if (count > _cards.length) {
      throw Exception('Not enough cards in deck to draw $count cards');
    }

    for (var i = 0; i < count; i++) {
      final card = _cards.removeAt(0);
      cardsToDraw.add(card);
    }

    return cardsToDraw;
  }

  @override
  int get remainingCards => _cards.length;

  @override
  IHand evaluate(List<IPlayingCard> cards) {
    return Hand.solveHand(cards.toPokerCards()).toIHand();
  }

  // This function takes a list of IHand and returns the winner(s) based on their PokerHandRank.
  List<IHand> determineWinnersByRank(List<Hand> hands) {
    List<IHand> handsConverted = hands.toIHandList();
    if (hands.isEmpty) return [];

    // Find the highest rank among the hands
    PokerHandRank highestRank = handsConverted.first.rank;
    for (final hand in handsConverted) {
      if (hand.rank.index < highestRank.index) {
        highestRank = hand.rank;
      }
    }

    // Collect all hands that have the highest rank
    List<IHand> winners = handsConverted.where((hand) => hand.rank == highestRank).toList();

    if (winners.length > 1) {
      winners = Hand.winners(hands).toIHandList();
    }
    // If there is more than one winner, you may want to implement tie-breaker logic here
    return winners;
  }

  @override
  List<IHand> winners(List<IHand> hands) {
    // TEMP DEBUG: Hardcoded hands for flush vs full house
    // final debugCommunity = [
    //   PlayingCardWrapper(playing_cards.PlayingCard(playing_cards.Suit.clubs, playing_cards.CardValue.three)), // 3♣
    //   PlayingCardWrapper(playing_cards.PlayingCard(playing_cards.Suit.clubs, playing_cards.CardValue.five)), // 5♣
    //   PlayingCardWrapper(playing_cards.PlayingCard(playing_cards.Suit.clubs, playing_cards.CardValue.queen)), // Q♣
    //   PlayingCardWrapper(playing_cards.PlayingCard(playing_cards.Suit.spades, playing_cards.CardValue.four)), // 4♠
    //   PlayingCardWrapper(playing_cards.PlayingCard(playing_cards.Suit.clubs, playing_cards.CardValue.four)), // 4♣
    // ];
    // final debugDealer = [
    //   PlayingCardWrapper(playing_cards.PlayingCard(playing_cards.Suit.diamonds, playing_cards.CardValue.two)), // 2♦
    //   PlayingCardWrapper(playing_cards.PlayingCard(playing_cards.Suit.clubs, playing_cards.CardValue.six)), // 6♣
    // ];
    // final debugPlayer = [
    //   PlayingCardWrapper(playing_cards.PlayingCard(playing_cards.Suit.diamonds, playing_cards.CardValue.queen)), // Q♦
    //   PlayingCardWrapper(playing_cards.PlayingCard(playing_cards.Suit.hearts, playing_cards.CardValue.queen)), // Q♥
    // ];
    // final dealerHand = evaluate([...debugCommunity, ...debugDealer]);
    // final playerHand = evaluate([...debugCommunity, ...debugPlayer]);
    // List<IHand> hands = [dealerHand, playerHand];

    // var hand1 = Hand.solveHand(['3c', '5c', 'Qc', '4s', '4c', '2d', '6c']);
    // var hand2 = Hand.solveHand(['3c', '5c', 'Qc', '4s', '4c', 'Qh', 'Qd']);

    final pokerCards = hands.map((h) => h.pokerCards).toList();
    final solvedHands = pokerCards.map((cards) => Hand.solveHand(cards)).toList();

    var winners = determineWinnersByRank(solvedHands);
    //print('winners: ${winners[0].rank} ${winners[0].name} ${winners[0].description}');
    return winners;
  }
}
