class TransactionItem {
  const TransactionItem({
    required this.iconUrl,
    required this.title,
    required this.timeLabel,
    required this.value,
    required this.createdAt,
    this.counterpartyUsername,
    this.isOutgoing = false,
  });

  final String iconUrl;
  final String title;
  final String timeLabel;
  final String value;
  final DateTime createdAt;
  final String? counterpartyUsername;
  final bool isOutgoing;
}
