import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_ewallet/services/http_service.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/custom_dropdown_field.dart';
import 'package:flutter_ewallet/utils/shared_user.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../models/user_model.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AddCardPageState();
}

class AddCardPageState extends State<AddCardPage> {
  List<String> fromBankAccountIbans = [];
  String? selectedFromIban;
  int BankAccountID = 0;

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final OutlineInputBorder border = OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(0.7),
      width: 2.0,
    ),
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchUserBankAccounts();
  }

  Future<void> fetchUserBankAccounts() async {
    try {
      int? userId;
      final UserModel? user = await SharedUser().getCurrentUser();
      if (user != null) {
        userId = user.id;
      }
      // Fetch IBANs list using user's id
      final response =
          await HttpService.getWithAuth('/bank-accounts/users/$userId');
      if (response['message'] == 'Success') {

        List<String> ibans = [];
        List<dynamic> dataList = response['data'];

        for (var item in dataList) {
          ibans.add(item['iban']);
        }

        setState(() {
          fromBankAccountIbans = ibans;
          // print(fromBankAccountIbans.toString());
        });
      }
    } catch (error) {
    }
  }

  Future<void> fetchBankAccountId(String iban) async {
    try {
      // Fetch IBANs list using user's id
      final response =
          await HttpService.getWithAuth('/bank-accounts/iban/$iban');
      if (response['message'] == 'Success') {

        int id = response['data']['id'];

        setState(() {
          BankAccountID = id;
        });
      }
    } catch (error) {
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Card'),
      ),
      resizeToAvoidBottomInset: false,
      body: Builder(
        builder: (BuildContext context) {
          return Container(
            decoration: const BoxDecoration(
                // image: DecorationImage(
                //   // image: const AssetImage('assets/bg-light.png'),
                //   fit: BoxFit.fill,
                // ),
                ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  CreditCardWidget(
                    enableFloatingCard: true,
                    cardNumber: cardNumber,
                    expiryDate: expiryDate,
                    cardHolderName: cardHolderName,
                    cvvCode: cvvCode,
                    // bankName: 'Axis Bank',
                    frontCardBorder: Border.all(color: Colors.grey),
                    backCardBorder: Border.all(color: Colors.grey),
                    showBackView: isCvvFocused,
                    obscureCardNumber: true,
                    obscureCardCvv: true,
                    isHolderNameVisible: true,
backgroundImage: "assets/bg8.jpg",
                    isSwipeGestureEnabled: true,
                    onCreditCardWidgetChange:
                        (CreditCardBrand creditCardBrand) {},
                    customCardTypeIcons: <CustomCardTypeIcon>[
                      CustomCardTypeIcon(
                        cardType: CardType.mastercard,
                        cardImage: Image.asset(
                          'assets/mastercard.png',
                          height: 48,
                          width: 48,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                        child: Column(
                          children: <Widget>[
                            CreditCardForm(
                              formKey: formKey,
                              obscureCvv: true,
                              obscureNumber: true,
                              cardNumber: cardNumber,
                              cvvCode: cvvCode,
                              isHolderNameVisible: true,
                              isCardNumberVisible: true,
                              isExpiryDateVisible: true,
                              cardHolderName: cardHolderName,
                              expiryDate: expiryDate,
                              inputConfiguration: const InputConfiguration(
                                cardNumberDecoration: InputDecoration(
                                  labelText: 'Number',
                                  hintText: 'XXXX XXXX XXXX XXXX',
                                ),
                                expiryDateDecoration: InputDecoration(
                                  labelText: 'Expired Date',
                                  hintText: 'XX/XX',
                                ),
                                cvvCodeDecoration: InputDecoration(
                                  labelText: 'CVV',
                                  hintText: 'XXX',
                                ),
                                cardHolderDecoration: InputDecoration(
                                  labelText: 'Card Holder',
                                ),
                              ),
                              onCreditCardModelChange: onCreditCardModelChange,
                            ),
                            const SizedBox(height: 20),
                            CustomDropDownFieldButton<String>(
                              title: "Select Your IBAN",
                              value: selectedFromIban,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedFromIban = newValue;
                                });
                              },
                              items: fromBankAccountIbans.map((String iban) {
                                return DropdownMenuItem<String>(
                                  value: iban,
                                  child: Text(iban),
                                );
                              }).toList(),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            GestureDetector(
                                onTap: () {
                                  _onValidate();
                                },
                                child: const CustomFilledButton(title: 'Save')),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onValidate() async {
    fetchBankAccountId(selectedFromIban.toString());

    int? userId;
    final UserModel? user = await SharedUser().getCurrentUser();
    if (user != null) {
      userId = user.id;
    }
    if (formKey.currentState?.validate() ?? false) {

      final cardData = {
        'cardHolderName': cardHolderName,
        'cardNumber': cardNumber,
        'expiryDate': expiryDate,
        'cvv': cvvCode,
        'bankAccountId': BankAccountID,
        'userId': userId.toString()
      };

      try {
        var response = await HttpService.postWithAuth('/cards', cardData);
        if (response['message'] == 'Success') {

          Fluttertoast.showToast(msg: 'Card created successfully!');

          Navigator.of(context).pop((route) => false);
        }

        // print('doing it');

        // Handle response accordingly
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error Occured');

        // Handle error
      }
    } else {
    }
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
