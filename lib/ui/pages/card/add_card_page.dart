import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_ewallet/models/wallet_account.dart';
import 'package:flutter_ewallet/services/http_service.dart';
import 'package:flutter_ewallet/services/wallet_account_service.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/custom_dropdown_field.dart';
import 'package:flutter_ewallet/utils/app_events.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AddCardPageState();
}

class AddCardPageState extends State<AddCardPage> {
  List<WalletAccount> _accounts = [];
  String? selectedFromIban;
  int bankAccountId = 0;

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
      final accounts =
          await WalletAccountService.instance.fetchAccounts(forceRefresh: true);
      if (!mounted) return;
      setState(() {
        _accounts = accounts;
        if (accounts.isNotEmpty && selectedFromIban == null) {
          selectedFromIban = accounts.first.iban;
          bankAccountId = accounts.first.id;
        }
      });
    } catch (_) {
      // Leave the account list empty; the dropdown simply has no options.
    }
  }

  Future<void> fetchBankAccountId(String iban) async {
    try {
      final response = await HttpService.getWithAuth('/bank-accounts/iban/$iban');
      if (response['message'] == 'Success') {
        final id = response['data']['id'];
        if (mounted) {
          setState(() {
            bankAccountId = id is int ? id : int.tryParse('$id') ?? 0;
          });
        }
      }
    } catch (_) {
      // Ignore; the id stays 0 and the backend rejects an invalid reference.
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
                              title: 'Link to wallet',
                              value: selectedFromIban,
                              onChanged: (String? newValue) async {
                                setState(() => selectedFromIban = newValue);
                                if (newValue != null) {
                                  await fetchBankAccountId(newValue);
                                }
                              },
                              items: _accounts.map((account) {
                                return DropdownMenuItem<String>(
                                  value: account.iban,
                                  child: Text(account.label),
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
    if (formKey.currentState?.validate() ?? false) {
      if (selectedFromIban != null) {
        await fetchBankAccountId(selectedFromIban!);
      }

      final cardData = {
        'cardHolderName': cardHolderName.trim(),
        'cardNumber': cardNumber.replaceAll(RegExp(r'\s+'), ''),
        'expiryDate': expiryDate,
        'cvv': cvvCode,
        if (bankAccountId > 0) 'bankAccountId': bankAccountId,
      };

      try {
        var response = await HttpService.postWithAuth('/cards', cardData);
        if (response['message'] == 'Success') {
          AppEvents.instance.notifyCardsChanged();
          Fluttertoast.showToast(msg: 'Card created successfully!');
          if (!mounted) return;
          Navigator.of(context).pop();
        } else {
          Fluttertoast.showToast(
              msg: response['message']?.toString() ?? 'Could not save card');
        }
      } catch (e) {
        Fluttertoast.showToast(
            msg: e.toString().replaceFirst('Exception: ', ''));
      }
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
