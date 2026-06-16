import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/user_profile.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/user_provider.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Step values
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 23, minute: 0);
  int _goalMl = 2000;
  final _customGoalController = TextEditingController();
  bool _isCustomGoal = false;

  @override
  void dispose() {
    _pageController.dispose();
    _customGoalController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final goal = _isCustomGoal
        ? int.tryParse(_customGoalController.text) ?? 2000
        : _goalMl;

    final profile = UserProfile(
      wakeHour: _wakeTime.hour,
      wakeMinute: _wakeTime.minute,
      sleepHour: _sleepTime.hour,
      sleepMinute: _sleepTime.minute,
      dailyGoalMl: goal.clamp(
          AppConstants.minGoal, AppConstants.maxGoal),
      createdAt: DateTime.now(),
    );

    await ref.read(userProfileProvider.notifier).saveProfile(profile);
    await ref.read(userProfileProvider.notifier).markOnboardingComplete();
    await ref.read(remindersProvider.notifier).generateForProfile(profile);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.backgroundGradientDark
              : AppColors.backgroundGradientLight,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  children: List.generate(4, (i) {
                    final isActive = i <= _currentPage;
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : cs.outline.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _WakeTimePage(
                      wakeTime: _wakeTime,
                      onChanged: (t) => setState(() => _wakeTime = t),
                    ),
                    _SleepTimePage(
                      sleepTime: _sleepTime,
                      onChanged: (t) => setState(() => _sleepTime = t),
                    ),
                    _GoalPage(
                      selectedGoal: _goalMl,
                      isCustom: _isCustomGoal,
                      customController: _customGoalController,
                      onGoalSelected: (g) => setState(() {
                        _goalMl = g;
                        _isCustomGoal = false;
                      }),
                      onCustomSelected: () =>
                          setState(() => _isCustomGoal = true),
                    ),
                    _SummaryPage(
                      wakeTime: _wakeTime,
                      sleepTime: _sleepTime,
                      goalMl: _isCustomGoal
                          ? int.tryParse(_customGoalController.text) ?? 2000
                          : _goalMl,
                    ),
                  ],
                ),
              ),

              // Next button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _nextPage,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      _currentPage == 3 ? 'Get Started 🚀' : 'Continue',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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

// ─── Step pages ────────────────────────────────────────────────────────────────

class _WakeTimePage extends StatelessWidget {
  final TimeOfDay wakeTime;
  final ValueChanged<TimeOfDay> onChanged;

