/// Summary shown on payment / top-up success screens.
class PaymentReceipt {
  const PaymentReceipt({
    required this.headline,
    required this.amount,
    required this.completedAt,
    this.counterpartyLabel,
    this.walletLabel,
    this.subtitle,
    this.referenceId,
  });

  final String headline;
  final double amount;
  final DateTime completedAt;
  final String? counterpartyLabel;
  final String? walletLabel;
  final String? subtitle;
  final String? referenceId;
}
