import 'package:flutter/material.dart';
import 'package:flutter_ewallet/services/card_service.dart';
import 'package:flutter_ewallet/utils/app_events.dart';
import 'package:flutter_ewallet/utils/card_display.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:flutter_ewallet/ui/widgets/saved_card_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../services/http_service.dart';

const double kCardHeight = 210;
const double kCardWidth = 340;

/// How much of each card peeks out below the one in front of it in the resting
/// (Samsung-Wallet style) stacked deck.
const double kCardPeek = 66;

/// Where the selected card rests once lifted, and where the rest tuck below it.
const double kTopPadding = 20;
const double kSelectedTop = 24;
const double kTuckedTop = 300;
const double kTuckedGap = 30;

const Duration kAnimationDuration = Duration(milliseconds: 320);

class SelectCard extends StatefulWidget {
  const SelectCard({super.key});

  @override
  State<SelectCard> createState() => _SelectCardState();
}

class _SelectCardState extends State<SelectCard> {
  int? selectedCardIndex;
  bool _flipped = false;
  List<Map<String, dynamic>> _cards = [];
  bool _loading = true;
  bool _deleting = false;

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
        final cardsData = List<Map<String, dynamic>>.from(response['data']);
        setState(() {
          _cards = cardsData;
          _loading = false;
          if (selectedCardIndex != null &&
              selectedCardIndex! >= _cards.length) {
            selectedCardIndex = null;
            _flipped = false;
          }
        });
      } else {
        setState(() {
          _cards = [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _cards = [];
          _loading = false;
        });
      }
    }
  }

  int? _cardId(Map<String, dynamic> card) {
    final id = card['id'];
    if (id is int) return id;
    return int.tryParse('$id');
  }

  Future<void> _deleteSelected() async {
    if (selectedCardIndex == null || _deleting) return;
    final card = _cards[selectedCardIndex!];
    final id = _cardId(card);
    if (id == null) return;

    final number = CardDisplay.number(card);
    final last4 =
        number.length >= 4 ? number.substring(number.length - 4) : number;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove card?'),
        content: Text(
          'Remove ${CardDisplay.holder(card)} ending $last4?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    final ok = await CardService.instance.deleteCard(id);
    if (!mounted) return;
    setState(() {
      _deleting = false;
      if (ok) {
        selectedCardIndex = null;
        _flipped = false;
      }
    });
    if (ok) {
      Fluttertoast.showToast(msg: 'Card removed');
      await _fetchDataFromUrl();
    } else {
      Fluttertoast.showToast(msg: 'Could not remove card');
    }
  }

  void _onTapCard(int index) {
    setState(() {
      if (selectedCardIndex == index) {
        // Tapping the already-lifted card flips it over.
        _flipped = !_flipped;
      } else {
        selectedCardIndex = index;
        _flipped = false;
      }
    });
  }

  void _unselect() {
    setState(() {
      selectedCardIndex = null;
      _flipped = false;
    });
  }

  /// Index of an unselected card within the tucked stack (0-based, skipping the
  /// selected card).
  int _tuckedPositionIndex(int indexInAllList) {
    if (indexInAllList < selectedCardIndex!) return indexInAllList;
    return indexInAllList - 1;
  }

  double _cardTop(int index, bool isSelected) {
    if (selectedCardIndex != null) {
      if (isSelected) return kSelectedTop;
      return kTuckedTop + _tuckedPositionIndex(index) * kTuckedGap;
    }
    // Resting deck: each card overlaps the one before it.
    return kTopPadding + index * kCardPeek;
  }

  double _cardScale(int index, bool isSelected) {
    if (selectedCardIndex != null && !isSelected) {
      // Tucked cards shrink slightly with depth.
      return 0.9 - _tuckedPositionIndex(index) * 0.015;
    }
    return 1.0;
  }

  double _totalHeight() {
    final n = _cards.length;
    if (selectedCardIndex == null) {
      return kTopPadding + (n - 1) * kCardPeek + kCardHeight + 40;
    }
    const selectedExtent = kSelectedTop + kCardHeight;
    final tuckedExtent =
        kTuckedTop + (n - 2).clamp(0, n) * kTuckedGap + kCardHeight;
    return (selectedExtent > tuckedExtent ? selectedExtent : tuckedExtent) + 40;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    // Keep the cards from spanning the full width — leaves breathing room and
    // makes the deck read as a stack of distinct cards.
    final cardWidth = kCardWidth < mediaQuery.size.width - 40
        ? kCardWidth
        : mediaQuery.size.width - 40;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your cards'),
      ),
      bottomNavigationBar: selectedCardIndex != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: FilledButton.icon(
                  onPressed: _deleting ? null : _deleteSelected,
                  icon: _deleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline),
                  label: Text(_deleting ? 'Removing…' : 'Remove card'),
                  style: FilledButton.styleFrom(
                    backgroundColor: redColor,
                    foregroundColor: whiteColor,
                  ),
                ),
              ),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : _cards.isEmpty
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
                      alignment: Alignment.topCenter,
                      children: [
                        AnimatedContainer(
                          duration: kAnimationDuration,
                          height: _totalHeight(),
                          width: mediaQuery.size.width,
                        ),
                        // Tap/drag empty space to dismiss the lifted card. Sits
                        // below the cards so they still receive their own taps.
                        if (selectedCardIndex != null)
                          Positioned.fill(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: _unselect,
                              onVerticalDragStart: (_) => _unselect(),
                            ),
                          ),
                        for (int i = 0; i < _cards.length; i++)
                          AnimatedPositioned(
                            top: _cardTop(i, i == selectedCardIndex),
                            duration: kAnimationDuration,
                            curve: Curves.easeOutCubic,
                            child: AnimatedScale(
                              scale: _cardScale(i, i == selectedCardIndex),
                              duration: kAnimationDuration,
                              curve: Curves.easeOutCubic,
                              child: GestureDetector(
                                onTap: () => _onTapCard(i),
                                child: _buildCard(i, cardWidth),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildCard(int index, double cardWidth) {
    final card = _cards[index];
    final palette =
        CardPalette.forCard(card['brand']?.toString(), index);
    final holder = CardDisplay.holder(card);
    final number = CardDisplay.number(card);
    final expiry = CardDisplay.expiry(card);
    final brand = card['brand']?.toString();

    return FlipCard(
      showBack: index == selectedCardIndex && _flipped,
      front: SavedCardWidget(
        cardHolderName: holder,
        maskedNumber: number,
        expiryDate: expiry,
        brand: brand,
        palette: palette,
        height: kCardHeight,
        width: cardWidth,
      ),
      back: SavedCardBack(
        cardHolderName: holder,
        maskedNumber: number,
        expiryDate: expiry,
        brand: brand,
        palette: palette,
        height: kCardHeight,
        width: cardWidth,
      ),
    );
  }
}
