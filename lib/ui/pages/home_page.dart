import 'package:flutter/material.dart';
import 'package:flutter_ewallet/models/user_model.dart';
import 'package:flutter_ewallet/ui/pages/card/pick_a_card.dart';
import 'package:flutter_ewallet/ui/pages/transaction_history.dart';
import 'package:flutter_ewallet/ui/widgets/notifications_sheet.dart';
import 'package:flutter_ewallet/ui/widgets/custom_card_friendly.dart';
import 'package:flutter_ewallet/ui/widgets/custom_home_services.dart';
import 'package:flutter_ewallet/ui/widgets/custom_latest_transaction_item.dart';
import 'package:flutter_ewallet/ui/widgets/custom_user.dart';
import 'package:flutter_ewallet/utils/shared.dart';
import 'package:flutter_ewallet/utils/shared_user.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../models/article_model.dart';
import '../../services/http_service.dart';
import '../../services/image_service.dart';
import '../../services/news_api_service.dart';
import '../widgets/custom_wallet_card.dart';

class TransactionListWidget extends StatefulWidget {
  final Function(double) callback;
  const TransactionListWidget({Key? key, required this.callback})
      : super(key: key);

  @override
  _TransactionListWidgetState createState() => _TransactionListWidgetState();
}

class _TransactionListWidgetState extends State<TransactionListWidget> {
  List<Transaction> latestTransactions = [];
  double ProgressSpent = 0;

  var userId;

