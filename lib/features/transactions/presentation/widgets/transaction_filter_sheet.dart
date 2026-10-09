import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/utils/date_labels.dart';
import '../../../../core/utils/date_range.dart';
import '../../../../core/widgets/money_field.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../accounts/data/account_repository.dart';
import '../../../categories/data/category_repository.dart';
import '../../data/transaction_filter.dart';

/// Yozuvlar uchun filtr paneli. `null` qaytsa — foydalanuvchi bekor qildi.
Future<TransactionFilter?> showTransactionFilterSheet(
  BuildContext context, {
  required TransactionFilter initial,
}) {
  return showModalBottomSheet<TransactionFilter>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _FilterSheet(initial: initial),
  );
}

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet({required this.initial});

  final TransactionFilter initial;

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late TransactionFilter _filter = widget.initial;
  late final _minController = TextEditingController(
    text: widget.initial.minAmount == null
        ? ''
        : (widget.initial.minAmount! / 100).toString(),
  );
  late final _maxController = TextEditingController(
    text: widget.initial.maxAmount == null
        ? ''
        : (widget.initial.maxAmount! / 100).toString(),
  );

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  Set<T> _toggle<T>(Set<T> set, T value) {
    final next = {...set};
    if (!next.remove(value)) next.add(value);
    return next;
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
      initialDateRange: _filter.range == null
          ? null
          : DateTimeRange(
              start: _filter.range!.start,
              end: _filter.range!.end.subtract(const Duration(days: 1)),
            ),
    );
    if (picked == null) return;
    setState(() {
      _filter = _filter.copyWith(
        range: DateRange.custom(picked.start, picked.end),
      );
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      _filter.copyWith(
        minAmount: MoneyField.toMinor(_minController.text),
        maxAmount: MoneyField.toMinor(_maxController.text),
        clearAmounts: _minController.text.trim().isEmpty &&
            _maxController.text.trim().isEmpty,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final currency = ref.watch(settingsProvider).mainCurrency;
    final accounts =
        ref.watch(accountsProvider).value ?? const <AccountWithBalance>[];
    final categories =
        ref.watch(activeCategoriesProvider).value ?? const <Category>[];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.actionFilter,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _minController.clear();
                    _maxController.clear();
                    setState(() => _filter = const TransactionFilter());
                  },
                  child: Text(l10n.actionClear),
                ),
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Label(l10n.txDate),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(l10n.labelAll),
                          selected: _filter.range == null,
                          onSelected: (_) => setState(
                            () => _filter = _filter.copyWith(clearRange: true),
                          ),
                        ),
                        ChoiceChip(
                          avatar: const Icon(Icons.event_outlined, size: 18),
                          label: Text(
                            _filter.range == null
                                ? l10n.statPickRange
                                : DateLabels.rangeLabel(
                                    context,
                                    _filter.range!,
                                  ),
                          ),
                          selected: _filter.range != null,
                          onSelected: (_) => _pickRange(),
                        ),
                      ],
                    ),
                    _Label(l10n.txType),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final type in TransactionType.values)
                          FilterChip(
                            label: Text(switch (type) {
                              TransactionType.income => l10n.txIncome,
                              TransactionType.expense => l10n.txExpense,
                              TransactionType.transfer => l10n.txTransfer,
                            }),
                            selected: _filter.types.contains(type),
                            onSelected: (_) => setState(() {
                              _filter = _filter.copyWith(
                                types: _toggle(_filter.types, type),
                              );
                            }),
                          ),
                      ],
                    ),
                    if (accounts.isNotEmpty) ...[
                      _Label(l10n.accTitle),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final account in accounts)
                            FilterChip(
                              label: Text(account.name),
                              selected: _filter.accountIds.contains(account.id),
                              onSelected: (_) => setState(() {
                                _filter = _filter.copyWith(
                                  accountIds:
                                      _toggle(_filter.accountIds, account.id),
                                );
                              }),
                            ),
                        ],
                      ),
                    ],
                    if (categories.isNotEmpty) ...[
                      _Label(l10n.catTitle),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final category in categories)
                            FilterChip(
                              label: Text(category.name),
                              selected:
                                  _filter.categoryIds.contains(category.id),
                              onSelected: (_) => setState(() {
                                _filter = _filter.copyWith(
                                  categoryIds: _toggle(
                                    _filter.categoryIds,
                                    category.id,
                                  ),
                                );
                              }),
                            ),
                        ],
                      ),
                    ],
                    _Label(l10n.txAmount),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'min',
                              suffixText: currency.symbol,
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _maxController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'max',
                              suffixText: currency.symbol,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    _Label(l10n.txSortBy),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final sort in TxSort.values)
                          ChoiceChip(
                            label: Text(switch (sort) {
                              TxSort.dateDesc => '${l10n.txDate} ↓',
                              TxSort.dateAsc => '${l10n.txDate} ↑',
                              TxSort.amountDesc => '${l10n.txAmount} ↓',
                              TxSort.amountAsc => '${l10n.txAmount} ↑',
                            }),
                            selected: _filter.sort == sort,
                            onSelected: (_) => setState(
                              () => _filter = _filter.copyWith(sort: sort),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            FilledButton(
              onPressed: _apply,
              child: Text(l10n.actionApply),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 18, 0, 8),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
        ),
      );
}
