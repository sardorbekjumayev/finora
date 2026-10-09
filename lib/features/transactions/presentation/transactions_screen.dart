import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/database/enums.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/utils/date_labels.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/design_kit.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../statistics/data/currency_converter.dart';
import '../data/transaction_filter.dart';
import '../data/transaction_repository.dart';
import 'widgets/transaction_filter_sheet.dart';
import 'widgets/transaction_tile.dart';

class TxFilterController extends Notifier<TransactionFilter> {
  @override
  TransactionFilter build() => const TransactionFilter();

  void setQuery(String value) => state = state.copyWith(query: value);

  void replace(TransactionFilter filter) => state = filter;

  void reset() => state = const TransactionFilter();
}

final txFilterProvider =
    NotifierProvider<TxFilterController, TransactionFilter>(
  TxFilterController.new,
);

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchController = TextEditingController();
  bool _searching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) {
        _searchController.clear();
        ref.read(txFilterProvider.notifier).setQuery('');
      }
    });
  }

  Future<void> _delete(TxWithRefs item) async {
    final l10n = AppL10n.of(context);
    final repo = ref.read(transactionRepositoryProvider);
    final removed = await repo.delete(item.tx.id);
    if (removed == null || !mounted) return;

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.txDeleted),
        action: SnackBarAction(
          label: l10n.actionUndo,
          onPressed: () => repo.restore(removed),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final filter = ref.watch(txFilterProvider);
    final async = ref.watch(filteredTransactionsProvider(filter));
    final settings = ref.watch(settingsProvider);
    final visible = ref.watch(balanceVisibleProvider);
    final converter = ref.watch(currencyConverterProvider).value ??
        CurrencyConverter.identity(settings.mainCurrencyCode);

    final activeCount = filter.activeCount + (filter.range == null ? 0 : 1);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: l10n.txListTitle,
              actions: [
                RoundIconButton(
                  icon: _searching ? Icons.close : Icons.search,
                  tooltip: l10n.actionSearch,
                  onPressed: _toggleSearch,
                ),
                Badge(
                  isLabelVisible: activeCount > 0,
                  label: Text('$activeCount'),
                  alignment: Alignment.topRight,
                  offset: const Offset(-2, 2),
                  child: RoundIconButton(
                    icon: Icons.tune,
                    tooltip: l10n.actionFilter,
                    onPressed: () async {
                      final updated = await showTransactionFilterSheet(
                        context,
                        initial: filter,
                      );
                      if (updated != null) {
                        ref.read(txFilterProvider.notifier).replace(updated);
                      }
                    },
                  ),
                ),
              ],
            ),
            if (_searching)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDims.pagePadding,
                  0,
                  AppDims.pagePadding,
                  12,
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n.txSearchHint,
                    prefixIcon: const Icon(Icons.search, size: 22),
                  ),
                  onChanged: (value) =>
                      ref.read(txFilterProvider.notifier).setQuery(value),
                ),
              ),
            // Maketdagi tur filtri: Hammasi / Kirim / Chiqim / O'tkazma.
            PillChips<TransactionType?>(
              options: [
                (null, l10n.labelAll),
                (TransactionType.income, l10n.txIncome),
                (TransactionType.expense, l10n.txExpense),
                (TransactionType.transfer, l10n.txTransfer),
              ],
              selected: filter.types.length == 1 ? filter.types.first : null,
              onChanged: (type) => ref.read(txFilterProvider.notifier).replace(
                    filter.copyWith(types: type == null ? {} : {type}),
                  ),
            ),
            Expanded(
              child: switch (async) {
                AsyncError(:final error) => EmptyState(
                    icon: Icons.error_outline,
                    title: l10n.errorGeneric,
                    message: '$error',
                  ),
                AsyncData(:final value) when value.isEmpty => EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: l10n.txEmptyTitle,
                    message: l10n.txEmptyBody,
                    actionLabel: l10n.txNew,
                    onAction: () => context.push(Routes.txNew),
                  ),
                AsyncData(:final value) => _GroupedList(
                    items: value,
                    converter: converter,
                    hidden: !visible,
                    onDelete: _delete,
                  ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Kunlar bo'yicha guruhlangan ro'yxat; har kun sarlavhasida kun jami.
class _GroupedList extends StatelessWidget {
  const _GroupedList({
    required this.items,
    required this.converter,
    required this.hidden,
    required this.onDelete,
  });

  final List<TxWithRefs> items;
  final CurrencyConverter converter;
  final bool hidden;
  final Future<void> Function(TxWithRefs) onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final mainCurrency = Currency.byCode(converter.mainCurrency);
    final groups = _group(items);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppDims.pagePadding,
        12,
        AppDims.pagePadding,
        AppDims.navBarClearance,
      ),
      itemCount: groups.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final group = groups[index];

        // Maketda kun guruhlari oq kartochka ichida: 13/800 kun sarlavhasi
        // va kun jami, so'ng yozuvlar.
        return DesignCard(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      DateLabels.dayHeader(context, group.day),
                      style: AppText.smallStrong.copyWith(
                        color: palette.textMuted,
                      ),
                    ),
                  ),
                  AmountText(
                    amount: group.net,
                    currency: mainCurrency,
                    type: group.net >= 0
                        ? TransactionType.income
                        : TransactionType.expense,
                    hidden: hidden,
                    style: AppText.smallStrong,
                  ),
                ],
              ),
              for (final item in group.items)
                _SwipeableTile(
                  item: item,
                  hidden: hidden,
                  onDelete: () => onDelete(item),
                ),
            ],
          ),
        );
      },
    );
  }

  List<_DayGroup> _group(List<TxWithRefs> items) {
    final groups = <_DayGroup>[];
    for (final item in items) {
      final day = DateTime(
        item.tx.date.year,
        item.tx.date.month,
        item.tx.date.day,
      );
      if (groups.isEmpty || groups.last.day != day) {
        groups.add(_DayGroup(day: day, items: [], net: 0));
      }
      final group = groups.last;
      group.items.add(item);
      if (item.tx.type != TransactionType.transfer) {
        final value = converter.toMain(item.tx.amount, item.account.currency);
        group.net += item.tx.type == TransactionType.income ? value : -value;
      }
    }
    return groups;
  }
}

class _DayGroup {
  _DayGroup({required this.day, required this.items, required this.net});

  final DateTime day;
  final List<TxWithRefs> items;
  int net;
}

class _SwipeableTile extends StatelessWidget {
  const _SwipeableTile({
    required this.item,
    required this.hidden,
    required this.onDelete,
  });

  final TxWithRefs item;
  final bool hidden;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey('tx-${item.tx.id}'),
      background: _SwipeBackground(
        alignment: Alignment.centerLeft,
        color: scheme.secondaryContainer,
        foreground: scheme.onSecondaryContainer,
        icon: Icons.edit_outlined,
        label: l10n.actionEdit,
      ),
      secondaryBackground: _SwipeBackground(
        alignment: Alignment.centerRight,
        color: scheme.errorContainer,
        foreground: scheme.onErrorContainer,
        icon: Icons.delete_outline,
        label: l10n.actionDelete,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // O'ngga surish — tahrirlash, element ro'yxatda qoladi.
          context.push(Routes.txEdit(item.tx.id));
          return false;
        }
        onDelete();
        return false;
      },
      child: TransactionTile(
        item: item,
        hidden: hidden,
        onTap: () => context.push(Routes.txDetails(item.tx.id)),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.foreground,
    required this.icon,
    required this.label,
  });

  final Alignment alignment;
  final Color color;
  final Color foreground;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