  const _WakeTimePage({required this.wakeTime, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text('🌅', style: TextStyle(fontSize: 72))
              .animate()
              .scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            'When do you wake up?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 12),
          Text(
            'We\'ll schedule your first reminder right after you wake up.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 48),
          _TimePickerCard(
            time: wakeTime,
            onChanged: onChanged,
            label: 'Wake-up time',
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }
}

class _SleepTimePage extends StatelessWidget {
  final TimeOfDay sleepTime;
  final ValueChanged<TimeOfDay> onChanged;

  const _SleepTimePage({required this.sleepTime, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text('🌙', style: TextStyle(fontSize: 72))
              .animate()
              .scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            'When do you go to bed?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 12),
          Text(
            'We\'ll stop sending reminders when you sleep.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 48),
          _TimePickerCard(
            time: sleepTime,
            onChanged: onChanged,
            label: 'Bedtime',
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }
}

class _TimePickerCard extends StatelessWidget {
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;
  final String label;

  const _TimePickerCard({
    required this.time,
    required this.onChanged,
    required this.label,
  });

  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: time,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final m = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$h:$m',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: -2,
                    ),
                  ),
                  TextSpan(
                    text: ' $period',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to change',
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalPage extends StatelessWidget {
  final int selectedGoal;
  final bool isCustom;
  final TextEditingController customController;
  final ValueChanged<int> onGoalSelected;
  final VoidCallback onCustomSelected;

  const _GoalPage({
    required this.selectedGoal,
    required this.isCustom,
    required this.customController,
    required this.onGoalSelected,
    required this.onCustomSelected,
  });

  @override
  Widget build(BuildContext context) {
    final goals = [
      {'label': '2 Liters', 'ml': 2000, 'emoji': '🥤'},
      {'label': '2.5 Liters', 'ml': 2500, 'emoji': '💧'},
      {'label': '3 Liters', 'ml': 3000, 'emoji': '🫗'},
      {'label': '4 Liters', 'ml': 4000, 'emoji': '🌊'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text('🎯', style: TextStyle(fontSize: 72))
              .animate()
              .scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            'Set your daily goal',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            'How much water do you want to drink per day?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 32),
          ...goals.asMap().entries.map((e) {
            final g = e.value;
            final ml = g['ml'] as int;
            final isSelected = !isCustom && selectedGoal == ml;
            return _GoalOption(
              label: g['label'] as String,
              emoji: g['emoji'] as String,
              ml: ml,
              isSelected: isSelected,
              onTap: () => onGoalSelected(ml),
            )
                .animate(delay: Duration(milliseconds: 400 + e.key * 80))
                .fadeIn()
                .slideX(begin: 0.1, end: 0);
          }),
          const SizedBox(height: 12),
          // Custom goal
          GestureDetector(
            onTap: onCustomSelected,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCustom
                    ? AppColors.primary.withOpacity(0.1)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCustom
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  width: isCustom ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  const Text('✏️', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: isCustom
                        ? TextField(
                            controller: customController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter amount in ml',
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            autofocus: true,
                          )
                        : const Text(
                            'Custom Amount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  if (!isCustom)
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
            ),
          ).animate(delay: 720.ms).fadeIn().slideX(begin: 0.1, end: 0),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _GoalOption extends StatelessWidget {
  final String label;
  final String emoji;
  final int ml;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalOption({
    required this.label,
    required this.emoji,
    required this.ml,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : null,
                ),
              ),
            ),
            Text(
              '$ml ml',
              style: TextStyle(
                fontSize: 14,
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPage extends StatelessWidget {
  final TimeOfDay wakeTime;
  final TimeOfDay sleepTime;
  final int goalMl;

  const _SummaryPage({
    required this.wakeTime,
    required this.sleepTime,
    required this.goalMl,
  });

  String _fmt(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  int _reminderCount() {
    final wakeMin = wakeTime.hour * 60 + wakeTime.minute;
    final sleepMin = sleepTime.hour * 60 + sleepTime.minute;
    final awake = sleepMin > wakeMin
        ? sleepMin - wakeMin
        : (24 * 60 - wakeMin) + sleepMin;
    final count = (goalMl / 250).ceil().clamp(2, 24);
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final count = _reminderCount();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text('✅', style: TextStyle(fontSize: 72))
              .animate()
              .scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            'You\'re all set!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            'Here\'s your personalized hydration plan',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 40),
          _SummaryCard(
            icon: '🌅',
            label: 'Wake-up time',
            value: _fmt(wakeTime),
          ).animate(delay: 400.ms).fadeIn().slideX(begin: -0.1, end: 0),
          const SizedBox(height: 12),
          _SummaryCard(
            icon: '🌙',
            label: 'Bedtime',
            value: _fmt(sleepTime),
          ).animate(delay: 500.ms).fadeIn().slideX(begin: -0.1, end: 0),
          const SizedBox(height: 12),
          _SummaryCard(
            icon: '🎯',
            label: 'Daily goal',
            value:
                goalMl >= 1000 ? '${goalMl / 1000}L' : '${goalMl}ml',
          ).animate(delay: 600.ms).fadeIn().slideX(begin: -0.1, end: 0),
          const SizedBox(height: 12),
          _SummaryCard(
            icon: '🔔',
            label: 'Reminders per day',
            value: '$count reminders',
          ).animate(delay: 700.ms).fadeIn().slideX(begin: -0.1, end: 0),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
