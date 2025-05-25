import 'package:ultimate_texas_holdem_poc/interfaces/bet_interface.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/hand_interface.dart';
import 'package:ultimate_texas_holdem_poc/utility/poker_hands.dart';

class Blind implements IBet {
  @override
  bool doesQualify(IHand hand) {
    final qualifies = hand.rank.index >= PokerHandRank.straight.index;
    print('[BLIND] Hand: ${hand.description} (${hand.rank}), Qualifies: $qualifies');
    return qualifies;
  }

  @override
  double payout(IHand hand, double betAmount) {
    final qualifies = doesQualify(hand);
    if (qualifies) {
      print('[BLIND] Payout: Qualified with ${hand.description} (${hand.rank})');
      switch (hand.rank) {
        case PokerHandRank.straight:
          return betAmount + (betAmount * 1 / 1);
        case PokerHandRank.flush:
          return betAmount + (betAmount * 3 / 2);
        case PokerHandRank.fullHouse:
          return betAmount + (betAmount * 3 / 1);
        case PokerHandRank.fourOfAKind:
          return betAmount + (betAmount * 10 / 1);
        case PokerHandRank.straightFlush:
          return betAmount + (betAmount * 50 / 1);
        case PokerHandRank.royalFlush:
          return betAmount + (betAmount * 500 / 1);
        default:
          return betAmount;
      }
    } else {
      print('[BLIND] Payout: Did NOT qualify with ${hand.description} (${hand.rank}), push (return original bet)');
      return betAmount;
    }
  }
}
