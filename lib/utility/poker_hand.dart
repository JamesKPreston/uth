import 'package:playing_cards/playing_cards.dart'; // For PlayingCard, CardValue, Suit
import 'package:poker_solver/poker_solver.dart'; // For Card (from poker_solver)

class PokerHand {
  Card _convertToPokerCard(PlayingCard card) {
    const valueMap = {
      CardValue.two: '2',
      CardValue.three: '3',
      CardValue.four: '4',
      CardValue.five: '5',
      CardValue.six: '6',
      CardValue.seven: '7',
      CardValue.eight: '8',
      CardValue.nine: '9',
      CardValue.ten: 'T',
      CardValue.jack: 'J',
      CardValue.queen: 'Q',
      CardValue.king: 'K',
      CardValue.ace: 'A',
    };
    const suitMap = {
      Suit.clubs: 'c',
      Suit.diamonds: 'd',
      Suit.hearts: 'h',
      Suit.spades: 's',
    };
    final code = valueMap[card.value]! + suitMap[card.suit]!;
    return Card(code);
  }

  Hand evaluate(List<PlayingCard> cards) {
    final pokerCards = cards.map(_convertToPokerCard).toList();
    return Hand.solveHand(pokerCards);
  }
}
