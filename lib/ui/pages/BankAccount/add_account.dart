import 'package:flutter/material.dart';
import 'package:flutter_ewallet/services/http_service.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/custom_text_field.dart';
import 'package:flutter_ewallet/utils/shared_user.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../models/user_model.dart';

class AddAccountPage extends StatefulWidget {
  const AddAccountPage({Key? key}) : super(key: key);

  @override
  _AddAccountPageState createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  final nameController = TextEditingController();
  final balanceController = TextEditingController();
  final ibanController = TextEditingController();
  final emailController = TextEditingController();

  bool validate() {
    return nameController.text.isNotEmpty &&
        balanceController.text.isNotEmpty &&
        ibanController.text.isNotEmpty &&
        emailController.text.isNotEmpty;
  }

  Future<void> saveBankAccount() async {
    if (validate()) {
       int? userId;
      final UserModel? user = await SharedUser().getCurrentUser();
      if (user != null) {
        userId = user.id;
      }
      // print('valid');
      final bankaccountData = {
        'name': nameController.text,
        'balance': balanceController.text,
        'iban': ibanController.text,
        'email': emailController.text,
        'userId': userId,
      };

      try {
        var response = await HttpService.postWithAuth('/bank-accounts', bankaccountData);
        if (response['message'] == 'Success') {

                                                          Fluttertoast.showToast(msg: 'Account created successfully!');


          Navigator.of(context).pop((route) => false);
        }

        // print('doing it');

        // Handle response accordingly
      } catch (e) {
                                                          Fluttertoast.showToast(msg: 'Error Occured');


        // Handle error
      }
    } else {
      // Show error message if validation fails
                                                          Fluttertoast.showToast(msg: 'Please Fill in all the fields');

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New BankAccount'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                              Image.asset('assets/add_bank.png', height: 331),
                              const SizedBox(height: 30,),
        
              CustomTextField(
                controller: nameController,
                title: 'Bank Account Name',
                keyboardType: TextInputType.name,
              ),
                          const SizedBox(height: 12),
        
              CustomTextField(
                controller: ibanController,
                title: 'IBAN',
              ),
                          const SizedBox(height: 12),
        
              CustomTextField(
                controller: balanceController,
                title: 'Balance',
                keyboardType: TextInputType.number,
              ),
                          const SizedBox(height: 12),
        
              CustomTextField(
                controller: emailController,
                title: 'Email Address',
              ),
              const SizedBox(height: 30),
              CustomFilledButton(
                onPressed: saveBankAccount,
                title: 'Save',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
