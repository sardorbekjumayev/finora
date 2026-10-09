import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/icon_color_picker.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/category_repository.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late final _tabs = TabController(length: 2, vsync: this);
  bool _showArchived = false;

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  CategoryKind get _currentKind =>
      _tabs.index == 0 ? CategoryKind.expense : CategoryKind.income;

  Future<void> _delete(Category category) async {
    final l10n = AppL10n.of(context);
    final repo = ref.read(categoryRepositoryProvider);
    final count = await repo.transactionCount(category.id);
    if (!mounted) return;

    final ok = await confirm(
      context,
      title: l10n.catDeleteTitle,
      message: l10n.catDeleteBody(count),
      confirmLabel: l10n.actionDelete,
      destructive: true,
      icon: Icons.delete_outline,
    );
    if (ok) await repo.delete(category.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.catTitle),
        actions: [
          IconButton(
            tooltip: l10n.catShowArchived,
            onPressed: () => setState(() => _showArchived = !_showArchived),
            icon: Icon(
              _showArchived ? Icons.inventory_2 : Icons.inventory_2_outlined,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          onTap: (_) => setState(() {}),
          tabs: [
            Tab(text: l10n.txExpense),
            Tab(text: l10n.txIncome),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          '${Routes.categoryNew}?kind=${_currentKind.name}',
        ),
        icon: const Icon(Icons.add),
        label: Text(l10n.catNew),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _CategoryList(
            kind: CategoryKind.expense,
            showArchived: _showArchived,
            onDelete: _delete,
          ),
          _CategoryList(
            kind: CategoryKind.income,
            showArchived: _showArchived,
            onDelete: _delete,
          ),
        ],
      ),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  const _CategoryList({
    required this.kind,
    required this.showArchived,
    required this.onDelete,
  });

  final CategoryKind kind;
  final bool showArchived;
  final Future<void> Function(Category) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final source = showArchived ? allCategoriesProvider : activeCategoriesProvider;
    final all = ref.watch(source).value;

    if (all == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final categories =
        all.where((c) => c.kind == kind).toList(growable: false);

    if (categories.isEmpty) {
      return EmptyState(
        icon: Icons.category_outlined,
        title: l10n.catEmptyTitle,
        message: l10n.catEmptyBody,
        actionLabel: l10n.catNew,
        onAction: () =>
            context.push('${Routes.categoryNew}?kind=${kind.name}'),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: categories.length,
      onReorderItem: (fromIndex, toIndex) {
        final ids = categories.map((c) => c.id).toList();
        ids.insert(toIndex, ids.removeAt(fromIndex));
        HapticFeedback.selectionClick();
        ref.read(categoryRepositoryProvider).reorder(ids);
      },
      itemBuilder: (context, index) {
        final category = categories[index];
        return Opacity(
          key: ValueKey('cat-${category.id}'),
          opacity: category.isArchived ? 0.55 : 1,
          child: ListTile(
            onTap: () => context.push(Routes.categoryEdit(category.id)),
            leading: IconBadge(
              iconKey: category.iconKey,
              colorValue: category.colorValue,
            ),
            title: Text(category.name),
            subtitle: category.isArchived
                ? Text(
                    l10n.catArchived,
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : null,
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                final repo = ref.read(categoryRepositoryProvider);
                switch (value) {
                  case 'edit':
                    context.push(Routes.categoryEdit(category.id));
                  case 'archive':
                    await repo.setArchived(
                      category.id,
                      archived: !category.isArchived,
                    );
                  case 'delete':
                    await onDelete(category);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'edit', child: Text(l10n.actionEdit)),
                PopupMenuItem(
                  value: 'archive',
                  child: Text(
                    category.isArchived
                        ? l10n.actionUnarchive
                        : l10n.actionArchive,
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    l10n.actionDelete,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
