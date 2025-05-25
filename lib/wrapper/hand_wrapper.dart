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
    print('[HandWrapper] Solver name: '
        '[33m$name[0m, Description: [36m${_hand.descr}[0m');
    switch (name.toLowerCase()) {
      case 'royal flush':
        print('[HandWrapper] Mapped to enum: PokerHandRank.royalFlush');
        return PokerHandRank.royalFlush;
      case 'straight flush':
        print('[HandWrapper] Mapped to enum: PokerHandRank.straightFlush');
        return PokerHandRank.straightFlush;
      case 'four of a kind':
        print('[HandWrapper] Mapped to enum: PokerHandRank.fourOfAKind');
        return PokerHandRank.fourOfAKind;
      case 'full house':
        print('[HandWrapper] Mapped to enum: PokerHandRank.fullHouse');
        return PokerHandRank.fullHouse;
      case 'flush':
        print('[HandWrapper] Mapped to enum: PokerHandRank.flush');
        return PokerHandRank.flush;
      case 'straight':
        print('[HandWrapper] Mapped to enum: PokerHandRank.straight');
        return PokerHandRank.straight;
      case 'three of a kind':
        print('[HandWrapper] Mapped to enum: PokerHandRank.threeOfAKind');
        return PokerHandRank.threeOfAKind;
      case 'two pair':
        print('[HandWrapper] Mapped to enum: PokerHandRank.twoPair');
        return PokerHandRank.twoPair;
      case 'pair':
        print('[HandWrapper] Mapped to enum: PokerHandRank.onePair');
        return PokerHandRank.onePair;
      case 'high card':
        print('[HandWrapper] Mapped to enum: PokerHandRank.highCard');
        return PokerHandRank.highCard;
      default:
        print('[HandWrapper] ERROR: Invalid hand rank: $name');
        throw Exception('Invalid hand rank: $name');
    }
  }
}
