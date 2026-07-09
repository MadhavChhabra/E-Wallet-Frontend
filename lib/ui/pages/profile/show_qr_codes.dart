import 'package:flutter/material.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../models/user_model.dart';
import '../../../services/http_service.dart';
import '../../../utils/shared_user.dart';

class QRCodeGenerator extends StatefulWidget {
  const QRCodeGenerator({super.key});

  @override
  State<QRCodeGenerator> createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> {
  String qrData = '';
  List<String> fromBankAccountIbans = [];
  List<String> bankAccountNames = [];
  final PageController _pageController = PageController();
  String username = "";

  @override
  void initState() {
    super.initState();
    fetchUserBankAccounts();
    username = "${SharedUser().getFirstname()} ${SharedUser().getLastname()}";
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
        List<String> names = [];
        List<dynamic> dataList = response['data'];

        for (var item in dataList) {
          ibans.add(item['iban']);
          names.add(item['name']);
        }

        setState(() {
          fromBankAccountIbans = ibans;
          bankAccountNames = names;
        });
      }
    } catch (_) {
      // Leave the lists empty; the QR page shows nothing to scan.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your QR Code'),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey
                        .shade300, // Change this to your desired frame color
                    width: 1.0, // Change this to your desired frame thickness
                  ),
                ),
                child: ClipOval(
                  child: Image(
                    image: SharedUser().getProfileImage().image,
                    height: 30,
                    width: 30,
                  ),
                )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                username,
                style: blackTextStyle,
                textScaler: const TextScaler.linear(1.5),
              ),
            ),
          ],
        ),
        Container(
          height: 400,
          margin: const EdgeInsets.only(left: 20, right: 20, top: 50, bottom: 100),
          child: Card(
            color: const Color.fromARGB(255, 241, 241, 241),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: fromBankAccountIbans.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Center(
                              child: QrImageView(
                                data: fromBankAccountIbans[index],
                                version: QrVersions.auto,
                                size: 250.0,
                              ),
                            ),
                            const Text("Scan this QR Code to pay",
                                textScaler: TextScaler.linear(0.9)),
                            const SizedBox(height: 20,),
                            Text(bankAccountNames[index].toUpperCase(),
                                style: blackTextStyle,
                                textScaler: const TextScaler.linear(1.1)),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "IBAN: ${fromBankAccountIbans[index]}",
                              style: blackTextStyle,
                              
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
