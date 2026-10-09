import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/database/enums.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../../core/widgets/design_kit.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../accounts/data/account_repository.dart';
import '../../statistics/data/statistics_repository.dart';
import '../../statistics/presentation/period_providers.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transactions/presentation/widgets/transaction_tile.dart';

/// Bosh sahifa (`plan/Main.dc.html`): logo + sarlavha, to'q balans kartasi,
/// gorizontal hisob kartochkalari, jamg'arma progressi va oxirgi yozuvlar.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final settings = ref.watch(settingsProvider);
    final visible = ref.watch(balanceVisibleProvider);
    final accounts = ref.watch(accountsProvider);
    final recent = ref.watch(recentTransactionsProvider);
    final total = ref.watch(totalBalanceProvider).value;
    final summary = ref.watch(currentMonthSummaryProvider);

    final accountList = accounts.value ?? const <AccountWithBalance>[];
    final recentList = recent.value ?? const <TxWithRefs>[];
    final isFresh = accountList.isEmpty && recentList.isEmpty;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: l10n.appTitle,
              leading: const BrandMark(size: 30),
              titleStyle: AppText.wordmark(24),
              actions: [
                RoundIconButton(
                  icon: Icons.search,
                  tooltip: l10n.actionSearch,
                  onPressed: () => context.go(Routes.transactions),
                ),
                RoundIconButton(
                  icon: Icons.settings_outlined,
                  tooltip: l10n.setTitle,
                  onPressed: () => context.push(Routes.settings),
                ),
              ],
            ),
            Expanded(
              child: isFresh && accounts.hasValue && recent.hasValue
                  ? EmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: l10n.dashEmptyTitle,
                      message: l10n.dashEmptyBody,
                      actionLabel: l10n.dashAddFirst,
                      onAction: () => context.push(Routes.txNew),
                    )
                  : ListView(
                      padding: const EdgeInsets.only(
                        bottom: AppDims.navBarClearance,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDims.pagePadding,
                          ),
                          child: _TotalBalanceCard(
                            total: total,
                            income: summary?.income,
                            expense: summary?.expense,
                            currency: settings.mainCurrency,
                            hidden: !visible,
                            onToggleHidden: () {
                              HapticFeedback.selectionClick();
                              ref
                                  .read(balanceVisibleProvider.notifier)
                                  .toggle();
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        _AccountsStrip(
                          accounts: accountList,
                          hidden: !visible,
                        ),
                        if (summary != null) ...[
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDims.pagePadding,
                            ),
                            child: _SavingsCard(
                              income: summary.income,
                              net: summary.net,
                              rate: summary.savingsRate,
                              currency: settings.mainCurrency,
                              hidden: !visible,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        SectionTitle(
                          l10n.dashRecent,
                          actionLabel: l10n.labelAll,
                          onAction: () => context.go(Routes.transactions),
                        ),
                        if (recentList.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDims.pagePadding,
                            ),
                            child: _RecentEmpty(),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDims.pagePadding,
                            ),
                            child: Column(
                              children: [
                                for (final item in recentList)
                                  TransactionTile(
                                    item: item,
                                    hidden: !visible,
                                    onTap: () => context
                                        .push(Routes.txDetails(item.tx.id)),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentEmpty extends StatelessWidget {
  const _RecentEmpty();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return DesignCard(
      child: EmptyState(
        compact: true,
        icon: Icons.receipt_long_outlined,
        title: l10n.dashEmptyTitle,
        actionLabel: l10n.dashAddFirst,
        onAction: () => context.push(Routes.txNew),
      ),
    );
  }
}

/// Umumiy balans: to'q fon, ko'z tugmasi va oy kirim/chiqim pillari.
class _TotalBalanceCard extends StatelessWidget {
  const _TotalBalanceCard({
    required this.total,
    required this.income,
    required this.expense,
    required this.currency,
    required this.hidden,
    required this.onToggleHidden,
  });

  final int? total;
  final int? income;
  final int? expense;
  final Currency currency;
  final bool hidden;
  final VoidCallback onToggleHidden;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final onHero = context.palette.onHero;

    return HeroCard(
      label: l10n.dashTotalBalance,
      trailing: RoundIconButton(
        icon: hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        tooltip: hidden ? l10n.dashShowBalance : l10n.dashHideBalance,
        onPressed: onToggleHidden,
        filled: false,
        foreground: onHero,
      ),
      amount: total == null
          ? SizedBox(
              height: 40,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: onHero,
                  ),
                ),
              ),
            )
          : FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: AmountText(
                amount: total!,
                currency: currency,
                hidden: hidden,
                colorize: false,
                showSign: false,
                style: AppText.amountHero.copyWith(color: onHero),
              ),
            ),
      pills: [
        HeroPill(
          icon: TxVisuals.icon(TransactionType.income),
          label: l10n.dashIncome,
          value: AmountText(
            amount: income ?? 0,
            currency: currency,
            hidden: hidden,
            colorize: false,
            showSign: false,
            style: AppText.pillValue.copyWith(color: onHero),
          ),
        ),
        HeroPill(
          icon: TxVisuals.icon(TransactionType.expense),
          label: l10n.dashExpense,
          value: AmountText(
            amount: expense ?? 0,
            currency: currency,
            hidden: hidden,
            colorize: false,
            showSign: false,
            style: AppText.pillValue.copyWith(color: onHero),
          ),
        ),
      ],
    );
  }
}

