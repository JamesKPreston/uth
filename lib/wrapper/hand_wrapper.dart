import 'package:poker_solver/hand.dart';
import 'package:poker_solver/card.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/hand_interface.dart';
import 'package:ultimate_texas_holdem_poc/utility/poker_hands.dart';

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

  @override
  PokerHandRank get rank {
    var name = _hand.name;
    switch (name.toLowerCase()) {
      case 'royal flush':
        return PokerHandRank.royalFlush;
      case 'straight flush':
        return PokerHandRank.straightFlush;
      case 'four of a kind':
        return PokerHandRank.fourOfAKind;
      case 'full house':
        return PokerHandRank.fullHouse;
      case 'flush':
        return PokerHandRank.flush;
      case 'straight':
        return PokerHandRank.straight;
      case 'three of a kind':
        return PokerHandRank.threeOfAKind;
      case 'two pair':
        return PokerHandRank.twoPair;
      case 'pair':
        return PokerHandRank.onePair;
      case 'high card':
        return PokerHandRank.highCard;
      default:
        throw Exception('Invalid hand rank: $name');
    }
  }
}
