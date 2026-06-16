import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/daily_summary.dart';
import '../../providers/user_provider.dart';
import '../../providers/water_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlySummary = ref.watch(monthlySummaryProvider);
    final profile = ref.watch(userProfileProvider);
    final goalMl = profile?.dailyGoalMl ?? 2000;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.backgroundGradientDark
              : AppColors.backgroundGradientLight,
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                floating: true,
                title: const Text(
                  'History',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
              ),

              // Calendar heatmap strip
              SliverToBoxAdapter(
                child: _CalendarStrip(
                  summaries: monthlySummary,
                  goalMl: goalMl,
                ).animate().fadeIn(delay: 100.ms),
              ),

              // Daily entries
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final reversed =
                          monthlySummary.reversed.toList();
                      final summary = reversed[i];
                      if (summary.logs.isEmpty &&
                          !AppDateUtils.isSameDay(
                              summary.date, DateTime.now())) {
                        return null;
                      }
                      return _DayCard(summary: summary)
                          .animate(
                            delay: Duration(milliseconds: i * 40),
                          )
                          .fadeIn()
                          .slideY(begin: 0.1, end: 0);
                    },
                    childCount: monthlySummary.length,
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

class _CalendarStrip extends StatelessWidget {
  final List<DailySummary> summaries;
  final int goalMl;

  const _CalendarStrip({required this.summaries, required this.goalMl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final last7 = summaries.length >= 7
        ? summaries.sublist(summaries.length - 7)
        : summaries;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last 7 days',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: last7.map((s) {
              final pct = s.progressPercent;
              final isToday =
                  AppDateUtils.isSameDay(s.date, DateTime.now());

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    children: [
                      Text(
                        AppDateUtils.formatDayName(s.date),
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                          fontWeight: isToday
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: cs.outline.withOpacity(0.1),
                        ),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              height: 48 * pct,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: pct >= 1.0
                                    ? AppColors.success
                                    : pct > 0
                                        ? AppColors.primary
                                        : Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${s.date.day}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isToday
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isToday
                              ? AppColors.primary
                              : cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final DailySummary summary;

  const _DayCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isToday =
        AppDateUtils.isSameDay(summary.date, DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isToday
              ? AppColors.primary.withOpacity(0.3)
              : cs.outline.withOpacity(0.15),
          width: isToday ? 1.5 : 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                ),
              ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          title: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppDateUtils.formatDate(summary.date),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isToday ? AppColors.primary : cs.onSurface,
                    ),
                  ),
                  Text(
                    DateFormat('EEEE').format(summary.date),
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${summary.consumedMl} ml',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: summary.goalReached
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                  ),
                  Text(
                    'of ${summary.goalMl} ml',
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              // Progress mini ring
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  value: summary.progressPercent,
                  backgroundColor: cs.outline.withOpacity(0.2),
                  color: summary.goalReached
                      ? AppColors.success
                      : AppColors.primary,
                  strokeWidth: 4,
                ),
              ),
            ],
          ),
          children: [
            if (summary.logs.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Text(
                  'No entries for this day',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              )
            else
              ...summary.logs.map((log) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 0),
                    leading: Text(
                      log.containerEmoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                    title: Text(
                      log.containerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      AppDateUtils.formatTime(log.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    trailing: Text(
                      '+${log.amountMl} ml',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
