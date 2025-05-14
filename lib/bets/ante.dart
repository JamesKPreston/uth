import 'package:ultimate_texas_holdem_poc/interfaces/bet_interface.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/hand_interface.dart';
import 'package:ultimate_texas_holdem_poc/utility/poker_hands.dart';

class Ante implements IBet {
  @override
  bool doesQualify(IHand hand) {
    return hand.rank.index >= PokerHandRank.onePair.index;
  }

  @override
  double payout(IHand hand, double betAmount) {
    if (doesQualify(hand)) {
      // Player wins, dealer qualifies: pays 1:1
      return betAmount * 2;
    } else {
      // Player wins, dealer does not qualify: push (return original bet)
      return betAmount;
    }
  }
}
