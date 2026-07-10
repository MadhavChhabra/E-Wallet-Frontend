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

    final page = await fetchPage(page: 0, size: 50, forceRefresh: forceRefresh);
    _cache = page.items;
    _cachedAt = DateTime.now();
    return _cache!;
  }

  Future<TransactionPage> fetchPage({
    int page = 0,
    int size = 20,
    bool forceRefresh = false,
  }) async {
    final UserModel? user = await SharedUser().getCurrentUser();
    final currentUserId = user?.id?.toString();
    if (currentUserId == null) {
      return const TransactionPage(
        items: [],
        page: 0,
        totalPages: 0,
        hasMore: false,
      );
    }

    final response = await HttpService.getWithAuth(
      '/transactions/users/${user!.id}?page=$page&size=$size&sort=createdAt,desc',
    );
    if (response['message'] != 'Success') {
      return TransactionPage(
        items: const [],
        page: page,
        totalPages: 0,
        hasMore: false,
      );
    }

    final data = response['data'];
    final dataList = data is Map
        ? (data['content'] as List<dynamic>? ?? [])
        : (data as List<dynamic>? ?? []);
    final totalPages = data is Map ? (data['totalPages'] as int? ?? 1) : 1;

    final items = <TransactionItem>[];
    for (final raw in dataList) {
      final item = _mapTransaction(raw, currentUserId);
      if (item != null) items.add(item);
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (page == 0 && !forceRefresh) {
      _cache = items;
      _cachedAt = DateTime.now();
    }

    return TransactionPage(
      items: items,
      page: page,
      totalPages: totalPages,
      hasMore: page + 1 < totalPages,
    );
  }

  Future<TransactionItem?> fetchById(int id) async {
    final response = await HttpService.getWithAuth('/transactions/$id');
    if (response['message'] != 'Success') return null;
    final raw = response['data'];
    if (raw is! Map<String, dynamic>) return null;

    final user = await SharedUser().getCurrentUser();
    return _mapTransaction(raw, user?.id?.toString());
  }

  double totalOutgoingSpend(List<TransactionItem> items) {
    var total = 0.0;
    for (final item in items) {
      if (!item.isOutgoing) continue;
      total += item.amount;
    }
    return total;
  }

  List<String> recentCounterparties(List<TransactionItem> items,
      {int limit = 8}) {
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

    final id = raw['id'] is int
        ? raw['id'] as int
        : int.tryParse('${raw['id']}') ?? 0;

    final createdAt = _parseCreatedAt(raw['createdAt']?.toString());
    final typeId = raw['type']?['id'];
    late String icon;
    late String sign;
    late String title;
    var isOutgoing = false;
    String? counterpartyUsername;
    String? counterpartyIban;

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
              raw['toBankAccount']?['user']?['username']?.toString() ??
                  raw['toBankAccount']?['name']?.toString();
          counterpartyIban = raw['toBankAccount']?['iban']?.toString();
        } else {
          counterpartyUsername =
              raw['fromBankAccount']?['user']?['username']?.toString() ??
                  raw['fromBankAccount']?['name']?.toString();
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
      id: id,
      iconUrl: icon,
      title: title,
      timeLabel: DateFormat("MMMM dd, yyyy 'at' hh:mm a").format(createdAt),
      value: '$sign ${formatCurrency(amount, symbol: '')}',
      amount: amount,
      createdAt: createdAt,
      counterpartyUsername: counterpartyUsername,
      counterpartyIban: counterpartyIban,
      isOutgoing: isOutgoing,
      description: raw['description']?.toString(),
      referenceNumber: raw['referenceNumber']?.toString(),
      typeId: typeId is int ? typeId : int.tryParse('$typeId'),
    );
  }

  DateTime _parseCreatedAt(String? createdAtString) {
    if (createdAtString == null || createdAtString.isEmpty) {
      return DateTime.now();
    }
    try {
      return DateFormat('dd-MM-yyyy HH:mm:ss').parse(createdAtString);
    } catch (_) {}
    try {
      return DateFormat('dd.MM.yyyy HH:mm:ss').parse(createdAtString);
    } catch (_) {
      return DateTime.now();
    }
  }
}
