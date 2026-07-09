import 'package:flutter/foundation.dart';
import 'package:flutter_ewallet/services/transaction_service.dart';
import 'package:flutter_ewallet/services/wallet_account_service.dart';

/// Lightweight app-wide event bus so screens can react to wallet mutations
/// (a new account, a transfer, a top-up) without being directly coupled.
///
/// The home screen's account/transaction widgets listen to [walletChanged] and
/// refetch; any flow that changes balances calls [notifyWalletChanged].
class AppEvents {
  AppEvents._();
  static final AppEvents instance = AppEvents._();

  /// Bumped whenever a wallet-affecting action succeeds.
  final ValueNotifier<int> walletChanged = ValueNotifier<int>(0);

  /// Bumped when saved cards change (add/delete).
  final ValueNotifier<int> cardsChanged = ValueNotifier<int>(0);

  void notifyWalletChanged() {
    walletChanged.value++;
    TransactionService.instance.invalidate();
    WalletAccountService.instance.invalidate();
  }

  void notifyCardsChanged() => cardsChanged.value++;
}
