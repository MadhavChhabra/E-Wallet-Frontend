import 'package:flutter/material.dart';
import 'package:flutter_ewallet/utils/theme.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          children: [
            Text(
              'Rewards',
              style: blackTextStyle.copyWith(
                fontSize: 24,
                fontWeight: semiBold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Earn perks as you spend and top up your wallet.',
              style: greyTextStyle.copyWith(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 24),
            const _RewardHeroCard(
              title: 'Level progress',
              subtitle: 'Keep transacting to unlock higher tiers.',
              progress: 0.42,
              badge: 'Silver',
            ),
            const SizedBox(height: 16),
            _OfferCard(
              icon: Icons.local_offer_outlined,
              title: '5% cashback on top-up',
              subtitle: 'Valid on Razorpay test payments this week.',
              accent: purpleColor,
              onTap: () => Navigator.pushNamed(context, '/topup-amount'),
            ),
            const SizedBox(height: 12),
            _OfferCard(
              icon: Icons.card_giftcard_outlined,
              title: 'Refer & earn',
              subtitle: 'Invite friends and earn wallet credits.',
              accent: blueColor,
            ),
            const SizedBox(height: 12),
            _OfferCard(
              icon: Icons.verified_user_outlined,
              title: 'Verified account bonus',
              subtitle: 'Complete your profile to unlock extra limits.',
              accent: greenColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardHeroCard extends StatelessWidget {
  const _RewardHeroCard({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.badge,
  });

  final String title;
  final String subtitle;
  final double progress;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [purpleColor, purpleColor.withOpacity(0.82)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: purpleColor.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: whiteTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: semiBold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: whiteColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: whiteTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: semiBold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: whiteTextStyle.copyWith(
              fontSize: 13,
              color: whiteColor.withOpacity(0.88),
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: whiteColor.withOpacity(0.22),
              color: whiteColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).round()}% to next tier',
            style: whiteTextStyle.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: blackTextStyle.copyWith(
                        fontWeight: semiBold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: greyTextStyle.copyWith(fontSize: 13, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
