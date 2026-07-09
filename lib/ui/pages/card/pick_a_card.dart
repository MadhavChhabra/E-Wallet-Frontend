
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_ewallet/utils/card_display.dart';
import 'package:flutter_ewallet/utils/theme.dart';

import '../../../services/http_service.dart';

const double kCardHeight = 225;
const double kCardWidth = 356;

const double kSpaceBetweenCard = 24;
const double kSpaceBetweenUnselectCard = 32;
const double kSpaceUnselectedCardToTop = 320;

const Duration kAnimationDuration = Duration(milliseconds: 245);

class SelectCard extends StatefulWidget {
  const SelectCard({
    Key? key,
    this.space = kSpaceBetweenCard,
  }) : super(key: key);

  final double space;

  @override
  State<SelectCard> createState() => _SelectCardState();
}

class _SelectCardState extends State<SelectCard> {
  int? selectedCardIndex;

  List<CreditCard> creditCards = [];

  @override
  void initState() {
    super.initState();
    _fetchDataFromUrl();
  }

  void _fetchDataFromUrl() async {
    try {
      final response =
          await HttpService.getWithAuth('/cards');
      if (response['message'] == 'Success') {
        final List<Map<String, dynamic>> cardsData =
            List<Map<String, dynamic>>.from(response['data']);

        setState(() {
          creditCards = cardsData.map((cardData) {
            return CreditCard(
              cardData: cardData,
              backgroundImageIndex: cardsData.indexOf(cardData),
              onTap: () {
                setState(() {
                  selectedCardIndex = cardsData.indexOf(cardData);
                });
              },
              isSelected: selectedCardIndex == cardsData.indexOf(cardData),
            );
          }).toList();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (_) {
      // Leave the card list empty; the UI shows the empty state.
    }
  }

  double _getCardTopPosititoned(int index, isSelected) {
    if (selectedCardIndex != null) {
      if (isSelected) {
        return widget.space;
      } else {
        /// Space from top to place put unselect cards.
        return kSpaceUnselectedCardToTop +
            toUnselectedCardPositionIndex(index) * kSpaceBetweenUnselectCard;
      }
    } else {
      /// Top first emptySpace + CardSpace + emptySpace + ...
      return widget.space + index * kCardHeight + index * widget.space;
    }
  }

  double _getCardScale(int index, isSelected) {
    if (selectedCardIndex != null) {
      if (isSelected) {
        return 1.0;
      } else {
        int totalUnselectCard = creditCards.length - 1;
        return 1.0 -
            (totalUnselectCard - toUnselectedCardPositionIndex(index) - 1) *
                0.05;
      }
    } else {
      return 1.0;
    }
  }

  void unSelectCard() {
    setState(() {
      selectedCardIndex = null;
    });
  }

  int toUnselectedCardPositionIndex(int indexInAllList) {
    if (selectedCardIndex != null) {
      if (indexInAllList < selectedCardIndex!) {
        return indexInAllList;
      } else {
        return indexInAllList - 1;
      }
    } else {
      throw 'Wrong usage';
    }
  }

  double totalHeightTotalCard() {
    if (selectedCardIndex == null) {
      final totalCard = creditCards.length;
      return widget.space * (totalCard + 1) + kCardHeight * totalCard;
    } else {
      return kSpaceUnselectedCardToTop +
          kCardHeight +
          (creditCards.length - 2) * kSpaceBetweenUnselectCard +
          kSpaceBetweenCard;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cards'),
      ),
      body: creditCards.isEmpty
          ? Center(
              child: Text(
                'No saved cards yet. Tap + to add one.',
                style: greyTextStyle.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            )
          : SizedBox.expand(
        child: SingleChildScrollView(
          child: Stack(alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: kAnimationDuration,
                height: totalHeightTotalCard(),
                width: mediaQuery.size.width,
              ),
              for (int i = 0; i < creditCards.length; i++)
                AnimatedPositioned(
                  top: _getCardTopPosititoned(i, i == selectedCardIndex),
                  duration: kAnimationDuration,
                  child: AnimatedScale(
                    scale: _getCardScale(i, i == selectedCardIndex),
                    duration: kAnimationDuration,
                    child: GestureDetector(
                      onTap: creditCards[i].onTap,
                      child: creditCards[i],
                    ),
                  ),
                ),
              if (selectedCardIndex != null)
                Positioned.fill(
                    child: GestureDetector(
                  onVerticalDragEnd: (_) {
                    unSelectCard();
                  },
                  onVerticalDragStart: (_) {
                    unSelectCard();
                  },
                ))
            ],
          ),
        ),
      ),
    );
  }
}

class CreditCard extends StatelessWidget {
  const CreditCard({
    Key? key,
    required this.cardData,
    required this.onTap,
    required this.backgroundImageIndex,
    required bool isSelected,
  }) : super(key: key);

  final Map<String, dynamic> cardData;
  final VoidCallback onTap;
  final int backgroundImageIndex;

  @override
  Widget build(BuildContext context) {
    final List<String> backgroundImages = [
      'assets/bg4.jpg',
      // 'assets/bg5.jpg',
      'assets/bg6.jpg',
      'assets/bg7.jpg',
      'assets/bg8.jpg',
      'assets/bg9.jpg',
      // Add more background images as needed
    ];

    // Determine the background image path based on the index
    final String backgroundImagePath =
        backgroundImages[backgroundImageIndex % backgroundImages.length];

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: CreditCardWidget(
          cardNumber: CardDisplay.number(cardData),
          expiryDate: CardDisplay.expiry(cardData),
          cardHolderName: CardDisplay.holder(cardData),
          cvvCode: CardDisplay.cvv(cardData),
          showBackView: false,
          isSwipeGestureEnabled: false, enableFloatingCard: true,isHolderNameVisible: true,
          height: kCardHeight,
          width: kCardWidth,
          backgroundImage: backgroundImagePath,
          // cardBgColor: _getColorFromHex(cardData['backgroundColor']),
          onCreditCardWidgetChange: (_) {},
        ),
      ),
    );
  }
}
