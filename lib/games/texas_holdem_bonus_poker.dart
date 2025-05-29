import 'package:poker_solver/hand.dart';
import 'package:ultimate_texas_holdem_poc/utility/common.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/bet_interface.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/hand_interface.dart';
import 'package:ultimate_texas_holdem_poc/interfaces/playing_card_interface.dart';
import 'package:ultimate_texas_holdem_poc/utility/player.dart';
import 'package:ultimate_texas_holdem_poc/utility/poker_hands.dart';

class TexasHoldemBonus {
  TexasHoldemBonus();
  final ante = _Ante();
  final bonus = _Bonus();
  late Player player1;
  List<IPlayingCard> player1Cards = [];
  List<IPlayingCard> dealer = [];
  List<IPlayingCard> community = [];
  List<bool> communityShowBacks = [true, true, true, true, true]; // Track individual showBack states
  bool showBacks = true;
  String? player1Hand = '';
  String? dealerHand = '';
  String result = '';
  bool twoX = false;
  bool oneX = false;
  int checkRound = 0;
  bool gameEnded = false;
  bool cardsDealt = false;
  double currentBet = 0;
  double totalAnte = 0; // Track total ante + blind amount
  double totalFlop = 0;
  double totalTurn = 0;
  double totalRiver = 0;
  double playBet = 0;

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
    final qualifies = hand.rank.index <= PokerHandRank.straight.index;
    print('[ANTE] Player hand: ${hand.description} (${hand.rank}), Qualifies: $qualifies');
    return qualifies;
  }

  @override
  double payout(IHand hand, double betAmount) {
    final qualifies = doesQualify(hand);
    if (qualifies) {
      print('[ANTE] Payout: Player qualifies with ${hand.description} (${hand.rank}), pays 1:1');
      // Player wins, dealer qualifies: pays 1:1
      return betAmount + (betAmount * 1 / 1);
    } else {
      print(
          '[ANTE] Payout: Player does NOT qualify with ${hand.description} (${hand.rank}), push (return original bet)');
      // Player wins, dealer does not qualify: push (return original bet)
      return betAmount;
    }
  }
}

class _Bonus implements IBet {
  @override
  bool doesQualify(IHand hand) {
    final qualifies = hand.rank.index <= PokerHandRank.straight.index;
    print('[BONUS] Hand: ${hand.description} (${hand.rank}), Qualifies: $qualifies');
    return qualifies;
  }

  @override
  double payout(IHand hand, double betAmount) {
    final qualifies = doesQualify(hand);
    if (qualifies) {
      print('[BONUS] Payout: Qualified with ${hand.description} (${hand.rank})');
    }
    return 0;
  }
}
