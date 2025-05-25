import 'package:ultimate_texas_holdem_poc/interfaces/bet_interface.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/hand_interface.dart';
import 'package:ultimate_texas_holdem_poc/utility/poker_hands.dart';

class Trips implements IBet {
  @override
  bool doesQualify(IHand hand) {
    return hand.rank.index >= PokerHandRank.threeOfAKind.index;
  }

  @override
  double payout(IHand hand, double betAmount) {
    if (doesQualify(hand)) {
      switch (hand.rank) {
        case PokerHandRank.threeOfAKind:
          return betAmount + (betAmount * 3 / 1);
        case PokerHandRank.straight:
          return betAmount + (betAmount * 4 / 1);
        case PokerHandRank.flush:
          return betAmount + (betAmount * 7 / 1);
        case PokerHandRank.fullHouse:
          return betAmount + (betAmount * 8 / 1);
        case PokerHandRank.fourOfAKind:
          return betAmount + (betAmount * 30 / 1);
        case PokerHandRank.straightFlush:
          return betAmount + (betAmount * 40 / 1);
        case PokerHandRank.royalFlush:
          return betAmount + (betAmount * 50 / 1);
        default:
          return betAmount;
      }
    } else {
      return 0;
    }
  }
}
