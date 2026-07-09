import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_ewallet/models/wallet_account.dart';
import 'package:flutter_ewallet/services/wallet_account_service.dart';
import 'package:flutter_ewallet/utils/app_events.dart';
import 'package:flutter_ewallet/utils/card_display.dart';
import 'package:flutter_ewallet/utils/iban_utils.dart';
import 'package:flutter_ewallet/ui/pages/transfer/transfer_amount_card_page.dart';
import 'package:flutter_ewallet/ui/widgets/custom_button.dart';
import 'package:flutter_ewallet/ui/widgets/custom_dropdown_field.dart';
import 'package:flutter_ewallet/ui/widgets/custom_text_field.dart';
import 'package:flutter_ewallet/ui/widgets/saved_card_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../services/http_service.dart';

const double kCardHeight = 225;
const double kCardWidth = 356;

class CardPaymentPage extends StatefulWidget {
  const CardPaymentPage({super.key});

  @override
  State<CardPaymentPage> createState() => _CardPaymentPageState();
}

class _CardPaymentPageState extends State<CardPaymentPage>
    with SingleTickerProviderStateMixin {
  static const _customPayee = '__custom__';

  int? selectedCardIndex;
  List<Map<String, dynamic>> creditCards = [];
  List<PayeeOption> _recentPayees = [];
  String? _selectedPayeeKey;
  bool _useCustomIban = false;
  bool _loading = true;

  final TextEditingController toIbanController = TextEditingController();

  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    AppEvents.instance.cardsChanged.addListener(_reloadCards);
    _load();

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
    AppEvents.instance.cardsChanged.removeListener(_reloadCards);
    _animationController?.dispose();
    toIbanController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await Future.wait([_fetchCards(), _loadPayees()]);
    if (mounted) setState(() => _loading = false);
  }

  void _reloadCards() => _fetchCards();

  Future<void> _fetchCards() async {
    try {
      final response = await HttpService.getWithAuth('/cards');
      if (!mounted) return;
      if (response['message'] == 'Success') {
        final cardsData = List<Map<String, dynamic>>.from(response['data']);
        setState(() {
          creditCards = cardsData;
          if (selectedCardIndex != null &&
              selectedCardIndex! >= creditCards.length) {
            selectedCardIndex = null;
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => creditCards = []);
    }
  }

  Future<void> _loadPayees() async {
    try {
      final payees = await WalletAccountService.instance.recentPayees();
      if (mounted) setState(() => _recentPayees = payees);
    } catch (_) {
      // Optional list.
    }
  }

  List<DropdownMenuItem<String>> _payeeItems() {
    final items = _recentPayees
        .map((p) => DropdownMenuItem(
              value: p.iban,
              child: Text(p.label),
            ))
        .toList();
    items.add(const DropdownMenuItem(
      value: _customPayee,
      child: Text('Enter IBAN manually'),
    ));
    return items;
  }

  String? _resolveToIban() {
    if (_useCustomIban || _selectedPayeeKey == _customPayee) {
      return extractIban(toIbanController.text) ?? toIbanController.text.trim();
    }
    return _selectedPayeeKey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Pay with card')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 225, 211, 255),
                    Color.fromARGB(255, 196, 238, 255),
                    Color.fromARGB(255, 241, 194, 255),
                  ],
                ),
              ),
              child: creditCards.isEmpty
                  ? Center(
                      child: Text(
                        'Add a card first from the Cards tab (+).',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height - 300,
                            width: MediaQuery.of(context).size.width,
                            child: CarouselSlider.builder(
                              itemCount: creditCards.length,
                              itemBuilder: (context, index, realIndex) {
                                final cardData = creditCards[index];
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => selectedCardIndex = index),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: selectedCardIndex == index
                                            ? Colors.blue
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: SavedCardWidget(
                                      cardHolderName:
                                          CardDisplay.holder(cardData),
                                      maskedNumber:
                                          CardDisplay.number(cardData),
                                      expiryDate:
                                          CardDisplay.expiry(cardData),
                                      brand: cardData['brand']?.toString(),
                                      height: kCardHeight,
                                      width: kCardWidth,
                                    ),
                                  ),
                                );
                              },
                              options: CarouselOptions(
                                height: kCardHeight,
                                aspectRatio: kCardWidth / kCardHeight,
                                viewportFraction: 0.8,
                                enableInfiniteScroll: false,
                                enlargeCenterPage: true,
                                enlargeStrategy: CenterPageEnlargeStrategy.scale,
                                onPageChanged: (index, reason) {
                                  setState(() => selectedCardIndex = index);
                                },
                              ),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _animationController!,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                  0,
                                  MediaQuery.of(context).size.height *
                                      _animation!.value,
                                ),
                                child: child,
                              );
                            },
                            child: Container(
                              height: _useCustomIban ? 260 : 220,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(40),
                                  topRight: Radius.circular(40),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: CustomDropDownFieldButton<String>(
                                      title: 'Pay to',
                                      value: _selectedPayeeKey,
                                      items: _payeeItems(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedPayeeKey = value;
                                          _useCustomIban = value == _customPayee;
                                          if (!_useCustomIban && value != null) {
                                            toIbanController.text = value;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  if (_useCustomIban) ...[
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: CustomTextField(
                                        title: 'Recipient IBAN',
                                        hintText: 'Paste or type IBAN',
                                        controller: toIbanController,
                                      ),
                                    ),
                                  ],
                                  if (selectedCardIndex != null)
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: CustomFilledButton(
                                        onPressed: () {
                                          if (selectedCardIndex == null) {
                                            Fluttertoast.showToast(
                                                msg: 'Select a card first.');
                                            return;
                                          }
                                          final toIban = _resolveToIban();
                                          if (toIban == null ||
                                              toIban.isEmpty) {
                                            Fluttertoast.showToast(
                                                msg:
                                                    'Choose or enter a recipient.');
                                            return;
                                          }
                                          final selectedCard =
                                              creditCards[selectedCardIndex!];
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  TransferCardAmountPage(
                                                toIban: toIban,
                                                cardNumber: CardDisplay.number(
                                                    selectedCard),
                                                expiryDate: CardDisplay.expiry(
                                                    selectedCard),
                                                cardHolderName:
                                                    CardDisplay.holder(
                                                        selectedCard),
                                                cvv: CardDisplay.cvv(
                                                    selectedCard),
                                              ),
                                            ),
                                          );
                                        },
                                        title: 'Enter amount',
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
    );
  }
}
