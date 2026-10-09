import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/icon_color_picker.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/category_repository.dart';

/// Kategoriya tanlash paneli. Ro'yxat emas, to'r — 3–4 tapda saqlash uchun.
Future<int?> showCategoryPicker(
  BuildContext context, {
  required CategoryKind kind,
  int? selectedId,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _CategoryPickerSheet(kind: kind, selectedId: selectedId),
  );
}

class _CategoryPickerSheet extends ConsumerWidget {
  const _CategoryPickerSheet({required this.kind, this.selectedId});

  final CategoryKind kind;
  final int? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final categories =
        ref.watch(categoriesByKindProvider(kind)).value ?? const <Category>[];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.txSelectCategory,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: l10n.catNew,
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('${Routes.categoryNew}?kind=${kind.name}');
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (categories.isEmpty)
              EmptyState(
                compact: true,
                icon: Icons.category_outlined,
                title: l10n.catEmptyTitle,
                message: l10n.catEmptyBody,
                actionLabel: l10n.catNew,
                onAction: () {
                  Navigator.of(context).pop();
                  context.push('${Routes.categoryNew}?kind=${kind.name}');
                },
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.55,
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category.id == selectedId;
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).pop(category.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconBadge(
                              iconKey: category.iconKey,
                              colorValue: category.colorValue,
                              size: 46,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              category.name,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
