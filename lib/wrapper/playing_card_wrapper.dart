import 'package:playing_cards/playing_cards.dart' as playing_cards;
import 'package:poker_solver/card.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/deck_interface.dart' as deck_interface;

class PlayingCardWrapper implements deck_interface.IPlayingCard {
  final playing_cards.PlayingCard _card;

  PlayingCardWrapper(this._card);

  @override
  deck_interface.Suit get suit {
    switch (_card.suit) {
      case playing_cards.Suit.clubs:
        return deck_interface.Suit.clubs;
      case playing_cards.Suit.diamonds:
        return deck_interface.Suit.diamonds;
      case playing_cards.Suit.hearts:
        return deck_interface.Suit.hearts;
      case playing_cards.Suit.spades:
        return deck_interface.Suit.spades;
      default:
        return deck_interface.Suit.spades; // Default case
    }
  }

  @override
  deck_interface.CardValue get value {
    switch (_card.value) {
      case playing_cards.CardValue.ace:
        return deck_interface.CardValue.ace;
      case playing_cards.CardValue.two:
        return deck_interface.CardValue.two;
      case playing_cards.CardValue.three:
        return deck_interface.CardValue.three;
      case playing_cards.CardValue.four:
        return deck_interface.CardValue.four;
      case playing_cards.CardValue.five:
        return deck_interface.CardValue.five;
      case playing_cards.CardValue.six:
        return deck_interface.CardValue.six;
      case playing_cards.CardValue.seven:
        return deck_interface.CardValue.seven;
      case playing_cards.CardValue.eight:
        return deck_interface.CardValue.eight;
      case playing_cards.CardValue.nine:
        return deck_interface.CardValue.nine;
      case playing_cards.CardValue.ten:
        return deck_interface.CardValue.ten;
      case playing_cards.CardValue.jack:
        return deck_interface.CardValue.jack;
      case playing_cards.CardValue.queen:
        return deck_interface.CardValue.queen;
      case playing_cards.CardValue.king:
        return deck_interface.CardValue.king;
      default:
        return deck_interface.CardValue.ace; // Default case
    }
  }

  playing_cards.PlayingCard toPlayingCard() {
    return playing_cards.PlayingCard(
        playing_cards.Suit.values[suit.index], playing_cards.CardValue.values[value.index]);
  }
}

extension PlayingCardConverter on playing_cards.PlayingCard {
  deck_interface.IPlayingCard toIPlayingCard() {
    return PlayingCardWrapper(this);
  }
}

extension PlayingCardListConverter on List<playing_cards.PlayingCard> {
  List<deck_interface.IPlayingCard> toIPlayingCard() {
    return map((card) => card.toIPlayingCard()).toList();
  }
}

extension PlayingCardWrapperExtension on deck_interface.IPlayingCard {
  playing_cards.PlayingCard toPlayingCard() {
    return playing_cards.PlayingCard(
        playing_cards.Suit.values[suit.index], playing_cards.CardValue.values[value.index]);
  }

  Card toPokerCard() {
    const valueMap = {
      deck_interface.CardValue.two: '2',
      deck_interface.CardValue.three: '3',
      deck_interface.CardValue.four: '4',
      deck_interface.CardValue.five: '5',
      deck_interface.CardValue.six: '6',
      deck_interface.CardValue.seven: '7',
      deck_interface.CardValue.eight: '8',
      deck_interface.CardValue.nine: '9',
      deck_interface.CardValue.ten: 'T',
      deck_interface.CardValue.jack: 'J',
      deck_interface.CardValue.queen: 'Q',
      deck_interface.CardValue.king: 'K',
      deck_interface.CardValue.ace: 'A',
    };
    const suitMap = {
      deck_interface.Suit.clubs: 'c',
      deck_interface.Suit.diamonds: 'd',
      deck_interface.Suit.hearts: 'h',
      deck_interface.Suit.spades: 's',
    };
    final code = valueMap[value]! + suitMap[suit]!;
    return Card(code);
  }
}

extension PlayingCardListWrapperExtension on List<deck_interface.IPlayingCard> {
  List<Card> toPokerCards() {
    return map((card) => card.toPokerCard()).toList();
  }
}
