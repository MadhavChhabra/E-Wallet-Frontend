import 'package:flutter/material.dart';
import 'package:flutter_ewallet/models/user_model.dart';
import 'package:flutter_ewallet/utils/app_events.dart';
import 'package:flutter_ewallet/utils/iban.dart';
import 'package:flutter_ewallet/ui/widgets/notifications_sheet.dart';
import 'package:flutter_ewallet/ui/widgets/animated_entrance.dart';
import 'package:flutter_ewallet/ui/widgets/custom_home_services.dart';
import 'package:flutter_ewallet/ui/widgets/custom_latest_transaction_item.dart';
import 'package:flutter_ewallet/ui/widgets/custom_user.dart';
import 'package:flutter_ewallet/utils/wallet_utils.dart';
import 'package:flutter_ewallet/utils/shared.dart';
import 'package:flutter_ewallet/utils/shared_user.dart';
import 'package:flutter_ewallet/utils/theme.dart';

import 'package:flutter_ewallet/models/transaction_item.dart';
import 'package:flutter_ewallet/services/transaction_service.dart';
import 'package:flutter_ewallet/ui/pages/transaction_detail_page.dart';
import 'package:flutter_ewallet/ui/widgets/app_section_card.dart';
import 'package:flutter_ewallet/services/wallet_account_service.dart';
import '../../services/http_service.dart';
import '../../services/image_service.dart';
import '../widgets/custom_wallet_card.dart';

class TransactionListWidget extends StatefulWidget {
  final Function(double) callback;
  const TransactionListWidget({super.key, required this.callback});

  @override
  State<TransactionListWidget> createState() => _TransactionListWidgetState();
}

