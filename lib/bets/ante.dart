import 'package:ultimate_texas_holdem_poc/interfaces/bet_interface.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/hand_interface.dart';
import 'package:ultimate_texas_holdem_poc/utility/poker_hands.dart';

class Ante implements IBet {
  @override
  bool doesQualify(IHand hand) {
    final qualifies = hand.rank.index >= PokerHandRank.onePair.index;
    print('[ANTE] Dealer hand: ${hand.description} (${hand.rank}), Qualifies: $qualifies');
    return qualifies;
  }

  @override
  double payout(IHand hand, double betAmount) {
    final qualifies = doesQualify(hand);
    if (qualifies) {
      print('[ANTE] Payout: Dealer qualifies with ${hand.description} (${hand.rank}), pays 1:1');
      // Player wins, dealer qualifies: pays 1:1
      return betAmount + (betAmount * 1 / 1);
    } else {
      print(
          '[ANTE] Payout: Dealer does NOT qualify with ${hand.description} (${hand.rank}), push (return original bet)');
      // Player wins, dealer does not qualify: push (return original bet)
      return betAmount;
    }
  }
}
