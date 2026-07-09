
import 'package:flutter/material.dart';
import 'package:flutter_ewallet/utils/app_events.dart';
import 'package:flutter_ewallet/utils/card_display.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:flutter_ewallet/ui/widgets/saved_card_widget.dart';

import '../../../services/http_service.dart';

const double kCardHeight = 225;
const double kCardWidth = 356;

const double kSpaceBetweenCard = 24;
const double kSpaceBetweenUnselectCard = 32;
const double kSpaceUnselectedCardToTop = 320;

const Duration kAnimationDuration = Duration(milliseconds: 245);

class SelectCard extends StatefulWidget {
  const SelectCard({
    super.key,
    this.space = kSpaceBetweenCard,
  });

  final double space;

  @override
  State<SelectCard> createState() => _SelectCardState();
}

class _SelectCardState extends State<SelectCard> {
  int? selectedCardIndex;
  List<_SavedCardEntry> creditCards = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    AppEvents.instance.cardsChanged.addListener(_fetchDataFromUrl);
    _fetchDataFromUrl();
  }

  @override
  void dispose() {
    AppEvents.instance.cardsChanged.removeListener(_fetchDataFromUrl);
    super.dispose();
  }

  Future<void> _fetchDataFromUrl() async {
    try {
      final response = await HttpService.getWithAuth('/cards');
      if (!mounted) return;
      if (response['message'] == 'Success') {
        final List<Map<String, dynamic>> cardsData =
            List<Map<String, dynamic>>.from(response['data']);

        setState(() {
          creditCards = cardsData.asMap().entries.map((entry) {
            final index = entry.key;
            final cardData = entry.value;
            return _SavedCardEntry(
              cardData: cardData,
              backgroundIndex: index,
              onTap: () => setState(() => selectedCardIndex = index),
            );
          }).toList();
          _loading = false;
          if (selectedCardIndex != null &&
              selectedCardIndex! >= creditCards.length) {
            selectedCardIndex = null;
          }
        });
      } else {
        setState(() {
          creditCards = [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          creditCards = [];
          _loading = false;
        });
      }
    }
  }

  double _getCardTopPosititoned(int index, isSelected) {
    if (selectedCardIndex != null) {
      if (isSelected) {
        return widget.space;
      } else {
        return kSpaceUnselectedCardToTop +
            toUnselectedCardPositionIndex(index) * kSpaceBetweenUnselectCard;
      }
    } else {
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
        title: const Text('Your cards'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : creditCards.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No saved cards yet. Tap + to add one.',
                      style: greyTextStyle.copyWith(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SizedBox.expand(
                  child: SingleChildScrollView(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedContainer(
                          duration: kAnimationDuration,
                          height: totalHeightTotalCard(),
                          width: mediaQuery.size.width,
                        ),
                        for (int i = 0; i < creditCards.length; i++)
                          AnimatedPositioned(
                            top: _getCardTopPosititoned(
                                i, i == selectedCardIndex),
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
                              onVerticalDragEnd: (_) => unSelectCard(),
                              onVerticalDragStart: (_) => unSelectCard(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _SavedCardEntry extends StatelessWidget {
  const _SavedCardEntry({
    required this.cardData,
    required this.onTap,
    required this.backgroundIndex,
  });

  final Map<String, dynamic> cardData;
  final VoidCallback onTap;
  final int backgroundIndex;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: SavedCardWidget(
          cardHolderName: CardDisplay.holder(cardData),
          maskedNumber: CardDisplay.number(cardData),
          expiryDate: CardDisplay.expiry(cardData),
          brand: cardData['brand']?.toString(),
          height: kCardHeight,
          width: kCardWidth,
        ),
      ),
    );
  }
}
