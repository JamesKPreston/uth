import 'package:ultimate_texas_holdem_poc/interfaces/hand_interface.dart';

abstract class IPlayingCard {
  Suit get suit;
  CardValue get value;
}

abstract class IDeck {
  List<IPlayingCard> draw(int count);
  void shuffle();
  int get remainingCards;
  IHand evaluate(List<IPlayingCard> cards);
  List<IHand> winners(List<IHand> hands);
}

enum Suit { clubs, diamonds, hearts, spades }

enum CardValue { two, three, four, five, six, seven, eight, nine, ten, jack, queen, king, ace }