class _TransactionListWidgetState extends State<TransactionListWidget> {
  List<TransactionItem> latestTransactions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    AppEvents.instance.walletChanged.addListener(_onWalletChanged);
  }

  @override
  void dispose() {
    AppEvents.instance.walletChanged.removeListener(_onWalletChanged);
    super.dispose();
  }

  void _onWalletChanged() => _loadTransactions(forceRefresh: true);

  Future<void> reload({bool forceRefresh = false}) =>
      _loadTransactions(forceRefresh: forceRefresh);

  Future<void> _loadTransactions({bool forceRefresh = false}) async {
    try {
      final items = await TransactionService.instance.fetchForCurrentUser(
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      widget.callback(
        TransactionService.instance.totalOutgoingSpend(items),
      );
      setState(() {
        latestTransactions = items;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  void _openDetail(TransactionItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransactionDetailPage(transactionId: item.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Latest Transactions',
                  style: blackTextStyle.copyWith(
                    fontSize: 17,
                    fontWeight: semiBold,
                  ),
                ),
              ),
              if (latestTransactions.isNotEmpty)
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/transactionHistory'),
                  child: Text(
                    'See all',
                    style: blueTextStyle.copyWith(fontSize: 13),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading)
            const AppSectionCard(
              child: SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else if (_error != null)
            AppSectionCard(
              child: Column(
                children: [
                  Text(
                    'Couldn\'t load transactions',
                    style: blackTextStyle.copyWith(fontWeight: semiBold),
                  ),
                  const SizedBox(height: 8),
                  Text(_error!, style: greyTextStyle.copyWith(fontSize: 12)),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      setState(() => _loading = true);
                      _loadTransactions(forceRefresh: true);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (latestTransactions.isEmpty)
            AppSectionCard(
              child: Column(
                children: [
                  Text(
                    'No transactions yet.',
                    style: greyTextStyle.copyWith(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/transfer'),
                        child: const Text('Send money'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/topup-amount'),
                        child: const Text('Top up'),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            AppSectionCard(
              child: Column(
                children: latestTransactions.take(5).map((transaction) {
                  return LatestTransactionItem(
                    title: transaction.title,
                    time: transaction.timeLabel,
                    value: transaction.value,
                    iconUrl: transaction.iconUrl,
                    onTap: () => _openDetail(transaction),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class AccountsWidget extends StatefulWidget {
  const AccountsWidget({super.key});

  @override
  State<AccountsWidget> createState() => _AccountsWidgetState();
}

class _AccountsWidgetState extends State<AccountsWidget> {
  List<dynamic> data = [];
  int currentIndex = 0;
  bool loading = true;
  String? loadError;
  final PageController _pageController = PageController();
  String? fullName;
  bool _provisioned = false;

  @override
  void initState() {
    super.initState();
    fetchAccountData();
    AppEvents.instance.walletChanged.addListener(_onWalletChanged);
  }

  @override
  void dispose() {
    AppEvents.instance.walletChanged.removeListener(_onWalletChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onWalletChanged() => fetchAccountData();

  Future<void> fetchAccountData() async {
    int? userId;
    String? naam;
    setState(() => loadError = null);
    try {
      final UserModel? user = await SharedUser().getCurrentUser();
      if (user != null) {
        userId = user.id;
        naam = "${user.firstname} ${user.lastname}";
      }
      final response =
          await HttpService.getWithAuth('/bank-accounts/users/$userId');
      final List<dynamic> accounts =
          (response['data'] as List<dynamic>?) ?? <dynamic>[];

      // A brand-new user has no wallet yet — auto-provision a funded one so the
      // dashboard is immediately usable (transfers, top-up, cards). Done once.
      if (accounts.isEmpty && !_provisioned && userId != null) {
        _provisioned = true;
        try {
          await HttpService.postWithAuth('/bank-accounts', {
            'name': 'My Wallet',
            'iban': generateIban(),
            'balance': 5000,
            'userId': userId,
          });
          return fetchAccountData();
        } catch (_) {
          // Fall through and show the empty state if provisioning fails.
        }
      }

      for (var i = 0; i < accounts.length; i++) {
        final account = accounts[i];
        final accountId = account['id'].toString();
        if (i == 0) {
          final email = account['user']?['email']?.toString();
          if (email != null) {
            await SharedUser().writeToStorage('email', email);
          }
        }
        await SharedUser().writeToStorage('bank_account_$accountId', accountId);
      }

      if (!mounted) return;
      setState(() {
        data = accounts;
        loading = false;
        loadError = null;
        fullName = naam;
      });
      if (accounts.isNotEmpty) {
        final iban = accounts[currentIndex.clamp(0, accounts.length - 1)]['iban']
            ?.toString();
        if (iban != null) {
          WalletAccountService.instance.setPreferredIban(iban);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          loadError = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  String? get selectedIban {
    if (data.isEmpty || currentIndex >= data.length) return null;
    return data[currentIndex]['iban']?.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (loadError != null) {
      return SizedBox(
        height: 250,
        child: AppSectionCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_outlined, color: greyColor, size: 36),
              const SizedBox(height: 12),
              Text(
                'Couldn\'t load balance',
                style: blackTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semiBold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                loadError!,
                style: greyTextStyle.copyWith(fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  setState(() => loading = true);
                  fetchAccountData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return data.isNotEmpty
        ? RefreshIndicator(
            onRefresh: fetchAccountData,
            child: Column(
              children: [
                SizedBox(
                  height: 230,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final bankAccount = data[index];
                      return WalletCard(
                        index: index,
                        userFullName: bankAccount['name'],
                        name: bankAccount['name'],
                        iban: bankAccount['iban'],
                        balance: WalletUtils.parseBalance(bankAccount['balance']),
                      );
                    },
                    onPageChanged: (index) {
                      setState(() => currentIndex = index);
                      final iban = data[index]['iban']?.toString();
                      if (iban != null) {
                        WalletAccountService.instance.setPreferredIban(iban);
                      }
                    },
                  ),
                ),
                _buildIndicatorDots(),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: fetchAccountData,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                WalletCard(
                  userFullName: fullName ?? 'Guest',
                  name: 'Bank Account',
                  iban: 'Add an account to begin',
                  balance: 0,
                ),
              ],
            ),
          );
  }

  Widget _buildIndicatorDots() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          data.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: currentIndex == index ? 18 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              color: currentIndex == index
                  ? purpleColor
                  : purpleColor.withOpacity(0.25),
            ),
          ),
        ),
      ),
    );
  }
}

class SendAgainWidget extends StatefulWidget {
  const SendAgainWidget({super.key});

  @override
  State<SendAgainWidget> createState() => _SendAgainWidgetState();
}

class _SendAgainWidgetState extends State<SendAgainWidget> {
  List<String> sendList = [];
  List<TransactionItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    AppEvents.instance.walletChanged.addListener(_onWalletChanged);
  }

  @override
  void dispose() {
    AppEvents.instance.walletChanged.removeListener(_onWalletChanged);
    super.dispose();
  }

  void _onWalletChanged() => _loadUsers(forceRefresh: true);

  Future<void> reload({bool forceRefresh = false}) =>
      _loadUsers(forceRefresh: forceRefresh);

  Future<void> _loadUsers({bool forceRefresh = false}) async {
    try {
      final items = await TransactionService.instance.fetchForCurrentUser(
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _items = items;
        sendList = TransactionService.instance.recentCounterparties(items);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();
    if (sendList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Send Again',
          style: blackTextStyle.copyWith(
            fontSize: 17,
            fontWeight: semiBold,
          ),
        ),
        const SizedBox(height: 12),
        AppSectionCard(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.78,
            ),
            itemCount: sendList.length,
            itemBuilder: (context, index) {
              final name = sendList[index];
              return GestureDetector(
                onTap: () {
                  final iban = TransactionService.instance
                      .counterpartyIbanForUsername(_items, name);
                  if (iban == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Could not find this contact. Use Send Money instead.'),
                      ),
                    );
                    return;
                  }
                  Navigator.pushNamed(
                    context,
                    '/transfer',
                    arguments: iban,
                  );
                },
                child: CustomUser(
                  image: Image.asset('assets/placeholder_image.jpg'),
                  userName: name,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final GlobalKey<_TransactionListWidgetState> _transactionListKey =
      GlobalKey<_TransactionListWidgetState>();
  final GlobalKey<_AccountsWidgetState> _accountsListKey =
      GlobalKey<_AccountsWidgetState>();
  final GlobalKey<_SendAgainWidgetState> _sendAgainKey =
      GlobalKey<_SendAgainWidgetState>();

  String name = 'user';
  Image _profileImage = SharedUser().getProfileImage();
  String lastname = '';
  double progressSpent = 0;

  void updateProgressSpent(double newValue) {
    setState(() {
      progressSpent = newValue;
    });
  }

  Future<void> fetchData() async {
    final UserModel? user = await SharedUser().getCurrentUser();
    if (user != null) {
      String? firstName = user.firstname;
      String? lastName = user.lastname;

      if (firstName != null && lastName != null) {

        setState(() {
          name = firstName;
          lastname = lastName;
        });
      } else {
      }
    }
  }

  Future<void> _fetchProfileImage() async {
    try {
      final url = await ImageService.currentProfileImageUrl();
      if (url != null && mounted) {
        setState(() {
          _profileImage = Image.network(url);
        });
      }
    } catch (e) {
      // Keep the placeholder if the profile image can't be loaded.
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    _fetchProfileImage();
    AppEvents.instance.profileImageChanged.addListener(_fetchProfileImage);
  }

  @override
  void dispose() {
    AppEvents.instance.profileImageChanged.removeListener(_fetchProfileImage);
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    TransactionService.instance.invalidate();
    await fetchData();
    await _fetchProfileImage();
    await _accountsListKey.currentState?.fetchAccountData();
    await _transactionListKey.currentState?.reload(forceRefresh: true);
    await _sendAgainKey.currentState?.reload(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedEntrance(
                  child: buildProfileSection(context),
                ),
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 70),
                  child: AccountsWidget(key: _accountsListKey),
                ),
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 120),
                  child: buildProgressLevel(),
                ),
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 170),
                  child: buildServices(context),
                ),
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 220),
                  child: TransactionListWidget(
                    key: _transactionListKey,
                    callback: updateProgressSpent,
                  ),
                ),
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 270),
                  child: SendAgainWidget(key: _sendAgainKey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProgressLevel() {
    final totalSpent = progressSpent;
    final level = (totalSpent ~/ 10000) + 1;
    final levelCap = level * 10000;
    final progress = (totalSpent / levelCap).clamp(0.0, 1.0);

    return AppSectionCard(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Spending level $level',
                style: blackTextStyle.copyWith(fontWeight: semiBold),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: greenTextStyle.copyWith(fontWeight: semiBold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${formatCurrency(totalSpent)} of ${formatCurrency(levelCap)} this tier',
            style: greyTextStyle.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: progress,
              color: greenColor,
              backgroundColor: lightBackgroundColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildServices(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Quick actions',
          style: blackTextStyle.copyWith(
            fontSize: 17,
            fontWeight: semiBold,
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              CustomHomeServices(
                iconUrl: 'assets/qr_scan_2.png',
                title: 'Scan any',
                subtitle: 'QR Code',
                preferredHeight: 40,
                preferredWidth: 40,
                onTap: () {
                  Navigator.pushNamed(context, '/QR_Scanner');
                },
              ),
              const SizedBox(width: 8),
              CustomHomeServices(
                iconUrl: 'assets/send_money.png',
                title: 'Send',
                subtitle: 'Money',
                preferredHeight: 50,
                preferredWidth: 50,
                onTap: () {
                  Navigator.pushNamed(context, '/transfer');
                },
              ),
              const SizedBox(width: 8),
              CustomHomeServices(
                iconUrl: 'assets/img_wallet.png',
                title: 'Top Up',
                subtitle: 'Wallet',
                preferredHeight: 32,
                preferredWidth: 32,
                onTap: () {
                  final iban =
                      _accountsListKey.currentState?.selectedIban;
                  Navigator.pushNamed(
                    context,
                    '/topup-amount',
                    arguments: iban,
                  );
                },
              ),
              const SizedBox(width: 8),
              CustomHomeServices(
                iconUrl: 'assets/self_transfer.png',
                title: 'Self',
                subtitle: 'Transfer',
                preferredHeight: 32,
                preferredWidth: 32,
                onTap: () {
                  Navigator.pushNamed(context, '/selfTransfer');
                },
              ),
              const SizedBox(width: 8),
              CustomHomeServices(
                iconUrl: 'assets/card_payment.png',
                title: 'Pay from',
                subtitle: 'Wallet',
                preferredHeight: 35,
                preferredWidth: 35,
                onTap: () {
                  Navigator.pushNamed(context, '/cardPayment');
                },
              ),
            ],
          ),
        ),
        ],
    );
  }

  Widget buildProfileSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello',
                  style: greyTextStyle.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: blackTextStyle.copyWith(
                    fontSize: 22,
                    fontWeight: semiBold,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: whiteColor,
                shape: const CircleBorder(),
                elevation: 0,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => NotificationsSheet.show(context),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(Icons.notifications_outlined, color: blackColor),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: purpleColor.withOpacity(0.25), width: 2),
                    image: DecorationImage(
                      image: _profileImage.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
