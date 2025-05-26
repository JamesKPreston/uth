import 'package:poker_solver/hand.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/hand_interface.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/playing_card_interface.dart';
import 'package:ultimate_texas_holdem_poc/utility/poker_hands.dart';
import 'package:ultimate_texas_holdem_poc/wrapper/hand_wrapper.dart';
import 'package:ultimate_texas_holdem_poc/wrapper/playing_card_wrapper.dart';

class Common {
  Common();

  IHand evaluate(List<IPlayingCard> cards) {
    return Hand.solveHand(cards.toPokerCards()).toIHand();
  }

  // This function takes a list of IHand and returns the winner(s) based on their PokerHandRank.
  List<IHand> determineWinnersByRank(List<Hand> hands) {
    List<IHand> handsConverted = hands.toIHandList();
    if (hands.isEmpty) return [];

    // Find the highest rank among the hands
    PokerHandRank highestRank = handsConverted.first.rank;
    for (final hand in handsConverted) {
      if (hand.rank.index < highestRank.index) {
        highestRank = hand.rank;
      }
    }

    // Collect all hands that have the highest rank
    List<IHand> winners = handsConverted.where((hand) => hand.rank == highestRank).toList();

    if (winners.length > 1) {
      winners = Hand.winners(hands).toIHandList();
    }
    // If there is more than one winner, you may want to implement tie-breaker logic here
    return winners;
  }

  List<IHand> winners(List<IHand> hands) {
    final pokerCards = hands.map((h) => h.pokerCards).toList();
    final solvedHands = pokerCards.map((cards) => Hand.solveHand(cards)).toList();

    var winners = determineWinnersByRank(solvedHands);
    return winners;
  }
}
