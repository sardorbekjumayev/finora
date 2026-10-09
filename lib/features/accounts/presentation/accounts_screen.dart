import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/design_kit.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/icon_color_picker.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../statistics/data/statistics_repository.dart';
import '../data/account_repository.dart';
import 'account_editor_screen.dart';
import 'widgets/account_picker.dart';
import 'widgets/reconcile_sheet.dart';

/// Hisoblar ro'yxati (`plan/Hisoblar.dc.html`): jami qoldiq, 48px ikonka
/// plitkali qatorlar va pastda "Balansni to'g'rilash".
class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  bool _showArchived = false;

  Future<void> _archive(AccountWithBalance item) async {
    await ref.read(accountRepositoryProvider).setArchived(
          item.id,
          archived: !item.account.isArchived,
        );
    HapticFeedback.selectionClick();
  }

  Future<void> _delete(AccountWithBalance item) async {
    final l10n = AppL10n.of(context);
    final repo = ref.read(accountRepositoryProvider);
    final count = await repo.transactionCount(item.id);

    if (!mounted) return;

    if (count > 0) {
      final archive = await confirm(
        context,
        title: l10n.accDeleteBlockedTitle,
        message: l10n.accDeleteBlockedBody(count),
        confirmLabel: l10n.actionArchive,
        icon: Icons.inventory_2_outlined,
      );
      if (archive) await repo.setArchived(item.id, archived: true);
      return;
    }

    final ok = await confirm(
      context,
      title: l10n.accDeleteTitle,
      message: l10n.accDeleteBody,
      confirmLabel: l10n.actionDelete,
      destructive: true,
      icon: Icons.delete_outline,
    );
    if (ok) await repo.delete(item.id);
  }

  /// Maketdagi pastki tugma: avval hisob tanlanadi, so'ng to'g'rilash paneli.
  Future<void> _reconcileAny(List<AccountWithBalance> accounts) async {
    final l10n = AppL10n.of(context);
    final id = await showAccountPicker(context, title: l10n.accReconcile);
    if (id == null || !mounted) return;

    final item = accounts.where((a) => a.id == id).firstOrNull;
    if (item == null) return;
    await showReconcileSheet(context, item);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final settings = ref.watch(settingsProvider);
    final visible = ref.watch(balanceVisibleProvider);
    final total = ref.watch(totalBalanceProvider).value;
    final async = ref.watch(
      _showArchived ? allAccountsProvider : accountsProvider,
    );
    final accounts = async.value ?? const <AccountWithBalance>[];
    final palette = context.palette;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: l10n.accTitle,
              actions: [
                RoundIconButton(
                  icon: _showArchived
                      ? Icons.inventory_2
                      : Icons.inventory_2_outlined,
                  tooltip: l10n.accShowArchived,
                  onPressed: () =>
                      setState(() => _showArchived = !_showArchived),
                ),
                RoundIconButton(
                  icon: Icons.add,
                  tooltip: l10n.accNew,
                  onPressed: () => context.push(Routes.accountNew),
                ),
              ],
            ),
            // Jami: 14/700 yorliq + 30/800 summa.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDims.pagePadding,
                0,
                AppDims.pagePadding,
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.labelTotal,
                    style: AppText.label.copyWith(color: palette.textMuted),
                  ),
                  if (total != null)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: AmountText(
                        amount: total,
                        currency: settings.mainCurrency,
                        hidden: !visible,
                        showSign: false,
                        colorize: false,
                        style: AppText.amountLarge
                            .copyWith(color: palette.textPrimary),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: accounts.isEmpty && async.hasValue
                  ? EmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: l10n.accEmptyTitle,
                      message: l10n.accEmptyBody,
                      actionLabel: l10n.accNew,
                      onAction: () => context.push(Routes.accountNew),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppDims.pagePadding,
                        0,
                        AppDims.pagePadding,
                        AppDims.navBarClearance,
                      ),
                      itemCount: accounts.length,
                      // Izoh va tugma ro'yxatdan tashqarida — ularni
                      // surib bo'lmaydi.
                      footer: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ReorderHint(text: l10n.accReorderHint),
                          _ReconcileFooter(
                            onPressed: () => _reconcileAny(accounts),
                          ),
                        ],
                      ),
                      onReorderItem: (fromIndex, toIndex) {
                        final ids = accounts.map((a) => a.id).toList();
                        ids.insert(toIndex, ids.removeAt(fromIndex));
                        HapticFeedback.selectionClick();
                        ref.read(accountRepositoryProvider).reorder(ids);
                      },
                      itemBuilder: (context, index) {
                        final item = accounts[index];
                        return Padding(
                          key: ValueKey('acc-${item.id}'),
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _AccountRow(
                            item: item,
                            hidden: !visible,
                            onEdit: () =>
                                context.push(Routes.accountEdit(item.id)),
                            onReconcile: () => showReconcileSheet(context, item),
                            onArchive: () => _archive(item),
                            onDelete: () => _delete(item),
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

class _ReorderHint extends StatelessWidget {
  const _ReorderHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 6),
      child: Row(
        children: [
          Icon(Icons.drag_indicator, size: 16, color: palette.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppText.hint.copyWith(color: palette.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

/// Maketdagi pastki blok: ramkali tugma + tushuntirish matni.
class _ReconcileFooter extends StatelessWidget {
  const _ReconcileFooter({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.check, size: 22),
            label: Text(l10n.accReconcile),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.accReconcileBody,
            textAlign: TextAlign.center,
            style: AppText.hint.copyWith(color: palette.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Bitta hisob: 48px ikonka plitkasi, nom 16/800, tur 12/700, qoldiq 16/800.
class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.item,
    required this.hidden,
    required this.onEdit,
    required this.onReconcile,
    required this.onArchive,
    required this.onDelete,
  });

  final AccountWithBalance item;
  final bool hidden;
  final VoidCallback onEdit;
  final VoidCallback onReconcile;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final archived = item.account.isArchived;
    final negative = item.balance < 0;

    final subtitle = <String>[
      accountTypeLabel(l10n, item.account.type),
      item.account.currency,
    ].join(' · ');

    return Opacity(
      opacity: archived ? 0.55 : 1,
      child: DesignCard(
        onTap: onEdit,
        child: Row(
          children: [
            IconBadge(
              iconKey: item.account.iconKey,
              colorValue: item.account.colorValue,
              size: AppDims.listIcon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.strong
                              .copyWith(color: palette.textPrimary),
                        ),
                      ),
                      if (archived) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 14,
                          color: palette.textMuted,
                        ),
                      ],
                      if (!item.account.includeInTotal) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.visibility_off_outlined,
                          size: 14,
                          color: palette.textMuted,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.meta.copyWith(color: palette.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AmountText(
              amount: item.balance,
              currency: item.currency,
              hidden: hidden,
              showSign: false,
              colorize: false,
              style: AppText.strong.copyWith(
                color: negative ? palette.expense : palette.textPrimary,
              ),
            ),
            PopupMenuButton<String>(
              tooltip: l10n.navMore,
              icon: Icon(Icons.more_vert, size: 22, color: palette.textMuted),
              onSelected: (value) => switch (value) {
                'edit' => onEdit(),
                'reconcile' => onReconcile(),
                'archive' => onArchive(),
                'delete' => onDelete(),
                _ => null,
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: _MenuRow(
                    icon: Icons.edit_outlined,
                    label: l10n.actionEdit,
                  ),
                ),
                PopupMenuItem(
                  value: 'reconcile',
                  child: _MenuRow(
                    icon: Icons.rule_outlined,
                    label: l10n.accReconcile,
                  ),
                ),
                PopupMenuItem(
                  value: 'archive',
                  child: _MenuRow(
                    icon: Icons.inventory_2_outlined,
                    label: archived ? l10n.actionUnarchive : l10n.actionArchive,
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: _MenuRow(
                    icon: Icons.delete_outline,
                    label: l10n.actionDelete,
                    danger: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? Theme.of(context).colorScheme.error : null;
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}
