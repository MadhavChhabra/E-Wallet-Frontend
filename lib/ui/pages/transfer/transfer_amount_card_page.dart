import 'package:flutter/material.dart';
import 'package:flutter_ewallet/services/http_service.dart';
import 'package:flutter_ewallet/ui/pages/transfer/loading_card.dart';
import 'package:flutter_ewallet/ui/pages/transfer/transfer_success_card.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/custom_input_pin_button.dart';
import 'package:flutter_ewallet/utils/shared_user.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:intl/intl.dart';

import '../../../models/user_model.dart';

class TransferCardAmountPage extends StatefulWidget {
  final String cardNumber;
  final String expiryDate;
  final String CardHolderName;
  final String CVV;
  final String toIban;
  // final String description;

  const TransferCardAmountPage({
    Key? key,
    required this.toIban,
    required this.cardNumber,
    required this.expiryDate,
    required this.CardHolderName,
    required this.CVV,
    // required this.description,
  }) : super(key: key);

  @override
  State<TransferCardAmountPage> createState() => _TransferCardAmountPageState();
}

class _TransferCardAmountPageState extends State<TransferCardAmountPage> {
  final TextEditingController amountController =
      TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();

    amountController.addListener(
      () {
        final text = amountController.text;
        final number = int.tryParse(text.replaceAll(RegExp(r'[.,]'), ''));

        if (number != null) {
          final formattedText = number.toString();
          setState(() {
            amountController.value = amountController.value.copyWith(
              text: formattedText,
              selection: TextSelection.collapsed(offset: formattedText.length),
            );
          });
        }
      },
    );
  }

  Future<void> sendTransferData(
    String CardHolderName,
    String toIban,
    String amount,
    String description,
    String CVV,
    String CardNumber,
    String Expiry,
  ) async {
    int? userId;
    final UserModel? user = await SharedUser().getCurrentUser();
    if (user != null) {
      print('User is not null');
      userId = user.id;
    }
    var now = DateTime.now().toUtc();
    String formattedTime = DateFormat("dd.MM.yyyy HH:mm:ss").format(now);

    final transferData = {
      'cardNumber': CardNumber,
      'expiryDate': Expiry,
      'cvv': CVV,
      'toBankAccountiban': toIban,
      'amount': amount,
      'cardHolderName': CardHolderName,
      'description': description,
      'userID': userId,
      'createdAt': formattedTime
    };

    try {
      final response = await HttpService.postWithAuth(
          '/debitCards/transaction', transferData);
      print('amount transfer response is');
      print(response);

      if (response['message'] == 'Success') {
        // If successful, navigate to success page
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context)=> LoadingCard()));
      } else {
        // Handle other status codes here
        print('Failed to send transfer data. Status code: $response');
      }
    } catch (error) {
      // Handle any errors that occur during the process
      print('Error sending transfer data: $error');
    }
  }

  addAmount(String number) {
    if (amountController.text == '0') {
      amountController.text = '';
    }
    setState(() {
      amountController.text = amountController.text + number;
    });
  }

  deleteAmount() {
    if (amountController.text.isNotEmpty) {
      setState(() {
        amountController.text = amountController.text
            .substring(0, amountController.text.length - 1);
        if (amountController.text == '') {
          amountController.text = '0';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackgroundColor,
      body:Container(
        padding: EdgeInsets.only(top: 80,left: 76,right: 55),
        alignment: Alignment.center,
        child: ListView(
          
          children: [
            Center(
              child: Text(
                'Total Amount',
                style: whiteTextStyle.copyWith(
                  fontSize: 20,
                  fontWeight: semiBold,
                ),
              ),
            ),
            const SizedBox(
              height: 65,
            ),
            Align(
              child: SizedBox(
                width: 200,
                child: TextFormField(
                  controller: amountController,
                  cursorColor: greyColor,
                  enabled: false,
                  style: whiteTextStyle.copyWith(
                    fontSize: 32,
                    fontWeight: medium,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Text(
                      '₹',
                      style: whiteTextStyle.copyWith(
                        fontSize: 32,
                        fontWeight: medium,
                      ),
                    ),
                    disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: greyColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 66,
            ),
            Wrap(
              spacing: 40,
              runSpacing: 40,
              children: [
                CustomInputPinButton(
                  text: '1',
                  onTap: () {
                    addAmount('1');
                  },
                ),
                CustomInputPinButton(
                  text: '2',
                  onTap: () {
                    addAmount('2');
                  },
                ),
                CustomInputPinButton(
                  text: '3',
                  onTap: () {
                    addAmount('3');
                  },
                ),
                CustomInputPinButton(
                  text: '4',
                  onTap: () {
                    addAmount('4');
                  },
                ),
                CustomInputPinButton(
                  text: '5',
                  onTap: () {
                    addAmount('5');
                  },
                ),
                CustomInputPinButton(
                  text: '6',
                  onTap: () {
                    addAmount('6');
                  },
                ),
                CustomInputPinButton(
                  text: '7',
                  onTap: () {
                    addAmount('7');
                  },
                ),
                CustomInputPinButton(
                  text: '8',
                  onTap: () {
                    addAmount('8');
                  },
                ),
                CustomInputPinButton(
                  text: '9',
                  onTap: () {
                    addAmount('9');
                  },
                ),
                const SizedBox(
                  height: 60,
                  width: 60,
                ),
                CustomInputPinButton(
                  text: '0',
                  onTap: () {
                    addAmount('0');
                  },
                ),
                GestureDetector(
                  onTap: () {
                    deleteAmount();
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: numberBackgroundColor,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_back,
                        color: whiteColor,
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            CustomFilledButton(
              title: 'Checkout Now',
              onPressed: () async {
                await sendTransferData(
                    widget.CardHolderName,
                    widget.toIban,
                    amountController.text,
                    "Card Transfer",
                    widget.CVV,
                    widget.cardNumber,
                    widget.expiryDate);
              },
            ),
            const SizedBox(
              height: 25,
            ),
            CustomTextButton(
              title: 'Term & Conditions',
              onPressed: () {},
            ),
            const SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }

  // final Uri _url = Uri.parse('https://demo.midtrans.com/');

  // Future<void> _launchUrl() async {
  //   if (await Navigator.pushNamed(context, '/pin') == true) {
  //     Navigator.pushNamedAndRemoveUntil(
  //         context, '/transfer-success', (route) => false);
  //   }
  // }
}
