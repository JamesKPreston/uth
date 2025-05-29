import 'package:playing_cards/playing_cards.dart' as playing_cards;
import 'package:ultimate_texas_holdem_poc/interfaces/playing_card_interface.dart';
import 'package:flutter/material.dart';
import 'package:ultimate_texas_holdem_poc/wrapper/playing_card_wrapper.dart';

class CardPlaceholder extends StatelessWidget {
  final IPlayingCard card;
  final bool showBack;

  const CardPlaceholder({
    Key? key,
    required this.card,
    required this.showBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70 * (89.0 / 64.0),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white24,
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(4),
      ),
      child: playing_cards.PlayingCardView(
        card: card.toPlayingCard(),
        showBack: showBack,
      ),
    );
  }
}