/// Maketdagi byudjet kartasining o'rni. Byudjetlar moduli hali yo'q
/// (rejada v1.0), shuning uchun shu joyda joriy oyning jamg'arma
/// foizi ko'rsatiladi — bir xil ko'rinish, bor ma'lumot.
class _SavingsCard extends StatelessWidget {
  const _SavingsCard({
    required this.income,
    required this.net,
    required this.rate,
    required this.currency,
    required this.hidden,
  });

  final int income;
  final int net;
  final double? rate;
  final Currency currency;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final positive = net >= 0;

    return DesignCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.statSavingsRate,
                  style: AppText.label.copyWith(color: palette.textPrimary),
                ),
              ),
              Text(
                hidden
                    ? '••••'
                    : '${Money.format(net, currency: currency, compact: true, withSymbol: false)}'
                        ' / '
                        '${Money.format(income, currency: currency, compact: true, withSymbol: false)}',
                style: AppText.label.copyWith(color: palette.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ProgressBar(
            value: rate == null ? 0 : rate!.clamp(0.0, 1.0),
            color: positive ? palette.primary : palette.expense,
          ),
        ],
      ),
    );
  }
}

/// Gorizontal hisob kartochkalari: 150px kenglik, rangli ikonka,
/// 13/700 nom va 17/800 qoldiq.
class _AccountsStrip extends StatelessWidget {
  const _AccountsStrip({required this.accounts, required this.hidden});

  final List<AccountWithBalance> accounts;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDims.pagePadding),
        itemCount: accounts.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == accounts.length) {
            return _AddAccountCard(
              onTap: () => context.push(Routes.accountNew),
            );
          }
          final item = accounts[index];
          return SizedBox(
            width: AppDims.accountCard,
            child: DesignCard(
              padding: const EdgeInsets.all(14),
              onTap: () => context.push(Routes.accountEdit(item.id)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    AppIcons.resolve(item.account.iconKey),
                    size: 22,
                    color: palette.adapt(Color(item.account.colorValue)),
                  ),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.small.copyWith(color: palette.textMuted),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: AmountText(
                      amount: item.balance,
                      currency: item.currency,
                      hidden: hidden,
                      showSign: false,
                      colorize: false,
                      style: AppText.accountAmount.copyWith(
                        color: item.balance < 0
                            ? palette.expense
                            : palette.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AddAccountCard extends StatelessWidget {
  const _AddAccountCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return SizedBox(
      width: 120,
      child: DashedButton(
        label: l10n.accNew,
        onPressed: onTap,
        radius: AppDims.card,
        vertical: true,
      ),
    );
  }
}
