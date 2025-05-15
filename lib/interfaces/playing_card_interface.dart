abstract class IPlayingCard {
  Suit get suit;
  CardValue get value;
}

enum Suit { clubs, diamonds, hearts, spades }

enum CardValue { two, three, four, five, six, seven, eight, nine, ten, jack, queen, king, ace }
