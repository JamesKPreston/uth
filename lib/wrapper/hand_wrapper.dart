import 'package:poker_solver/hand.dart';
import 'package:poker_solver/card.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/hand_interface.dart';

extension HandToIHand on Hand {
  IHand toIHand() {
    return _HandAdapter(this);
  }
}

extension HandListToIHandList on List<Hand> {
  List<IHand> toIHandList() {
    return map((hand) => hand.toIHand()).toList();
  }
}

class _HandAdapter implements IHand {
  final Hand _hand;

  _HandAdapter(this._hand);

  @override
  String get name => _hand.name;

  @override
  String get description => _hand.descr ?? '';

  @override
  List<Card> get pokerCards => _hand.cardPool;
}
