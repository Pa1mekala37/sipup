import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../providers/water_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);
    final longest = ref.watch(longestStreakProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    final badges = _buildBadges(streak, longest);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Achievements',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Streak hero
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🔥 Current Streak',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$streak',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        const Text(
                          'days',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          '🏆 Best Streak',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$longest',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        const Text(
                          'days',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1, 1),
                  duration: 400.ms,
                ),
          ),

          // Badges section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Text(
                'Badges',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final badge = badges[i];
                  return _BadgeCard(badge: badge)
                      .animate(
                          delay: Duration(milliseconds: 100 + i * 60))
                      .fadeIn()
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        duration: 300.ms,
                        curve: Curves.elasticOut,
                      );
                },
                childCount: badges.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  List<_Badge> _buildBadges(int streak, int longest) {
    return [
      _Badge(
        emoji: '💧',
        title: 'First Drop',
        description: 'Log your first water',
        days: 1,
        unlocked: longest >= 1,
        color: AppColors.waterBlue,
      ),
      _Badge(
        emoji: '🌊',
        title: '7-Day Wave',
        description: '7-day streak',
        days: 7,
        unlocked: longest >= 7,
        color: AppColors.primary,
      ),
      _Badge(
        emoji: '⭐',
        title: 'Two Weeks',
        description: '14-day streak',
        days: 14,
        unlocked: longest >= 14,
        color: AppColors.warning,
      ),
      _Badge(
        emoji: '🏅',
        title: 'Monthly Hero',
        description: '30-day streak',
        days: 30,
        unlocked: longest >= 30,
        color: AppColors.streakBronze,
      ),
      _Badge(
        emoji: '🥈',
        title: '60-Day Legend',
        description: '60-day streak',
        days: 60,
        unlocked: longest >= 60,
        color: AppColors.streakSilver,
      ),
      _Badge(
        emoji: '🥇',
        title: 'Century Club',
        description: '100-day streak',
        days: 100,
        unlocked: longest >= 100,
        color: AppColors.streakGold,
      ),
      _Badge(
        emoji: '👑',
        title: 'Year Champion',
        description: '365-day streak',
        days: 365,
        unlocked: longest >= 365,
        color: AppColors.streakPlatinum,
      ),
    ];
  }
}

class _Badge {
  final String emoji;
  final String title;
  final String description;
  final int days;
  final bool unlocked;
  final Color color;

  const _Badge({
    required this.emoji,
    required this.title,
    required this.description,
    required this.days,
    required this.unlocked,
    required this.color,
  });
}

class _BadgeCard extends StatelessWidget {
  final _Badge badge;

  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: badge.unlocked
            ? badge.color.withOpacity(isDark ? 0.15 : 0.08)
            : isDark
                ? AppColors.cardDark
                : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badge.unlocked
              ? badge.color.withOpacity(0.4)
              : cs.outline.withOpacity(0.15),
          width: badge.unlocked ? 1.5 : 1,
        ),
        boxShadow: badge.unlocked
            ? [
                BoxShadow(
                  color: badge.color.withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji with lock overlay
          Stack(
            alignment: Alignment.center,
            children: [
              Text(
                badge.emoji,
                style: TextStyle(
                  fontSize: 36,
                  color: badge.unlocked ? null : Colors.transparent,
                ),
              ),
              if (!badge.unlocked)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cs.outline.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    color: cs.onSurfaceVariant.withOpacity(0.5),
                    size: 24,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            badge.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: badge.unlocked ? badge.color : cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            badge.description,
            style: TextStyle(
              fontSize: 10,
              color: cs.onSurfaceVariant.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
