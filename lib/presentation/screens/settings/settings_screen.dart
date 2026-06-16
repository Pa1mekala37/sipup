import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/providers.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/water_provider.dart';
import 'custom_containers_screen.dart';
import 'reminder_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final profile = ref.watch(userProfileProvider);
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
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                title: const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Appearance ────────────────────────────────────────
                    _SectionHeader(label: 'Appearance'),
                    _SettingsTile(
                      icon: Icons.dark_mode_outlined,
                      iconColor: const Color(0xFF7C3AED),
                      title: 'Dark Mode',
                      subtitle: 'Switch between light and dark theme',
                      trailing: Switch(
                        value: themeMode == ThemeMode.dark,
                        onChanged: (_) =>
                            ref.read(themeModeProvider.notifier).toggle(),
                        activeColor: AppColors.primary,
                      ),
                    ).animate().fadeIn(delay: 100.ms),

                    const SizedBox(height: 16),

                    // ── Hydration ─────────────────────────────────────────
                    _SectionHeader(label: 'Hydration'),
                    _SettingsTile(
                      icon: Icons.flag_outlined,
                      iconColor: AppColors.primary,
                      title: 'Daily Goal',
                      subtitle: profile != null
                          ? '${profile.dailyGoalMl} ml per day'
                          : 'Not set',
                      onTap: () => _showGoalPicker(context, ref, profile?.dailyGoalMl ?? 2000),
                    ).animate(delay: 150.ms).fadeIn(),

                    _SettingsTile(
                      icon: Icons.wb_sunny_outlined,
                      iconColor: Colors.orange,
                      title: 'Wake-up Time',
                      subtitle: profile?.wakeTimeFormatted ?? 'Not set',
                      onTap: () => _pickWakeTime(context, ref, profile),
                    ).animate(delay: 200.ms).fadeIn(),

                    _SettingsTile(
                      icon: Icons.nightlight_outlined,
                      iconColor: const Color(0xFF5C6BC0),
                      title: 'Bedtime',
                      subtitle: profile?.sleepTimeFormatted ?? 'Not set',
                      onTap: () => _pickSleepTime(context, ref, profile),
                    ).animate(delay: 250.ms).fadeIn(),

                    _SettingsTile(
                      icon: Icons.notifications_outlined,
                      iconColor: AppColors.waterBlue,
                      title: 'Reminder Settings',
                      subtitle: 'Configure reminder times',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReminderSettingsScreen(),
                        ),
                      ),
                      showChevron: true,
                    ).animate(delay: 300.ms).fadeIn(),

                    _SettingsTile(
                      icon: Icons.local_drink_outlined,
                      iconColor: AppColors.secondary,
                      title: 'Custom Containers',
                      subtitle: 'Manage your drink containers',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CustomContainersScreen(),
                        ),
                      ),
                      showChevron: true,
                    ).animate(delay: 350.ms).fadeIn(),

                    const SizedBox(height: 16),

                    // ── Data ──────────────────────────────────────────────
                    _SectionHeader(label: 'Data'),
                    _SettingsTile(
                      icon: Icons.delete_outline,
                      iconColor: AppColors.error,
                      title: 'Reset All Data',
                      subtitle: 'Delete all logs and settings',
                      titleColor: AppColors.error,
                      onTap: () => _showResetConfirmation(context, ref),
                    ).animate(delay: 400.ms).fadeIn(),

                    const SizedBox(height: 24),

                    // ── About ─────────────────────────────────────────────
                    Center(
                      child: Column(
                        children: [
                          Text(
                            AppConstants.appName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Version 1.0.0 • Free',
                            style: TextStyle(
                              fontSize: 13,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '💧 Stay hydrated, stay healthy',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 500.ms).fadeIn(),

                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGoalPicker(BuildContext context, WidgetRef ref, int current) {
    final goals = [1500, 2000, 2500, 3000, 3500, 4000];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Goal',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            ...goals.map((g) => ListTile(
                  title: Text(
                    g >= 1000 ? '${g / 1000}L' : '${g}ml',
                    style: TextStyle(
                      fontWeight: g == current
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: g == current ? AppColors.primary : null,
                    ),
                  ),
                  trailing: g == current
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () async {
                    await ref.read(userProfileProvider.notifier).updateGoal(g);
                    if (context.mounted) Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickWakeTime(
      BuildContext context, WidgetRef ref, dynamic profile) async {
    if (profile == null) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: profile.wakeHour, minute: profile.wakeMinute),
    );
    if (picked != null) {
      await ref.read(userProfileProvider.notifier).updateWakeTime(
          picked.hour, picked.minute);
      final updatedProfile = ref.read(userProfileProvider);
      if (updatedProfile != null) {
        await ref.read(remindersProvider.notifier).generateForProfile(updatedProfile);
      }
    }
  }

  Future<void> _pickSleepTime(
      BuildContext context, WidgetRef ref, dynamic profile) async {
    if (profile == null) return;
    final picked = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: profile.sleepHour, minute: profile.sleepMinute),
    );
    if (picked != null) {
      await ref.read(userProfileProvider.notifier).updateSleepTime(
          picked.hour, picked.minute);
      final updatedProfile = ref.read(userProfileProvider);
      if (updatedProfile != null) {
        await ref.read(remindersProvider.notifier).generateForProfile(updatedProfile);
      }
    }
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data'),
        content: const Text(
          'This will permanently delete all your water logs, streaks, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () async {
              await ref.read(localDataSourceProvider).clearAll();
              await NotificationService.instance.cancelAllReminders();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data has been reset')),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = false,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                ),
              ],
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: cs.onSurfaceVariant,
          ),
        ),
        trailing: trailing ??
            (showChevron
                ? Icon(
                    Icons.chevron_right,
                    color: cs.onSurfaceVariant,
                  )
                : null),
      ),
    );
  }
}
