import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_ewallet/ui/pages/transfer/transfer_amount_card_page.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../services/http_service.dart';
import '../../../utils/shared_user.dart';
import '../../models/user_model.dart';
import '../widgets/custom_text_field.dart';

const double kCardHeight = 225;
const double kCardWidth = 356;
const double kRaisedHeight = 10.0; // Adjust this value as needed

class CardPaymentPage extends StatefulWidget {
  const CardPaymentPage({Key? key}) : super(key: key);

  @override
  State<CardPaymentPage> createState() => _CardPaymentPageState();
}

class _CardPaymentPageState extends State<CardPaymentPage>
    with SingleTickerProviderStateMixin {
  int? selectedCardIndex;
  List<Map<String, dynamic>> creditCards = [];
  final TextEditingController toIbanController =
      TextEditingController(text: '');

  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _fetchDataFromUrl();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOut,
    ));

    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _fetchDataFromUrl();
  // }

  Future<void> _fetchDataFromUrl() async {
     int? userId;
      final UserModel? user = await SharedUser().getCurrentUser();
      if (user != null) {
        print('User is not null');
        userId = user.id;
      }

    try {
      final response =
          await HttpService.getWithAuth('/debitCards/user/$userId');
      if (response['message'] == 'Success') {
        final List<Map<String, dynamic>> cardsData =
            List<Map<String, dynamic>>.from(response['data']);
        setState(() {
          creditCards = cardsData;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Select Card'),
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
              Color.fromARGB(255, 225, 211, 255),
              Color.fromARGB(255, 196, 238, 255),
              Color.fromARGB(255, 241, 194, 255)
            ])),
        child: SingleChildScrollView(
          child: Column(
            verticalDirection: VerticalDirection.down,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height - 300,
                width: MediaQuery.of(context).size.width,
                // color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: CarouselSlider.builder(
                        itemCount: creditCards.length,
                        itemBuilder: (context, index, realIndex) {
                          final cardData = creditCards[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCardIndex = index;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedCardIndex == index
                                      ? Colors.blue
                                      : Colors.transparent,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: selectedCardIndex == index
                                    ? [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: CreditCardWidget(
                                cardNumber: cardData['cardNumber'],
                                expiryDate: cardData['expiryDate'],
                                cardHolderName: cardData['cardHolderName'],
                                cvvCode: cardData['cvv'],
                                showBackView: false,
                                isSwipeGestureEnabled: false,
                                // enableFloatingCard: true,
                                // isHolderNameVisible: true,    
                                height: kCardHeight,
                                width: kCardWidth,
                                onCreditCardWidgetChange: (_) {},
                              ),
                            ),
                          );
                        },
                        options: CarouselOptions(
                          height: kCardHeight,
                          aspectRatio: kCardWidth / kCardHeight,
                          viewportFraction: 0.8,
                          initialPage: 0,
                          enableInfiniteScroll: false,
                          reverse: false,
                          enlargeCenterPage: true,enlargeStrategy: CenterPageEnlargeStrategy.scale,
                          onPageChanged: (index, reason) {
                            setState(() {
                              selectedCardIndex = index;
                            });
                          },
                        ),
                      ),
                    ),
                    //  Container(
                    //   margin: EdgeInsets.symmetric(horizontal: 20),
                    //    child: CustomTextField(
                    //     title: 'Enter Receiver\'s IBAN',
                    //     hintText: 'IBAN',
                    //     controller: toIbanController,
                    //                    ),
                    //  ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _animationController!,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0,
                        MediaQuery.of(context).size.height * _animation!.value),
                    child: child,
                  );
                },
                child: Container(
                  // borderOnForeground: true,
                  margin: const EdgeInsets.all(0),
                  child: Container(
                    height: 195,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                              top: 20, left: 20, right: 20, bottom: 15),
                          child: CustomTextField(
                            title: 'Enter Receiver\'s IBAN',
                            hintText: 'IBAN',
                            controller: toIbanController,
                          ),
                        ),
                        if (selectedCardIndex != null)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CustomFilledButton(
                              onPressed: () {
                                if (selectedCardIndex != null) {
                                  final selectedCard =
                                      creditCards[selectedCardIndex!];
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => TransferCardAmountPage(
                                      toIban: toIbanController.text,
                                      cardNumber: selectedCard['cardNumber'],
                                      expiryDate: selectedCard['expiryDate'],
                                      CardHolderName:
                                          selectedCard['cardHolderName'],
                                      CVV: selectedCard['cvv'],
                                    ),
                                  ));
                                } else {
                                  
                                              Fluttertoast.showToast(msg: 'Please select a card first.');

                                }
                              },
                              title: 'Select this Card for Payment',
                            ),
                          ),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void _showBottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Container(
  //         padding: EdgeInsets.all(16),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.only(
  //             topLeft: Radius.circular(20),
  //             topRight: Radius.circular(20),
  //           ),
  //         ),
  //         child: Wrap(
  //           children: <Widget>[
  //             CustomTextField(
  //               title: 'Enter Receiver\'s IBAN',
  //               hintText: 'IBAN',
  //               controller: toIbanController,
  //             ),
  //             // Add other widgets or buttons as needed
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}
