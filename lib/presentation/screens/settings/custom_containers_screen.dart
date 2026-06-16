import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/custom_container.dart';
import '../../providers/water_provider.dart';

class CustomContainersScreen extends ConsumerWidget {
  const CustomContainersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final containers = ref.watch(customContainersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Custom Containers',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Container',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: containers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🫗', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  Text(
                    'No custom containers yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your favorite containers',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: containers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final c = containers[i];
                return _ContainerTile(
                  container: c,
                  onEdit: () => _showEditDialog(context, ref, c),
                  onDelete: () => ref
                      .read(customContainersProvider.notifier)
                      .delete(c.id),
                ).animate(delay: Duration(milliseconds: i * 40)).fadeIn().slideX(begin: 0.05, end: 0);
              },
            ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    _showContainerDialog(context, ref, null);
  }

  void _showEditDialog(
      BuildContext context, WidgetRef ref, CustomContainer c) {
    _showContainerDialog(context, ref, c);
  }

  void _showContainerDialog(
      BuildContext context, WidgetRef ref, CustomContainer? existing) {
    final nameController =
        TextEditingController(text: existing?.name ?? '');
    final volController = TextEditingController(
        text: existing != null ? '${existing.volumeMl}' : '');
    String emoji = existing?.emoji ?? '🫗';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      existing == null ? 'Add Container' : 'Edit Container',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 20),
                    // Emoji selector
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Simple emoji cycling
                            final emojis = [
                              '🫗', '💧', '🥤', '☕', '🍶', '⚗️',
                              '🏃', '🪣', '🌊', '🥛'
                            ];
                            final idx = emojis.indexOf(emoji);
                            setState(() {
                              emoji = emojis[(idx + 1) % emojis.length];
                            });
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3)),
                            ),
                            child: Center(
                              child: Text(emoji,
                                  style: const TextStyle(fontSize: 32)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Tap to change emoji',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Container name',
                        hintText: 'e.g. Office Bottle',
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: volController,
                      decoration: const InputDecoration(
                        labelText: 'Volume (ml)',
                        hintText: 'e.g. 650',
                        suffixText: 'ml',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final vol = int.tryParse(volController.text);
                          if (name.isEmpty || vol == null || vol <= 0) {
                            return;
                          }

                          if (existing == null) {
                            await ref
                                .read(customContainersProvider.notifier)
                                .add(name: name, volumeMl: vol, emoji: emoji);
                          } else {
                            await ref
                                .read(customContainersProvider.notifier)
                                .update(existing.copyWith(
                                    name: name, volumeMl: vol, emoji: emoji));
                          }

                          if (context.mounted) Navigator.pop(context);
                        },
                        child: Text(
                          existing == null ? 'Add Container' : 'Save Changes',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ContainerTile extends StatelessWidget {
  final CustomContainer container;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ContainerTile({
    required this.container,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key(container.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Text(container.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    container.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${container.volumeMl} ml',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
