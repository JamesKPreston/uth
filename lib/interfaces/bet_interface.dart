import 'package:ultimate_texas_holdem_poc/interfaces/hand_interface.dart';

abstract class IBet {
  /// Returns true if the hand qualifies for this bet.
  bool doesQualify(IHand hand);

  /// Returns the payout amount for the given hand and bet amount.
  double payout(IHand hand, double betAmount);
}
