import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../providers/water_provider.dart';

class AddWaterBottomSheet extends ConsumerStatefulWidget {
  const AddWaterBottomSheet({super.key});

  @override
  ConsumerState<AddWaterBottomSheet> createState() =>
      _AddWaterBottomSheetState();
}

class _AddWaterBottomSheetState extends ConsumerState<AddWaterBottomSheet> {
  int? _selectedMl;
  bool _isCustom = false;
  final _customController = TextEditingController();
  String _selectedContainerName = '';
  String _selectedContainerEmoji = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _selectContainer(
      int ml, String name, String emoji) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedMl = ml;
      _selectedContainerName = name;
      _selectedContainerEmoji = emoji;
      _isCustom = false;
    });
  }

  Future<void> _addWater() async {
    final ml = _isCustom
        ? int.tryParse(_customController.text)
        : _selectedMl;

    if (ml == null || ml <= 0) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    await ref.read(dailySummaryProvider.notifier).addWater(
          amountMl: ml,
          containerName: _isCustom ? 'Custom' : _selectedContainerName,
          containerEmoji: _isCustom ? '💧' : _selectedContainerEmoji,
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customContainers = ref.watch(customContainersProvider);
    final mediaQuery = MediaQuery.of(context);

    final allContainers = [
      ...AppConstants.predefinedContainers.map((c) => {
            'name': c['name'] as String,
            'ml': c['volumeMl'] as int,
            'emoji': c['emoji'] as String,
            'isCustom': false,
          }),
      ...customContainers.map((c) => {
            'name': c.name,
            'ml': c.volumeMl,
            'emoji': c.emoji,
            'isCustom': true,
          }),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: mediaQuery.viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Text(
                  'Add Water 💧',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Text(
                  'Select a container or enter custom amount',
                  style: TextStyle(fontSize: 14),
                ),
              ),

              // Container grid
              SizedBox(
                height: 180,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: allContainers.length + 1, // +1 for custom
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    if (i == allContainers.length) {
                      return _CustomCard(
                        isSelected: _isCustom,
                        controller: _customController,
                        onTap: () => setState(() {
                          _isCustom = true;
                          _selectedMl = null;
                        }),
                      ).animate(
                        delay: Duration(milliseconds: i * 50),
                      ).fadeIn().slideX(begin: 0.2, end: 0);
                    }

                    final c = allContainers[i];
                    final ml = c['ml'] as int;
                    final name = c['name'] as String;
                    final emoji = c['emoji'] as String;
                    final isSelected =
                        !_isCustom && _selectedMl == ml && _selectedContainerName == name;

                    return _ContainerCard(
                      name: name,
                      ml: ml,
                      emoji: emoji,
                      isSelected: isSelected,
                      onTap: () => _selectContainer(ml, name, emoji),
                    ).animate(
                      delay: Duration(milliseconds: i * 50),
                    ).fadeIn().slideX(begin: 0.2, end: 0);
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Add button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: (_selectedMl != null || _isCustom) && !_isLoading
                        ? _addWater
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: cs.outline.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            _selectedMl != null
                                ? 'Log ${_selectedMl}ml'
                                : _isCustom
                                    ? 'Log Custom Amount'
                                    : 'Select a container',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContainerCard extends StatelessWidget {
  final String name;
  final int ml;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _ContainerCard({
    required this.name,
    required this.ml,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.12)
              : isDark
                  ? AppColors.surfaceDark
                  : const Color(0xFFF8FFFE),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : cs.outline.withOpacity(0.25),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : cs.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            const SizedBox(height: 4),
            Text(
              '$ml ml',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? AppColors.primary
                    : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomCard extends StatelessWidget {
  final bool isSelected;
  final TextEditingController controller;
  final VoidCallback onTap;

  const _CustomCard({
    required this.isSelected,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.12)
              : isDark
                  ? AppColors.surfaceDark
                  : const Color(0xFFF8FFFE),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : cs.outline.withOpacity(0.25),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✏️', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            if (isSelected)
              SizedBox(
                width: 90,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  autofocus: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'ml',
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              )
            else ...[
              Text(
                'Custom',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Enter ml',
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
