import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/database/enums.dart';
import '../../../core/utils/date_labels.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/icon_color_picker.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/transaction_repository.dart';

class TransactionDetailsScreen extends ConsumerWidget {
  const TransactionDetailsScreen({required this.id, super.key});

  final int id;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final ok = await confirm(
      context,
      title: l10n.txDeleteTitle,
      message: l10n.txDeleteBody,
      confirmLabel: l10n.actionDelete,
      destructive: true,
      icon: Icons.delete_outline,
    );
    if (!ok) return;

    final repo = ref.read(transactionRepositoryProvider);
    final removed = await repo.delete(id);
    if (!context.mounted || removed == null) return;

    final messenger = ScaffoldMessenger.of(context);
    context.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.txDeleted),
        action: SnackBarAction(
          label: l10n.actionUndo,
          onPressed: () => repo.restore(removed),
        ),
      ),
    );
  }

  Future<void> _duplicate(BuildContext context, WidgetRef ref, TxWithRefs item) async {
    final l10n = AppL10n.of(context);
    await ref.read(transactionRepositoryProvider).create(
          TxDraft(
            type: item.tx.type,
            amount: item.tx.amount,
            accountId: item.tx.accountId,
            toAccountId: item.tx.toAccountId,
            categoryId: item.tx.categoryId,
            date: DateTime.now(),
            note: item.tx.note,
            transferRate: item.tx.transferRate,
          ),
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.txSaved)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final async = ref.watch(transactionByIdProvider(id));
    final item = async.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.txDetails),
        actions: [
          if (item != null) ...[
            IconButton(
              tooltip: l10n.actionDuplicate,
              onPressed: () => _duplicate(context, ref, item),
              icon: const Icon(Icons.copy_outlined),
            ),
            IconButton(
              tooltip: l10n.actionEdit,
              onPressed: () => context.push(Routes.txEdit(id)),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: l10n.actionDelete,
              onPressed: () => _delete(context, ref),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ],
      ),
      body: switch (async) {
        AsyncData(value: null) => EmptyState(
            icon: Icons.search_off_outlined,
            title: l10n.txEmptyTitle,
          ),
        AsyncData(:final value?) => _Details(item: value),
        AsyncError(:final error) => EmptyState(
            icon: Icons.error_outline,
            title: l10n.errorGeneric,
            message: '$error',
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.item});

  final TxWithRefs item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    final tx = item.tx;
    final isTransfer = tx.type == TransactionType.transfer;

    final typeLabel = switch (tx.type) {
      TransactionType.income => l10n.txIncome,
      TransactionType.expense => l10n.txExpense,
      TransactionType.transfer => l10n.txTransfer,
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: context.colorForTxType(tx.type).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      TxVisuals.icon(tx.type),
                      size: 16,
                      color: context.colorForTxType(tx.type),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      typeLabel,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: context.colorForTxType(tx.type),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FittedBox(
                child: AmountText(
                  amount: tx.amount,
                  currency: item.currency,
                  type: tx.type,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              if (isTransfer && item.isCrossCurrency) ...[
                const SizedBox(height: 4),
                AmountText(
                  amount: item.receivedAmount,
                  currency: item.toCurrency,
                  showSign: false,
                  colorize: false,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 28),
        Card(
          child: Column(
            children: [
              if (!isTransfer)
                _Row(
                  label: l10n.txCategory,
                  value: item.category?.name ?? l10n.txNoCategory,
                  leading: IconBadge(
                    iconKey: item.category?.iconKey ?? 'other',
                    colorValue:
                        item.category?.colorValue ?? scheme.outline.toARGB32(),
                    size: 36,
                  ),
                ),
              _Row(
                label: isTransfer ? l10n.txFromAccount : l10n.txAccount,
                value: item.account.name,
                leading: IconBadge(
                  iconKey: item.account.iconKey,
                  colorValue: item.account.colorValue,
                  size: 36,
                ),
              ),
              if (isTransfer && item.toAccount != null)
                _Row(
                  label: l10n.txToAccount,
                  value: item.toAccount!.name,
                  leading: IconBadge(
                    iconKey: item.toAccount!.iconKey,
                    colorValue: item.toAccount!.colorValue,
                    size: 36,
                  ),
                ),
              _Row(
                label: l10n.txDate,
                value: DateLabels.dateTime(context, tx.date),
                icon: Icons.event_outlined,
              ),
              if (tx.transferRate != null)
                _Row(
                  label: l10n.txRate,
                  value: tx.transferRate!.toString(),
                  icon: Icons.currency_exchange_outlined,
                ),
              if ((tx.note ?? '').trim().isNotEmpty)
                _Row(
                  label: l10n.txNote,
                  value: tx.note!.trim(),
                  icon: Icons.notes_outlined,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.icon,
    this.leading,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: leading ??
          (icon == null
              ? null
              : SizedBox(
                  width: 36,
                  child: Icon(icon, color: scheme.onSurfaceVariant),
                )),
      title: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: scheme.onSurfaceVariant),
      ),
      subtitle: Text(
        value,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}
