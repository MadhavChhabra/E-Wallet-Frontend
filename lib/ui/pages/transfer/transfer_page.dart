import 'package:flutter/material.dart';
import 'package:flutter_ewallet/services/http_service.dart';
import 'package:flutter_ewallet/ui/pages/transfer/transfer_amount_page.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/custom_dropdown_field.dart';
import 'package:flutter_ewallet/ui/widgets/custom_text_field.dart';

import '../../../models/user_model.dart';
import '../../../utils/shared_user.dart';

class TransferPage extends StatefulWidget {
  final String? receiverIban;
  const TransferPage({super.key, this.receiverIban});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  String? selectedFromIban;
  List<String> fromBankAccountIbans = [];

  @override
  void initState() {
    super.initState();
    fetchUserBankAccounts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.receiverIban != null) {
        toIbanController.text = widget.receiverIban!;
      }
    });
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
      // Leave the account list empty; the dropdown simply has no options.
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

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final receiverIban = widget.receiverIban; // Get the argument for clarity

    if (receiverIban != null) {
      toIbanController.text = receiverIban;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          Image.asset('assets/bank_transfer.png', height: 331),

          const SizedBox(
            height: 20,
          ),
          CustomDropDownFieldButton<String>(
            title: 'Send Via',
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
          const SizedBox(height: 15),

          CustomTextField(
            title: 'Enter Receiver\'s IBAN',
            hintText: 'IBAN',
            controller: toIbanController,
          ),
          const SizedBox(height: 15),
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
              if (selectedFromIban == null) {
                _showError('Please select your source account.');
                return;
              }
              final toIban = toIbanController.text.trim();
              if (toIban.isEmpty) {
                _showError('Please enter the receiver\'s IBAN.');
                return;
              }
              if (selectedFromIban == toIban) {
                _showError('Source and destination must be different.');
                return;
              }
              final routerPin = Navigator.pushNamed(context, '/pin');
              if (await routerPin == true) {
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransferAmountPage(
                      fromIban: selectedFromIban!,
                      toIban: toIban,
                      description: descriptionController.text,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
