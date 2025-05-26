import 'package:ultimate_texas_holdem_poc/interfaces/playing_card_interface.dart';

abstract class IDeck {
  List<IPlayingCard> draw(int count);
  void shuffle();
  int get remainingCards;
}
