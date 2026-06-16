import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/reminder_provider.dart';

class ReminderSettingsScreen extends ConsumerWidget {
  const ReminderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(remindersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reminders',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () => ref.read(remindersProvider.notifier).rescheduleAll(),
            child: const Text('Reschedule'),
          ),
        ],
      ),
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: reminders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🔔', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    'No reminders set',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete onboarding to generate reminders',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reminders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final reminder = reminders[i];
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: reminder.isEnabled
                          ? AppColors.primary.withOpacity(0.2)
                          : cs.outline.withOpacity(0.15),
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
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: reminder.isEnabled
                              ? AppColors.primary.withOpacity(0.1)
                              : cs.outline.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: reminder.isEnabled
                              ? AppColors.primary
                              : cs.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reminder.formattedTime,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: reminder.isEnabled
                                    ? cs.onSurface
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              reminder.isEnabled ? 'Active' : 'Disabled',
                              style: TextStyle(
                                fontSize: 12,
                                color: reminder.isEnabled
                                    ? AppColors.success
                                    : cs.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: reminder.isEnabled,
                        onChanged: (_) => ref
                            .read(remindersProvider.notifier)
                            .toggleReminder(reminder.id),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ).animate(delay: Duration(milliseconds: i * 30)).fadeIn().slideX(begin: 0.05, end: 0);
              },
            ),
    );
  }
}
