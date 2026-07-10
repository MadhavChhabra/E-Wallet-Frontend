class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.iconUrl,
    required this.title,
    required this.timeLabel,
    required this.value,
    required this.amount,
    required this.createdAt,
    this.counterpartyUsername,
    this.counterpartyIban,
    this.isOutgoing = false,
    this.description,
    this.referenceNumber,
    this.typeId,
  });

  final int id;
  final String iconUrl;
  final String title;
  final String timeLabel;
  final String value;
  final double amount;
  final DateTime createdAt;
  final String? counterpartyUsername;
  final String? counterpartyIban;
  final bool isOutgoing;
  final String? description;
  final String? referenceNumber;
  final int? typeId;
}

class TransactionPage {
  const TransactionPage({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.hasMore,
  });

  final List<TransactionItem> items;
  final int page;
  final int totalPages;
  final bool hasMore;
}
