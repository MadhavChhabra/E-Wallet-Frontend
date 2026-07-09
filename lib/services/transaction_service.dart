import 'package:flutter_ewallet/models/transaction_item.dart';
import 'package:flutter_ewallet/models/user_model.dart';
import 'package:flutter_ewallet/services/http_service.dart';
import 'package:flutter_ewallet/utils/shared.dart';
import 'package:flutter_ewallet/utils/shared_user.dart';
import 'package:intl/intl.dart';

/// Fetches and caches user transactions to avoid duplicate API calls on Home.
class TransactionService {
  TransactionService._();

  static final TransactionService instance = TransactionService._();

  List<TransactionItem>? _cache;
  DateTime? _cachedAt;
  static const Duration _cacheTtl = Duration(seconds: 60);

  void invalidate() {
    _cache = null;
    _cachedAt = null;
  }

  Future<List<TransactionItem>> fetchForCurrentUser({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _cache != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < _cacheTtl) {
      return _cache!;
    }

    final UserModel? user = await SharedUser().getCurrentUser();
    if (user?.id == null) {
      _cache = const [];
      _cachedAt = DateTime.now();
      return _cache!;
    }

    final response =
        await HttpService.getWithAuth('/transactions/users/${user!.id}');
    if (response['message'] != 'Success') {
      _cache = const [];
      _cachedAt = DateTime.now();
      return _cache!;
    }

    final bankAccountIds = await SharedUser().retrieveBankAccountIds();
    final dataList = response['data']['content'] as List<dynamic>? ?? [];

    final items = <TransactionItem>[];
    for (final raw in dataList) {
      final item = _mapTransaction(raw, bankAccountIds);
      if (item != null) items.add(item);
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _cache = items;
    _cachedAt = DateTime.now();
    return items;
  }

  double totalOutgoingSpend(List<TransactionItem> items) {
    var total = 0.0;
    for (final item in items) {
      if (!item.isOutgoing) continue;
      final amount = double.tryParse(
        item.value.replaceAll(RegExp(r'[^\d.]'), ''),
      );
      if (amount != null) total += amount;
    }
    return total;
  }

  List<String> recentCounterparties(List<TransactionItem> items, {int limit = 8}) {
    final seen = <String>{};
    final names = <String>[];
    for (final item in items) {
      final name = item.counterpartyUsername;
      if (name == null || name.isEmpty || seen.contains(name)) continue;
      seen.add(name);
      names.add(name);
      if (names.length >= limit) break;
    }
    return names;
  }

  TransactionItem? _mapTransaction(
    dynamic raw,
    List<String> bankAccountIds,
  ) {
    final amount = raw['amount'] != null
        ? double.tryParse(raw['amount'].toString())
        : null;
    if (amount == null) return null;

    final createdAt = _parseCreatedAt(raw['createdAt']?.toString());
    final typeId = raw['type']?['id'];
    late String icon;
    late String sign;
    late String title;
    var isOutgoing = false;
    String? counterpartyUsername;

    // Backend type ids (DataInitializer): 1=Transfer, 2=Deposit, 3=Withdraw,
    // 4=Top Up, 5=Payment.
    switch (typeId) {
      case 1:
        final fromId = raw['fromBankAccount']?['id']?.toString();
        final outgoing =
            fromId != null && bankAccountIds.contains(fromId);
        icon = outgoing
            ? 'assets/ic_transaction_cat3.png'
            : 'assets/ic_transaction_cat1.png';
        sign = outgoing ? '-' : '+';
        title = 'Transfer';
        isOutgoing = outgoing;
        counterpartyUsername =
            raw['toBankAccount']?['user']?['username']?.toString();
        break;
      case 2:
        icon = 'assets/ic_transaction_cat1.png';
        sign = '+';
        title = 'Deposit';
        break;
      case 3:
        icon = 'assets/ic_transaction_cat3.png';
        sign = '-';
        title = 'Withdrawal';
        isOutgoing = true;
        break;
      case 4:
        icon = 'assets/ic_transaction_cat1.png';
        sign = '+';
        title = 'Top Up';
        break;
      case 5:
        icon = 'assets/ic_transaction_cat3.png';
        sign = '-';
        title = 'Payment';
        isOutgoing = true;
        break;
      default:
        icon = 'assets/ic_transaction_cat5.png';
        sign = '';
        title = 'Transaction';
    }

    return TransactionItem(
      iconUrl: icon,
      title: title,
      timeLabel: DateFormat("MMMM dd, yyyy 'at' hh:mm a").format(createdAt),
      value: '$sign ${formatCurrency(amount, symbol: '')}',
      createdAt: createdAt,
      counterpartyUsername: counterpartyUsername,
      isOutgoing: isOutgoing,
    );
  }

  DateTime _parseCreatedAt(String? createdAtString) {
    if (createdAtString == null || createdAtString.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    final parts = createdAtString.split(' ');
    if (parts.length < 2) return DateTime.fromMillisecondsSinceEpoch(0);

    final dateParts = parts[0].split('-');
    final timeParts = parts[1].split(':');
    if (dateParts.length < 3 || timeParts.length < 2) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DateTime(
      int.parse(dateParts[2]),
      int.parse(dateParts[1]),
      int.parse(dateParts[0]),
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
      int.parse(timeParts[2].split('.')[0]),
    );
  }
}
