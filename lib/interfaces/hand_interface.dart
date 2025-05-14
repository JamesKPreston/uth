import 'package:poker_solver/card.dart';
import 'package:ultimate_texas_holdem_poc/utility/poker_hands.dart';

abstract class IHand {
  String get name;
  String get description;
  List<Card> get pokerCards;
  PokerHandRank get rank;
}
