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
    final currentUserId = user?.id?.toString();
    if (currentUserId == null) {
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

    final dataList = response['data']['content'] as List<dynamic>? ?? [];

    final items = <TransactionItem>[];
    for (final raw in dataList) {
      final item = _mapTransaction(raw, currentUserId);
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
      if (!item.isOutgoing) continue;
      final name = item.counterpartyUsername;
      if (name == null || name.isEmpty || seen.contains(name)) continue;
      seen.add(name);
      names.add(name);
      if (names.length >= limit) break;
    }
    return names;
  }

  /// Maps a recent counterparty username to their IBAN for quick re-send.
  String? counterpartyIbanForUsername(
    List<TransactionItem> items,
    String username,
  ) {
    for (final item in items) {
      if (item.isOutgoing &&
          item.counterpartyUsername == username &&
          item.counterpartyIban != null &&
          item.counterpartyIban!.isNotEmpty) {
        return item.counterpartyIban;
      }
    }
    return null;
  }

  TransactionItem? _mapTransaction(
    dynamic raw,
    String? currentUserId,
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
    String? counterpartyIban;

    // Backend type ids (DataInitializer): 1=Transfer, 2=Deposit, 3=Withdraw,
    // 4=Top Up, 5=Payment.
    switch (typeId) {
      case 1:
        final fromUserId = raw['fromBankAccount']?['user']?['id']?.toString();
        final outgoing =
            currentUserId != null && fromUserId == currentUserId;
        icon = outgoing
            ? 'assets/ic_transaction_cat3.png'
            : 'assets/ic_transaction_cat1.png';
        sign = outgoing ? '-' : '+';
        title = outgoing ? 'Money sent' : 'Money received';
        isOutgoing = outgoing;
        if (outgoing) {
          counterpartyUsername =
              raw['toBankAccount']?['user']?['username']?.toString();
          counterpartyIban = raw['toBankAccount']?['iban']?.toString();
        } else {
          counterpartyUsername =
              raw['fromBankAccount']?['user']?['username']?.toString();
          counterpartyIban = raw['fromBankAccount']?['iban']?.toString();
        }
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
      counterpartyIban: counterpartyIban,
      isOutgoing: isOutgoing,
    );
  }

  DateTime _parseCreatedAt(String? createdAtString) {
    if (createdAtString == null || createdAtString.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    // Backend format: dd-MM-yyyy HH:mm:ss
    try {
      return DateFormat('dd-MM-yyyy HH:mm:ss').parse(createdAtString);
    } catch (_) {
      // Legacy / alternate formats.
    }

    try {
      return DateFormat('dd.MM.yyyy HH:mm:ss').parse(createdAtString);
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }
}
