import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ewallet/ui/pages/rewards_page.dart';
import 'package:flutter_ewallet/ui/pages/home_page.dart';
import 'package:flutter_ewallet/ui/pages/transaction_history.dart';

import '../../utils/theme.dart';
import 'card/pick_a_card.dart';

class CustomBottomNavigation extends StatefulWidget {
  const CustomBottomNavigation({super.key});

  @override
  State<CustomBottomNavigation> createState() => _CustomBottomNavigationState();
}

class _CustomBottomNavigationState extends State<CustomBottomNavigation> {
  int _currentIndex = 0;

  static const _pages = [
    Homepage(),
    TransactionHistoryPage(),
    SelectCard(),
    RewardsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/addCard');
        },
        backgroundColor: purpleColor,
        child: Image.asset(
          'assets/ic_plus_circle.png',
          width: 24,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        backgroundColor: whiteColor,
        activeIndex: _currentIndex,
        icons: const [
          Icons.home_rounded,
          Icons.history_rounded,
          Icons.credit_card_rounded,
          Icons.card_giftcard_rounded,
        ],
        blurEffect: true,
        activeColor: purpleColor,
        inactiveColor: blackColor.withOpacity(0.55),
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        elevation: 16,
        leftCornerRadius: 22,
        rightCornerRadius: 22,
        iconSize: 28,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