  void updateSpendings(double newValue) {
    setState(() {
      ProgressSpent = newValue;
      widget.callback(ProgressSpent);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUserTransactions();
  }

  DateTime parseCustomDateTime(String dateTimeString) {
    List<String> parts = dateTimeString.split(' ');
    String datePart = parts[0];
    String timePart = parts[1];

    List<String> dateParts = datePart.split('-');
    int year = int.parse(dateParts[2]);
    int month = int.parse(dateParts[1]);
    int day = int.parse(dateParts[0]);

    List<String> timeParts = timePart.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    int second = int.parse(timeParts[2].split('.')[0]); // Remove milliseconds

    return DateTime(year, month, day, hour, minute, second);
  }

  Future<void> fetchUserTransactions() async {
    try {
      int? userId;
      final UserModel? user = await SharedUser().getCurrentUser();
      if (user != null) {
        userId = user.id;
      }
      if (userId == null) {
      } else {
        final response =
            await HttpService.getWithAuth('/transactions/users/$userId');
        List<String> bankAccountIDs =
            await SharedUser().retrieveBankAccountIds();

        if (response['message'] == 'Success') {

          List<Transaction> transactions = [];
          List<dynamic> dataList = response['data']['content'];

          for (var item in dataList) {
            var amount = item['amount'] != null
                ? double.tryParse(item['amount'].toString())
                : null;
            String createdAtString = item['createdAt'];

            // Check if createdAtString is not null before parsing
            DateTime createdAtDateTime = parseCustomDateTime(createdAtString);
            String createdAtFormatted = DateFormat("MMMM dd, yyyy 'at' hh:mm a")
                .format(createdAtDateTime);

            if (amount != null) {
              String icon;
              String sign;
              String title;

              switch (item['type']['id']) {
                case 1:
                  icon = "assets/ic_transaction_cat1.png"; // Deposit icon
                  sign = '+';
                  title = "Deposit";
                  break;
                case 2:
                  icon = "assets/ic_transaction_cat3.png"; // Withdrawal icon
                  sign = '-';
                  title = "Withdrawal";
                  break;
                case 3:
                  icon = bankAccountIDs
                          .contains(item['fromBankAccount']['id'].toString())
                      ? "assets/ic_transaction_cat3.png"
                      : "assets/ic_transaction_cat1.png"; // Transfer icon
                  sign = bankAccountIDs
                          .contains(item['fromBankAccount']['id'].toString())
                      ? '-'
                      : '+';
                  title = "Transfer";
                  break;
                default:
                  icon =
                      "assets/ic_transaction_cat5.png"; // Default icon for unknown transaction type
                  sign = '';
                  title = "Transaction";
              }

              transactions.add(Transaction(
                iconUrl: icon,
                title: title,
                time: createdAtFormatted,
                value: '$sign ${formatCurrency(amount, symbol: '')}',
              ));
            }
          }
          double totalSpent = 0;
          for (var transaction in transactions) {
            var amount = double.tryParse(
              transaction.value.replaceAll(RegExp(r'[^\d.]'), ''),
            );
            if (amount != null) {
              if (transaction.title == 'Withdrawal' ||
                  transaction.title == 'Transfer') {
                totalSpent += amount;
              } else {
                totalSpent = totalSpent;
              }
            }
          }

          transactions.sort((a, b) => b.time.compareTo(a.time));

          updateSpendings(totalSpent);

          setState(() {
            latestTransactions = transactions;
            // ProgressSpent = totalSpent;
            // print("PROGRESS SPENT IS $ProgressSpent");
          });
        }
      }
    } catch (error) {
    }
  }

  @override
  Widget build(BuildContext context) {
    // setState(() {});

    return Container(
        margin: const EdgeInsets.only(top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latest Transaction',
              style: blackTextStyle.copyWith(
                fontSize: 16,
                fontWeight: semiBold,
              ),
            ),
            latestTransactions.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.only(top: 14),
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: whiteColor,
                    ),
                    child: Column(
                      children: latestTransactions.take(5).map((transaction) {
                        return LatestTransactionItem(
                          // icon: transaction.icon,
                          title: transaction.title,
                          time: transaction.time,
                          value: transaction.value,
                          iconUrl: transaction.iconUrl,
                        );
                      }).toList(),
                    ),
                  )
                : Container(
                    color: whiteColor,
                    padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 50),
                    child: Center(
                        child: Text(
                      "Your Latest Transactions will be shown here",
                      style: blackTextStyle.copyWith(fontSize: 16),
                      textAlign: TextAlign.center,
                    ))),
          ],
        ));
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

      for (var account in response['data']) {
        final accountId = account['id'].toString();
        String email = account['user']['email'];
        await SharedUser().writeToStorage('email', email);
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
    return loading
        ? const Center(child: CircularProgressIndicator())
        : data.isNotEmpty
            ? RefreshIndicator(
                onRefresh: fetchAccountData,
                child: Column(
                  children: [
                    SizedBox(
                      height: 250,
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
                            balance: bankAccount['balance'],
                          );
                        },
                        onPageChanged: (index) {
                          setState(() {
                            currentIndex = index;
                          });
                        },
                      ),
                    ),
                    _buildIndicatorDots(),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: fetchAccountData,
                child: Column(children: [
                  SizedBox(
                      height: 250,
                      child: WalletCard(
                        userFullName: fullName.toString(),
                        name: "Bank Name",
                        iban: "IN1656519616165",
                        balance: 0,
                      ))
                ]),
              );
  }

  Widget _buildIndicatorDots() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          data.length,
          (index) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentIndex == index
                  ? Colors.blue
                  : Colors.blue.withOpacity(0.5),
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
  Set<CustomUser> sendList = {};

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      int? userId;
      final UserModel? user = await SharedUser().getCurrentUser();
      if (user != null) {
        userId = user.id;
      }

      if (userId == null) {
      } else {
        final response =
            await HttpService.getWithAuth('/transactions/users/$userId');

        if (response['message'] == 'Success') {

          List<dynamic> dataList = response['data']['content'];

          for (var item in dataList) {
            String username =
                item['toBankAccount']['user']['username'].toString();
            int id = item['toBankAccount']['user']['id'];

            Image image = await _fetchProfileImagebyID(id) ??
                Image.asset('assets/placeholder_image.jpg');

            sendList.add(
              CustomUser(
                image: image,
                userName: username,
              ),
            );
          }

          setState(() {});
        }
      }
    } catch (error) {
    }
  }

  Future<Image?> _fetchProfileImagebyID(int id) async {
    // The backend only exposes the *current* user's profile image, so avatars
    // for other users fall back to the placeholder.
    return null;
  }

  @override
  Widget build(BuildContext context) {
    int numberOfColumns = 4;
    int numberOfRows = (sendList.length / numberOfColumns).ceil();
    double rowHeight = 100.0; // Adjust row height as needed
    double gridHeight = numberOfRows * rowHeight;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 16,
        ),
        Text(
          'Send Again',
          style: blackTextStyle.copyWith(
            fontSize: 16,
            fontWeight: semiBold,
          ),
        ),
        sendList.isNotEmpty
            ? Container(
                margin: const EdgeInsets.only(left: 7, right: 7, bottom: 14, top: 10),
                height: gridHeight + 10, // Use calculated grid height
                padding: const EdgeInsets.only(top: 10),
                // padding: const EdgeInsets.only(right: 22, left: 22, bottom: 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: whiteColor,
                ),
                width: MediaQuery.of(context).size.width,
                child: sendList.isNotEmpty
                    ? GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: numberOfColumns,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: sendList.length,
                        itemBuilder: (context, index) {
                          return sendList.elementAt(index);
                        },
                      )
                    : Center(
                        child: Text("Kindly Make any payments",
                            style: blackTextStyle.copyWith(fontSize: 16)),
                      ),
              )
            : Container(
                color: whiteColor,
                padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 50),
                child: Center(
                    child: Text(
                  "Kindly Make any payments",
                  style: blackTextStyle.copyWith(fontSize: 16),
                ))),
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
  List<Transaction> latestTransactions = [];
  final GlobalKey<_TransactionListWidgetState> _transactionListKey =
      GlobalKey<_TransactionListWidgetState>();
  final GlobalKey<_AccountsWidgetState> _accountsListKey =
      GlobalKey<_AccountsWidgetState>();
  final GlobalKey<_SendAgainWidgetState> _sendAgainKey =
      GlobalKey<_SendAgainWidgetState>();

  final _newsApiService = NewsApiService();
  final List<Article> _articles = [];

  String name = 'user';

  Image _profileImage = SharedUser().getProfileImage();

  String lastname = '';

  double ProgressSpent = 0;

  void updateProgressSpent(double newValue) {
    setState(() {
      ProgressSpent = newValue;
    });
  }

  void fetchData() async {
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
    try {
      // Fetch new data and update the state
      fetchData();
      _fetchProfileImage();
    } catch (error) {
      Fluttertoast.showToast(msg: 'Failed to Refresh');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List numbers = ['1', '2', '3', '5'];
    return

        // Scaffold(
        // bottomNavigationBar: customBottomAppBar(),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     Navigator.of(context).pushNamed("/addCard");
        //   },
        //   backgroundColor: purpleColor,
        //   child: Image.asset(
        //     'assets/ic_plus_circle.png',
        //     width: 24,
        //   ),
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // body:

        RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildProfileSection(context),
                AccountsWidget(key: _accountsListKey),
                buildProgressLevel(),
                // buildProgressLevel(_TransactionListWidgetState().ProgressSpent),
                buildServices(context),
                TransactionListWidget(
                  key: _transactionListKey,
                  callback: updateProgressSpent,
                ),
                SendAgainWidget(
                  key: _sendAgainKey,
                ),
                // buildSendAgain(),
                // buildFriendlyTips()
              ],
            ),
          ),
        ),
      ),
      // ),
    );
  }

  Widget buildProgressLevel() {
    double totalSpent = ProgressSpent;
    // Determine the level and progress based on totalSpent
    int level = (totalSpent ~/ 10000) + 1;
    int levelCap = level * 10000;
    double progress = totalSpent / levelCap;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: whiteColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Level $level',
                style: blackTextStyle.copyWith(
                  fontWeight: medium,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: greenTextStyle.copyWith(
                  fontWeight: semiBold,
                ),
              ),
              Text(
                ' of ${formatCurrency(levelCap)}',
                style: blackTextStyle.copyWith(
                  fontWeight: semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(55),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: progress,
              color: greenColor,
              backgroundColor: lightBackgroundColor,
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

  Widget buildFriendlyTips() {
    return FutureBuilder(
      future: _newsApiService.fetchTopHeadlines(),
      builder: (BuildContext context, AsyncSnapshot<List<Article>> snapshot) {
        if (snapshot.hasData) {
          List<Article>? articles = snapshot.data;
          _articles.isNotEmpty
              ? GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16),
                  itemCount: articles?.length,
                  itemBuilder: (context, index) {
                    final article = _articles[index];
                    return FriendlyCustomCard(
                      imageUrl: article.urlToImage,
                      title: article.title,
                      url: article.url,
                    );
                  })
              : const Center(
                  child: CircularProgressIndicator(),
                );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  // Widget buildFriendlyTips() {
  //   return Container(
  //     margin: const EdgeInsets.only(top: 30, bottom: 50),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Friendly Tips',
  //           style: blackTextStyle.copyWith(
  //             fontSize: 16,
  //             fontWeight: semiBold,
  //           ),
  //         ),
  //         const SizedBox(
  //           height: 14,
  //         ),
  //         _articles.isNotEmpty
  //             ? GridView.builder(
  //                 padding: const EdgeInsets.all(16),
  //                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //                   crossAxisCount: 2,
  //                   childAspectRatio: 0.7,
  //                   mainAxisSpacing: 16,
  //                   crossAxisSpacing: 16,
  //                 ),
  //                 itemCount: _articles.length,
  //                 itemBuilder: (context, index) {
  //                   final article = _articles[index];
  //                   return FriendlyCustomCard(
  //                     imageUrl: article.urlToImage,
  //                     title: article.title,
  //                     url: article.url,
  //                   );
  //                 },
  //               )
  //             : Center(
  //                 child: CircularProgressIndicator(),
  //               ),
  //       ],
  //     ),
  //   );
  // }

  // Widget buildSendAgain() {
  //   return Container(
  //     margin: const EdgeInsets.only(top: 30),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Send Again',
  //           style: blackTextStyle.copyWith(
  //             fontSize: 16,
  //             fontWeight: semiBold,
  //           ),
  //         ),
  //         const SizedBox(
  //           height: 16,
  //         ),
  //         const SingleChildScrollView(
  //           scrollDirection: Axis.horizontal,
  //           child: Row(
  //             children: [
  //               CustomUser(
  //                 imageUrl: 'assets/img_friend1.png',
  //                 userName: '@idkher',
  //               ),
  //               CustomUser(
  //                 imageUrl: 'assets/img_friend2.png',
  //                 userName: '@she',
  //               ),
  //               CustomUser(
  //                 imageUrl: 'assets/img_friend3.png',
  //                 userName: '@boii',

  //               ),
  //               CustomUser(
  //                 imageUrl: 'assets/img_friend4.png',
  //                 userName: '@gigachad',
  //               ),
  //               CustomUser(
  //                 imageUrl: 'assets/img_friend1.png',
  //                 userName: '@stree',
  //               ),
  //             ],
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

  Widget buildLatestTransaction() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest Transaction',
            style: blackTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semiBold,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: whiteColor,
            ),
            child: Column(
              children: latestTransactions.take(4).map((transaction) {
                return LatestTransactionItem(
                  // icon: transaction.icon,
                  title: transaction.title,
                  time: transaction.time,
                  value: transaction.value, iconUrl: '',
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildServices(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Do Something',
            style: blackTextStyle.copyWith(
              fontSize: 18,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              CustomHomeServices(
                iconUrl: 'assets/card_payment.png',
                title: 'Pay Using',
                subtitle: 'Card',
                preferredHeight: 35,
                preferredWidth: 35,
                onTap: () {
                  Navigator.pushNamed(context, '/cardPayment');
                  // showDialog(
                  //     context: context,
                  //     builder: (context) => const MoreDialog());
                },
              ),
            ],
          ),
        ],
      ),
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

class Transaction {
  final String iconUrl;
  final String title;
  final String time;
  final String value;

  Transaction(
      {required this.iconUrl,
      required this.title,
      required this.time,
      required this.value});
}
