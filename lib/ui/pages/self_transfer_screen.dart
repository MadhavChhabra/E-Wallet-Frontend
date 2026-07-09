import 'package:flutter/material.dart';
import 'package:flutter_ewallet/services/http_service.dart';
import 'package:flutter_ewallet/ui/pages/transfer/transfer_amount_page.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/custom_dropdown_field.dart';
import 'package:flutter_ewallet/ui/widgets/custom_text_field.dart';

import '../../../utils/shared_user.dart';
import '../../models/user_model.dart';

class SelfTransferPage extends StatefulWidget {
  const SelfTransferPage({super.key});

  @override
  State<SelfTransferPage> createState() => _SelfTransferPageState();
}

class _SelfTransferPageState extends State<SelfTransferPage> {
  String? selectedFromIban;
  String? selectedToIban;
  List<String> fromBankAccountIbans = [];

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
        });
      }
    } catch (_) {
      // Leave the account list empty; the UI shows the error state.
    }
  }

  final TextEditingController fromIbanController =
      TextEditingController(text: '');
  final TextEditingController toIbanController =
      TextEditingController(text: '');

  final TextEditingController amountController =
      TextEditingController(text: '');
  final TextEditingController descriptionController =
      TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          Image.asset('assets/file.png', height: 331),
          const SizedBox(
            height: 20,
          ),

          CustomDropDownFieldButton<String>(
            title: 'Transfer from IBAN',
            value: selectedFromIban,
            items: fromBankAccountIbans.map((String iban) {
              return DropdownMenuItem<String>(
                value: iban,
                child: Text(iban),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedFromIban = newValue;
              });
            },
          ),
          const SizedBox(
            height: 20,
          ),
          CustomDropDownFieldButton<String>(
            title: 'Transfer to IBAN',
            value: selectedToIban,
            items: fromBankAccountIbans.map((String iban) {
              return DropdownMenuItem<String>(
                value: iban,
                child: Text(iban),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedToIban = newValue;
              });
            },
          ),

          const SizedBox(height: 20),
          CustomTextField(
            title: 'Description',
            hintText: 'Enter description',
            controller: descriptionController,
          ),
          // buildRecentUsers(),
          // buildResult(),
          const SizedBox(
            height: 40,
          ),
          CustomFilledButton(
            title: 'Continue',
            onPressed: () async {
              // Navigate to transfer-amount route with IBAN and description data
              if (selectedFromIban != null) {
                final routerPin = Navigator.pushNamed(context, '/pin');
                if (await routerPin == true) {
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransferAmountPage(
                        fromIban: selectedFromIban!,
                        toIban: toIbanController.text,
                        description: descriptionController.text,
                      ),
                    ),
                  );
                }
              } else {
                // Handle case when no IBAN is selected
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Please select your IBAN.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    });
              }
            },
          ),
        ],
      ),
    );
  }
}
