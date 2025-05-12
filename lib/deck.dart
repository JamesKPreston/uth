import 'package:playing_cards/playing_cards.dart';
import 'dart:math';

class Deck {
  List<PlayingCard> _cards = [];

  Deck() {
    _cards = standardFiftyTwoCardDeck();
  }

  void shuffle() {
    _cards.shuffle(Random());
  }

  List<PlayingCard> draw(int count) {
    List<PlayingCard> cardsToDraw = [];
    if (count > _cards.length) {
      throw Exception('Not enough cards in deck to draw $count cards');
    }

    for (var i = 0; i < count; i++) {
      cardsToDraw.add(_cards.removeAt(0));
    }

    return cardsToDraw;
  }

  int get remainingCards => _cards.length;
}
