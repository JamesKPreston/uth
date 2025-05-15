import 'package:playing_cards/playing_cards.dart' as playing_cards;
import 'package:poker_solver/card.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/playing_card_interface.dart';

class PlayingCardWrapper implements IPlayingCard {
  final playing_cards.PlayingCard _card;

  PlayingCardWrapper(this._card);

  @override
  Suit get suit {
    switch (_card.suit) {
      case playing_cards.Suit.clubs:
        return Suit.clubs;
      case playing_cards.Suit.diamonds:
        return Suit.diamonds;
      case playing_cards.Suit.hearts:
        return Suit.hearts;
      case playing_cards.Suit.spades:
        return Suit.spades;
      default:
        return Suit.spades; // Default case
    }
  }

  @override
  CardValue get value {
    switch (_card.value) {
      case playing_cards.CardValue.ace:
        return CardValue.ace;
      case playing_cards.CardValue.two:
        return CardValue.two;
      case playing_cards.CardValue.three:
        return CardValue.three;
      case playing_cards.CardValue.four:
        return CardValue.four;
      case playing_cards.CardValue.five:
        return CardValue.five;
      case playing_cards.CardValue.six:
        return CardValue.six;
      case playing_cards.CardValue.seven:
        return CardValue.seven;
      case playing_cards.CardValue.eight:
        return CardValue.eight;
      case playing_cards.CardValue.nine:
        return CardValue.nine;
      case playing_cards.CardValue.ten:
        return CardValue.ten;
      case playing_cards.CardValue.jack:
        return CardValue.jack;
      case playing_cards.CardValue.queen:
        return CardValue.queen;
      case playing_cards.CardValue.king:
        return CardValue.king;
      default:
        return CardValue.ace; // Default case
    }
  }

  playing_cards.PlayingCard toPlayingCard() {
    return playing_cards.PlayingCard(
        playing_cards.Suit.values[suit.index], playing_cards.CardValue.values[value.index]);
  }
}

extension PlayingCardConverter on playing_cards.PlayingCard {
  IPlayingCard toIPlayingCard() {
    return PlayingCardWrapper(this);
  }
}

extension PlayingCardListConverter on List<playing_cards.PlayingCard> {
  List<IPlayingCard> toIPlayingCard() {
    return map((card) => card.toIPlayingCard()).toList();
  }
}

extension PlayingCardWrapperExtension on IPlayingCard {
  playing_cards.PlayingCard toPlayingCard() {
    return playing_cards.PlayingCard(
        playing_cards.Suit.values[suit.index], playing_cards.CardValue.values[value.index]);
  }

  Card toPokerCard() {
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
    final code = valueMap[value]! + suitMap[suit]!;
    return Card(code);
  }
}

extension PlayingCardListWrapperExtension on List<IPlayingCard> {
  List<Card> toPokerCards() {
    return map((card) => card.toPokerCard()).toList();
  }
}
