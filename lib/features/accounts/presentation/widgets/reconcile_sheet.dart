import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/money.dart';
import '../../../../core/widgets/amount_text.dart';
import '../../../../core/widgets/money_field.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/account_repository.dart';

/// Balansni to'g'rilash: foydalanuvchi haqiqiy qoldiqni kiritadi, ilova farqni
/// "Tuzatish" yozuvi sifatida qo'shadi — balans qo'lda o'zgartirilmaydi.
Future<void> showReconcileSheet(
  BuildContext context,
  AccountWithBalance item,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ReconcileSheet(item: item),
  );
}

class _ReconcileSheet extends ConsumerStatefulWidget {
  const _ReconcileSheet({required this.item});

  final AccountWithBalance item;

  @override
  ConsumerState<_ReconcileSheet> createState() => _ReconcileSheetState();
}

class _ReconcileSheetState extends ConsumerState<_ReconcileSheet> {
  late final _controller = TextEditingController(
    text: Money.raw(widget.item.balance, currency: widget.item.currency),
  );
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final l10n = AppL10n.of(context);
    final real = MoneyField.toMinor(_controller.text);
    if (real == null) return;

    setState(() => _saving = true);
    final diff = await ref.read(accountRepositoryProvider).reconcile(
          accountId: widget.item.id,
          realBalance: real,
          note: l10n.accAdjustmentNote,
        );

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    HapticFeedback.mediumImpact();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          diff == 0
              ? l10n.accReconcileNoDiff
              : l10n.accReconcileDone(
                  Money.format(
                    diff,
                    currency: widget.item.currency,
                    forcedSign: diff > 0 ? '+' : '−',
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.accReconcile,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.accReconcileBody,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.item.name,
                    style: Theme.of(context).textTheme.bodyMedium),
                AmountText(
                  amount: widget.item.balance,
                  currency: widget.item.currency,
                  showSign: false,
                  colorize: false,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            MoneyField(
              controller: _controller,
              currency: widget.item.currency,
              label: l10n.accRealBalance,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: _apply,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _apply,
              child: Text(l10n.actionSave),
            ),
          ],
        ),
      ),
    );
  }
}
