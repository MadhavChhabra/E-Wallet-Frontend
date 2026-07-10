import 'package:flutter_ewallet/models/wallet_account.dart';
import 'package:flutter_ewallet/models/user_model.dart';
import 'package:flutter_ewallet/services/http_service.dart';
import 'package:flutter_ewallet/services/transaction_service.dart';
import 'package:flutter_ewallet/utils/shared_user.dart';

/// Loads the current user's wallet accounts and recent payees.
class WalletAccountService {
  WalletAccountService._();
  static final WalletAccountService instance = WalletAccountService._();

  List<WalletAccount>? _cache;
  String? _preferredIban;

  void invalidate() => _cache = null;

  void setPreferredIban(String iban) => _preferredIban = iban;

  Future<String?> preferredWalletIban() async {
    if (_preferredIban != null) return _preferredIban;
    final accounts = await fetchAccounts();
    if (accounts.isEmpty) return null;
    return accounts.first.iban;
  }

  Future<double?> balanceForIban(String iban) async {
    final accounts = await fetchAccounts();
    for (final account in accounts) {
      if (account.iban == iban) return account.balance;
    }
    return null;
  }

  Future<WalletAccount?> accountForIban(String iban) async {
    final accounts = await fetchAccounts();
    for (final account in accounts) {
      if (account.iban == iban) return account;
    }
    return null;
  }

  Future<List<WalletAccount>> fetchAccounts({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return _cache!;

    final UserModel? user = await SharedUser().getCurrentUser();
    if (user?.id == null) {
      _cache = const [];
      return _cache!;
    }

    final response =
        await HttpService.getWithAuth('/bank-accounts/users/${user!.id}');
    final data = response['data'];
    if (data is! List) {
      _cache = const [];
      return _cache!;
    }

    final accounts = <WalletAccount>[];
    for (final raw in data) {
      if (raw is Map<String, dynamic>) {
        final account = WalletAccount.fromJson(raw);
        if (account != null) {
          accounts.add(account);
          await SharedUser().writeToStorage(
            'bank_account_${account.id}',
            account.id.toString(),
          );
        }
      }
    }

    _cache = accounts;
    if (_preferredIban == null && accounts.isNotEmpty) {
      _preferredIban = accounts.first.iban;
    }
    return accounts;
  }

  Future<List<PayeeOption>> recentPayees({int limit = 8}) async {
    final items =
        await TransactionService.instance.fetchForCurrentUser(forceRefresh: true);
    final seen = <String>{};
    final payees = <PayeeOption>[];

    for (final item in items) {
      if (!item.isOutgoing) continue;
      final iban = item.counterpartyIban;
      if (iban == null || iban.isEmpty || seen.contains(iban)) continue;
      seen.add(iban);
      final name = item.counterpartyUsername ?? 'Contact';
      payees.add(PayeeOption(
        label: '$name · …${iban.substring(iban.length - 4)}',
        iban: iban,
      ));
      if (payees.length >= limit) break;
    }
    return payees;
  }
}
