import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/widgets/amount_text.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/icon_color_picker.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/account_repository.dart';

/// Hisob tanlash paneli.
Future<int?> showAccountPicker(
  BuildContext context, {
  int? selectedId,
  Set<int> excludeIds = const {},
  String? title,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _AccountPickerSheet(
      selectedId: selectedId,
      excludeIds: excludeIds,
      title: title,
    ),
  );
}

class _AccountPickerSheet extends ConsumerWidget {
  const _AccountPickerSheet({
    this.selectedId,
    this.excludeIds = const {},
    this.title,
  });

  final int? selectedId;
  final Set<int> excludeIds;
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final all =
        ref.watch(accountsProvider).value ?? const <AccountWithBalance>[];
    final accounts =
        all.where((a) => !excludeIds.contains(a.id)).toList(growable: false);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title ?? l10n.txSelectAccount,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.accNew,
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push(Routes.accountNew);
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            if (accounts.isEmpty)
              EmptyState(
                compact: true,
                icon: Icons.account_balance_wallet_outlined,
                title: l10n.accEmptyTitle,
                message: l10n.accEmptyBody,
                actionLabel: l10n.accNew,
                onAction: () {
                  Navigator.of(context).pop();
                  context.push(Routes.accountNew);
                },
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.55,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final item = accounts[index];
                    final isSelected = item.id == selectedId;
                    return ListTile(
                      selected: isSelected,
                      leading: IconBadge(
                        iconKey: item.account.iconKey,
                        colorValue: item.account.colorValue,
                      ),
                      title: Text(item.name),
                      subtitle: Text(item.account.currency),
                      trailing: AmountText(
                        amount: item.balance,
                        currency: item.currency,
                        showSign: false,
                        colorize: false,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).pop(item.id);
                      },
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
