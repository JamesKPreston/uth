import 'package:playing_cards/playing_cards.dart';
import 'package:poker_solver/hand.dart';
import 'dart:math';

import 'package:ultimate_texas_holdem_poc/interfaces/deck_interface.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/hand_interface.dart';
import 'package:ultimate_texas_holdem_poc/wrapper/playing_card_wrapper.dart';
import 'package:ultimate_texas_holdem_poc/wrapper/hand_wrapper.dart';

class Deck implements IDeck {
  List<IPlayingCard> _cards = [];

  Deck() {
    _cards = standardFiftyTwoCardDeck().toIPlayingCard();
  }

  @override
  void shuffle() {
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

  @override
  List<IHand> winners(List<IHand> hands) {
    final pokerCards = hands.map((h) => h.pokerCards).toList();
    final solvedHands = pokerCards.map((cards) => Hand.solveHand(cards)).toList();
    return Hand.winners(solvedHands).toIHandList();
  }
}
