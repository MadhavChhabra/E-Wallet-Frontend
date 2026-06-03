import 'package:flutter/material.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:intl/intl.dart';

import '../../models/user_model.dart';
import '../../services/http_service.dart';
import '../../utils/shared.dart';
import '../../utils/shared_user.dart';
import '../widgets/custom_latest_transaction_item.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  List<Transaction> latestTransactions = [];
  List<String> AccountIds = [];

  var userId;

  @override
  void initState() {
    super.initState();
    fetchUserTransactions();
  }

  Future<void> fetchUserTransactions() async {
    try {
      int? userId;
      final UserModel? user = await SharedUser().getCurrentUser();
      if (user != null) {
        print('User is not null');
        userId = user.id;
      }
      if (userId == null) {
        print('User ID is null');
      } else {
        final response =
            await HttpService.getWithAuth('/transactions/users/$userId');
        print('response is');
        print(response);
        List<String> bankAccountIDs =
            await SharedUser().retrieveBankAccountIds();
        print(bankAccountIDs.toString());

        if (response['message'] == 'Success') {
          print(response);

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

          transactions.sort((a, b) => b.time.compareTo(a.time));

          setState(() {
            latestTransactions = transactions;
          });
        }
      }
    } catch (error) {
      print('Error fetching user transactions: $error');
    }
  }

// Function to parse custom date-time format
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

  @override
  Widget build(BuildContext context) {
    return
        // Scaffold(
        //   appBar: AppBar(
        //     title: const Text('Transaction History'),
        //   ),

        // body:
        SafeArea(
      child: Container(
        // padding: EdgeInsets.only(top: 10),
        child: ListView(
          physics: PageScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            // SearchBar(hintText: "Search Transactions",textStyle: MaterialStatePropertyAll(whiteTextStyle),elevation: MaterialStatePropertyAll(1)),
            // Container(
            //   margin: EdgeInsets.only(top: 30, bottom: 10),
            //   child: Text("Your Transaction History",
            //       style: blackTextStyle.copyWith(fontSize: 22, fontWeight: bold),
            //       textAlign: TextAlign.center),
            // ),
            if (latestTransactions.isNotEmpty) ...[
              _buildMonthlySections(latestTransactions),
            ],
          ],
          // ),
        ),
      ),
    );
  }

  Widget _buildMonthlySections(List<Transaction> transactions) {
    Map<String, List<Transaction>> groupedTransactions = {};

    for (Transaction transaction in transactions) {
      String month = DateFormat('MMMM yyyy').format(
          DateFormat("MMMM dd, yyyy 'at' hh:mm a").parse(transaction.time));
      groupedTransactions.putIfAbsent(month, () => []);
      groupedTransactions[month]!.add(transaction);
    }

    // Sort the keys in descending order to display the latest months first
    List<String> sortedKeys = groupedTransactions.keys.toList();
    sortedKeys.sort((a, b) => DateFormat('MMMM yyyy')
        .parse(b)
        .compareTo(DateFormat('MMMM yyyy').parse(a)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedKeys.map((month) {
        return _buildSection(month, groupedTransactions[month]!);
      }).toList(),
    );
  }

  Widget _buildSection(String title, List<Transaction> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(fontWeight: semiBold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Column(
          children: transactions
              .map((transaction) => _buildTransactionItem(transaction))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return LatestTransactionItem(
      iconUrl: transaction.iconUrl,
      title: transaction.title,
      time: transaction.time,
      value: transaction.value,
    );
  }
}

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
