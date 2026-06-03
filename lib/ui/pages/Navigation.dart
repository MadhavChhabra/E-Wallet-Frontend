import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ewallet/ui/pages/home_page.dart';
import 'package:flutter_ewallet/ui/pages/transaction_history.dart';

import '../../utils/theme.dart';
import 'card/pick_a_card.dart';

class CustomBottomNavigation extends StatefulWidget {
  @override
  _CustomBottomNavigationState createState() => _CustomBottomNavigationState();
}

class _CustomBottomNavigationState extends State<CustomBottomNavigation> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Homepage(),
      TransactionHistoryPage(),
      SelectCard(),
      // RewardPage(),
    ];

    final Map<String, IconData> customIcons = {
    'assets/icon_home.png': Icons.home,
    'assets/icon_history.png': Icons.history,
    'assets/icon_credit_card.png': Icons.credit_card,
    'assets/icon_gift_card.png': Icons.card_giftcard,
  };

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/addCard");
        },
        backgroundColor: purpleColor,
        child: Image.asset(
          'assets/ic_plus_circle.png',
          width: 24,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: PageView(
        controller: _pageController,
        children: pages,
        physics: const NeverScrollableScrollPhysics(), // Prevent swiping
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        backgroundColor: whiteColor,
        activeIndex: _currentIndex,
        icons:
         const [
          Icons.home,
          Icons.history,
          Icons.credit_card,
          Icons.card_giftcard ,
        ],
        blurEffect: true,
        activeColor: purpleColor,
        inactiveColor: blackColor,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        elevation: 16,
        leftCornerRadius: 22,
        rightCornerRadius: 22,
        iconSize: 30,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
      ),
    );
  }
}
