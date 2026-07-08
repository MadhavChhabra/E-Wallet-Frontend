import 'package:flutter/material.dart';
import 'package:flutter_ewallet/models/user_model.dart';
import 'package:flutter_ewallet/ui/pages/card/pick_a_card.dart';
import 'package:flutter_ewallet/ui/pages/transaction_history.dart';
import 'package:flutter_ewallet/ui/widgets/notifications_sheet.dart';
import 'package:flutter_ewallet/ui/widgets/animated_entrance.dart';
import 'package:flutter_ewallet/ui/widgets/profile_avatar.dart';
import 'package:flutter_ewallet/ui/widgets/custom_home_services.dart';
import 'package:flutter_ewallet/ui/widgets/custom_latest_transaction_item.dart';
import 'package:flutter_ewallet/ui/widgets/custom_user.dart';
import 'package:flutter_ewallet/utils/shared.dart';
import 'package:flutter_ewallet/utils/shared_user.dart';
import 'package:flutter_ewallet/utils/theme.dart';

import 'package:flutter_ewallet/models/transaction_item.dart';
import 'package:flutter_ewallet/services/transaction_service.dart';
import 'package:flutter_ewallet/ui/widgets/app_section_card.dart';
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

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

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
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest Transactions',
            style: blackTextStyle.copyWith(
              fontSize: 17,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const AppSectionCard(
              child: SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else if (latestTransactions.isEmpty)
            AppSectionCard(
              child: Center(
                child: Text(
                  'Your latest transactions will appear here.',
                  style: greyTextStyle.copyWith(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
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
  const AccountsWidget({Key? key}) : super(key: key);

  @override
  _AccountsWidgetState createState() => _AccountsWidgetState();
}

class _AccountsWidgetState extends State<AccountsWidget> {
  List<dynamic> data = [];
  int currentIndex = 0;
  bool loading = true;
  final PageController _pageController = PageController();
  String? fullName;

  @override
  void initState() {
    super.initState();
    fetchAccountData();
  }

  Future<void> fetchAccountData() async {
    int? userId;
    String? naam;
    try {
      final UserModel? user = await SharedUser().getCurrentUser();
      if (user != null) {
        userId = user.id;
        naam = "${user.firstname} ${user.lastname}";
      }
      final response =
          await HttpService.getWithAuth('/bank-accounts/users/$userId');

      for (var i = 0; i < response['data'].length; i++) {
        final account = response['data'][i];
        final accountId = account['id'].toString();
        if (i == 0) {
          final email = account['user']['email']?.toString();
          if (email != null) {
            await SharedUser().writeToStorage('email', email);
          }
        }
        await SharedUser().writeToStorage('bank_account_$accountId', accountId);
      }

      setState(() {
        data = response['data'];
        loading = false;
        fullName = naam;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
                    physics: const BouncingScrollPhysics(),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final bankAccount = data[index];
                      return WalletCard(
                        index: index,
                        userFullName: bankAccount['name'],
                        name: bankAccount['name'],
                        iban: bankAccount['iban'],
                        balance: (bankAccount['balance'] as num).toDouble(),
                      );
                    },
                    onPageChanged: (index) {
                      setState(() => currentIndex = index);
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
// start here

class SendAgainWidget extends StatefulWidget {
  const SendAgainWidget({super.key});

  @override
  State<SendAgainWidget> createState() => _SendAgainWidgetState();
}

class _SendAgainWidgetState extends State<SendAgainWidget> {
  List<String> sendList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> reload({bool forceRefresh = false}) =>
      _loadUsers(forceRefresh: forceRefresh);

  Future<void> _loadUsers({bool forceRefresh = false}) async {
    try {
      final items = await TransactionService.instance.fetchForCurrentUser(
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
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
              return CustomUser(
                image: Image.asset('assets/placeholder_image.jpg'),
                userName: sendList[index],
              );
            },
          ),
        ),
      ],
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
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
  double ProgressSpent = 0;

  void updateProgressSpent(double newValue) {
    setState(() {
      ProgressSpent = newValue;
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

  // void fetchEmail() async {
  //   final UserModel? user = await SharedUser().getCurrentUser();
  //   if (user != null) {
  //     print('User is not null');
  //     int? id = user.id;

  //     if (id != null) {
  //       print('User id not null');

  //       final response = await HttpService.getWithAuth(
  //           "${SharedValues.baseUrl}/auth/email/$id");
  //       print("${SharedValues.baseUrl}/auth/email/$id");
  //       SharedUser().writeToStorage('email', response['message']);
  //       print(response.toString());
  //     } else {
  //       print('USER ID NULL EMAIL');
  //     }
  //   }
  // }

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

  // Future<void> _fetchArticles() async {
  //   try {
  //     final articles =
  //         await _newsApiService.fetchTopHeadlines(category: 'business');
  //     print("AYYYOOOOOOOOOOO" + articles.isEmpty.toString());
  //     setState(() {
  //       _articles = articles;
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  @override
  void initState() {
    super.initState();
    fetchData();
    _fetchProfileImage();
    // fetchEmail();"${SharedValues.baseUrl}/auth/email/$id"
    // _fetchArticles();
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
      color: purpleColor,
      child: Container(
        decoration: const BoxDecoration(gradient: homeBackgroundGradient),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedEntrance(
                  child: _HomeHeaderCard(
                    child: buildProfileSection(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      const SizedBox(height: 96),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProgressLevel() {
    final totalSpent = ProgressSpent;
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
            child: SizedBox(
              height: 8,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: lightBackgroundColor),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(gradient: progressGradient),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BottomAppBar customBottomAppBar() {
    return BottomAppBar(
      elevation: 0,
      color: whiteColor,
      shape: const CircularNotchedRectangle(),
      clipBehavior: Clip.antiAlias,
      notchMargin: 6,
      child: BottomNavigationBar(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          if (index != 0) {
            // Navigate to respective pages for indexes other than 0 (Home)
            switch (index) {
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SelectCard()),
                );
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TransactionHistoryPage()),
                );
                break;
              case 3:
                // or reward
                break;
              default:
                break;
            }
          }
        },
        backgroundColor: whiteColor,
        selectedItemColor: blueColor,
        unselectedItemColor: blackColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: blueTextStyle.copyWith(
          fontSize: 10,
          fontWeight: medium,
        ),
        unselectedLabelStyle: blackTextStyle.copyWith(
          fontSize: 10,
          fontWeight: medium,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/ic_overview.png',
              width: 20,
              color: blueColor,
            ),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/ic_history.png',
              width: 20,
            ),
            label: 'History',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_rounded),
            //  Image.asset(
            //   'assets/ic_statistic.png',
            //   width: 20,
            // ),
            label: 'Cards',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/ic_reward.png',
              width: 20,
            ),
            label: 'Reward',
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
            color: purpleColor.withOpacity(0.92),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
              CustomHomeServices(
                iconUrl: 'assets/qr_scan_2.png',
                title: 'Scan any',
                subtitle: 'QR Code',
                preferredHeight: 40,
                preferredWidth: 40,
                tileGradient: [purpleColor.withOpacity(0.18), purpleColor.withOpacity(0.06)],
                onTap: () {
                  Navigator.pushNamed(context, '/QR_Scanner');
                },
              ),
              CustomHomeServices(
                iconUrl: 'assets/send_money.png',
                title: 'Send',
                subtitle: 'Money',
                preferredHeight: 50,
                preferredWidth: 50,
                tileGradient: [blueColor.withOpacity(0.22), blueColor.withOpacity(0.08)],
                onTap: () {
                  Navigator.pushNamed(context, '/transfer');
                },
              ),
              CustomHomeServices(
                iconUrl: 'assets/self_transfer.png',
                title: 'Self',
                subtitle: 'Transfer',
                preferredHeight: 32,
                preferredWidth: 32,
                tileGradient: [tealColor.withOpacity(0.22), tealColor.withOpacity(0.08)],
                onTap: () {
                  Navigator.pushNamed(context, '/selfTransfer');
                },
              ),
              CustomHomeServices(
                iconUrl: 'assets/img_wallet.png',
                title: 'Top Up',
                subtitle: 'Wallet',
                preferredHeight: 30,
                preferredWidth: 30,
                tileGradient: [amberColor.withOpacity(0.24), coralColor.withOpacity(0.10)],
                onTap: () {
                  Navigator.pushNamed(context, '/topup');
                },
              ),
            ],
          ),
        ],
    );
  }

  Widget buildCardBank() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.all(30),
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: const DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(
            'assets/img_bg_card.png',
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$name $lastname',
            style: whiteTextStyle.copyWith(
              fontSize: 18,
              fontWeight: medium,
            ),
          ),
          const SizedBox(
            height: 28,
          ),
          Text(
            '****  ****  ****  1234',
            style: whiteTextStyle.copyWith(
              fontSize: 18,
              fontWeight: medium,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text('Balance', style: whiteTextStyle),
          Text(
            formatCurrency(12500),
            style: whiteTextStyle.copyWith(
              fontSize: 24,
              fontWeight: semiBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfileSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
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
                  style: whiteTextStyle.copyWith(
                    fontSize: 15,
                    color: whiteColor.withOpacity(0.82),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: whiteTextStyle.copyWith(
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
                color: whiteColor.withOpacity(0.16),
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
                        Icon(Icons.notifications_outlined, color: whiteColor),
                        Positioned(
                          right: -1,
                          top: -1,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: redColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: whiteColor, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ProfileAvatar(
                image: _profileImage.image,
                size: 48,
                onTap: () => Navigator.pushNamed(context, '/profile'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeHeaderCard extends StatelessWidget {
  const _HomeHeaderCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      decoration: BoxDecoration(
        gradient: homeHeaderGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: purpleColor.withOpacity(0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}
// class MoreDialog extends StatelessWidget {
//   const MoreDialog({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: Colors.transparent,
//       insetPadding: EdgeInsets.zero,
//       alignment: Alignment.bottomCenter,
//       content: Container(
//         height: 326,
//         width: MediaQuery.of(context).size.width,
//         padding: const EdgeInsets.all(30),
//         decoration: BoxDecoration(
//           color: lightBackgroundColor,
//           borderRadius: BorderRadius.circular(40),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Do More With Us",
//               style: blackTextStyle.copyWith(
//                 fontSize: 16,
//                 fontWeight: semiBold,
//               ),
//             ),
//             const SizedBox(
//               height: 13,
//             ),
//             Wrap(
//               spacing: 29,
//               runSpacing: 25,
//               children: [
//                 CustomHomeServices(
//                   iconUrl: 'assets/ic_product_data.png',
//                   title: 'Data',
//                   onTap: () {
//                     Navigator.pushNamed(context, '/data-provider');
//                   },
//                 ),
//                 const CustomHomeServices(
//                   iconUrl: 'assets/ic_product_water.png',
//                   title: 'Water',
//                 ),
//                 const CustomHomeServices(
//                   iconUrl: 'assets/ic_product_stream.png',
//                   title: 'Stream',
//                 ),
//                 const CustomHomeServices(
//                   iconUrl: 'assets/ic_product_movie.png',
//                   title: 'Movie',
//                 ),
//                 const CustomHomeServices(
//                   iconUrl: 'assets/ic_product_food.png',
//                   title: 'Food',
//                 ),
//                 const CustomHomeServices(
//                   iconUrl: 'assets/ic_product_travel.png',
//                   title: 'Travel',
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// }
