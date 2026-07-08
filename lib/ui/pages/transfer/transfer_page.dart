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
  const TransferPage({Key? key, this.receiverIban}) : super(key: key);

  @override
  _TransferPageState createState() => _TransferPageState();
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
      } else {
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
    } catch (error) {
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
    final receiverIban = widget.receiverIban; // Get the argument for clarity

    if (receiverIban != null) {
      toIbanController.text = receiverIban;
    } else {
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
          // DropdownButtonFormField<String>(
          //   decoration: const InputDecoration(
          //     labelText: 'Select Your IBAN',
          //     border: OutlineInputBorder(),
          //   ),
          //   value: selectedFromIban,
          //   onChanged: (String? newValue) {
          //     setState(() {
          //       selectedFromIban = newValue;
          //     });
          //   },
          //   items: fromBankAccountIbans.map((String iban) {
          //     return DropdownMenuItem<String>(
          //       value: iban,
          //       child: Text(iban),
          //     );
          //   }).toList(),
          // ),
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
              // Navigate to transfer-amount route with IBAN and description data
              if (selectedFromIban != null) {
  
                  final routerPin = Navigator.pushNamed(context, '/pin');
                  if (await routerPin == true) {
                    // ignore: use_build_context_synchronously
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

//   Widget buildResult() {
//     return Container(
//       margin: const EdgeInsets.only(top: 40),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Result',
//             style: blackTextStyle.copyWith(
//               fontWeight: semiBold,
//             ),
//           ),
//           const SizedBox(
//             height: 14,
//           ),
//           const Wrap(
//             spacing: 17,
//             runSpacing: 17,
//             children: [
//               CustomTransferResultItem(
//                 imageUrl: 'assets/img_friend1.png',
//                 name: 'Yoona Jie',
//                 username: '@yoenna',
//                 isVerified: true,
//               ),
//               CustomTransferResultItem(
//                 imageUrl: 'assets/img_friend2.png',
//                 name: 'Elenna Jie',
//                 username: '@elenna',
//                 isVerified: true,
//                 isSelected: true,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
}
