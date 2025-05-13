import 'package:poker_solver/card.dart';

abstract class IHand {
  String get name;
  String get description;
  List<Card> get pokerCards;
}
