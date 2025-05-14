class Player {
  String name;
  double bankroll;

  Player({required this.name, required this.bankroll});

  void updateBankroll(double amount) {
    bankroll += amount;
  }
}
