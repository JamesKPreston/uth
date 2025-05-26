import 'package:poker_solver/hand.dart';
import 'package:ultimate_texas_holdem_poc/games/common.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/bet_interface.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/hand_interface.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/playing_card_interface.dart';
import 'package:ultimate_texas_holdem_poc/utility/poker_hands.dart';

class UltimateTexasHoldem {
  UltimateTexasHoldem();
  final ante = _Ante();
  final blind = _Blind();
  final trips = _Trips();

  IHand evaluate(List<IPlayingCard> cards) {
    return Common().evaluate(cards);
  }

  // This function takes a list of IHand and returns the winner(s) based on their PokerHandRank.
  List<IHand> determineWinnersByRank(List<Hand> hands) {
    return Common().determineWinnersByRank(hands);
  }

  List<IHand> winners(List<IHand> hands) {
    return Common().winners(hands);
  }
}

class _Ante implements IBet {
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

class _Blind implements IBet {
  @override
  bool doesQualify(IHand hand) {
    final qualifies = hand.rank.index <= PokerHandRank.straight.index;
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

class _Trips implements IBet {
  @override
  bool doesQualify(IHand hand) {
    final qualifies = hand.rank.index <= PokerHandRank.threeOfAKind.index;
    print('[TRIPS] Hand: ${hand.description} (${hand.rank}), Qualifies: $qualifies');
    return qualifies;
  }

  @override
  double payout(IHand hand, double betAmount) {
    final qualifies = doesQualify(hand);
    if (qualifies) {
      print('[TRIPS] Payout: Qualified with ${hand.description} (${hand.rank})');
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
      print('[TRIPS] Payout: Did NOT qualify with ${hand.description} (${hand.rank}), pays 0');
      return 0;
    }
  }
}
