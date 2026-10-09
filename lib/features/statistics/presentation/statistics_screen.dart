import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/utils/date_labels.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/design_kit.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/icon_color_picker.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../accounts/data/account_repository.dart';
import '../../categories/data/category_repository.dart';
import '../../transactions/data/transaction_filter.dart';
import '../../transactions/presentation/transactions_screen.dart';
import '../data/currency_converter.dart';
import '../domain/period_summary.dart';
import 'period_providers.dart';
import 'widgets/period_selector.dart';
import 'widgets/stat_charts.dart';

/// Statistika (`plan/Statistika.dc.html`): davr segmentlari, donut +
/// legenda, ustunli grafik va ko'rsatkich plitkalari — bitta uzun oqimda.
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  /// Donut va kategoriya ro'yxati kirimni ko'rsatsinmi.
  bool _showIncome = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final range = ref.watch(periodProvider);
    final summary = ref.watch(periodSummaryProvider(range));

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(title: l10n.statTitle),
            const PeriodSelector(),
            const SizedBox(height: 4),
            Expanded(
              child: switch (summary) {
                null => const Center(child: CircularProgressIndicator()),
                final value when value.isEmpty => EmptyState(
                    icon: Icons.insert_chart_outlined,
                    title: l10n.statEmptyTitle,
                    message: l10n.statEmptyBody,
                  ),
                final value => _Body(
                    summary: value,
                    showIncome: _showIncome,
                    onKindChanged: (income) =>
                        setState(() => _showIncome = income),
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.summary,
    required this.showIncome,
    required this.onKindChanged,
  });

  final PeriodSummary summary;
  final bool showIncome;
  final ValueChanged<bool> onKindChanged;

  static const _gutter = EdgeInsets.symmetric(
    horizontal: AppDims.pagePadding,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final currency = ref.watch(settingsProvider).mainCurrency;
    final hidden = !ref.watch(balanceVisibleProvider);
    final categories = ref.watch(categoryMapProvider);
    final comparison = ref.watch(periodComparisonProvider);
    final opening = ref.watch(openingBalanceProvider(summary.range.start));

    final slices =
        showIncome ? summary.incomeByCategory : summary.expenseByCategory;
    final sliceTotal = showIncome ? summary.income : summary.expense;
    final savingsRate = summary.savingsRate;

    return ListView(
      padding: const EdgeInsets.only(bottom: AppDims.navBarClearance),
      children: [
        _MissingRateBanner(currencies: summary.currencies),
        const SizedBox(height: 12),

        // Jami kirim / chiqim / sof natija.
        Padding(
          padding: _gutter,
          child: DesignCard(
            child: Column(
              children: [
                _TotalRow(
                  label: l10n.statTotalIncome,
                  amount: summary.income,
                  type: TransactionType.income,
                  currency: currency,
                  hidden: hidden,
                  change: comparison?.incomeChange,
                ),
                const Divider(height: 24),
                _TotalRow(
                  label: l10n.statTotalExpense,
                  amount: summary.expense,
                  type: TransactionType.expense,
                  currency: currency,
                  hidden: hidden,
                  change: comparison?.expenseChange,
                  // Chiqimning o'sishi yaxshi xabar emas.
                  higherIsBetter: false,
                ),
                const Divider(height: 24),
                _TotalRow(
                  label: l10n.statNet,
                  amount: summary.net,
                  type: summary.net >= 0
                      ? TransactionType.income
                      : TransactionType.expense,
                  currency: currency,
                  hidden: hidden,
                  showSign: false,
                ),
              ],
            ),
          ),
        ),

        // Ko'rsatkich plitkalari — maketdagi ikki ustunli to'r.
        const SizedBox(height: 12),
        Padding(
          padding: _gutter,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: l10n.statAvgPerDay,
                      value: hidden
                          ? '••••'
                          : Money.format(
                              summary.averageDailyExpense,
                              currency: currency,
                              compact: true,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                      label: l10n.statSavingsRate,
                      value: savingsRate == null
                          ? '—'
                          : '${(savingsRate * 100).round()}%',
                      valueColor: savingsRate == null
                          ? null
                          : (savingsRate >= 0
                              ? context.incomeColor
                              : context.expenseColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: l10n.statBiggestExpense,
                      value: summary.biggestExpense == null
                          ? '—'
                          : (hidden
                              ? '••••'
                              : Money.format(
                                  summary.biggestExpense!.amount,
                                  currency: Currency.byCode(
                                    summary.biggestExpense!.currency,
                                  ),
                                  compact: true,
                                )),
                      footnote: summary.biggestExpense == null
                          ? null
                          : DateLabels.shortDate(
                              context,
                              summary.biggestExpense!.date,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                      label: l10n.statTopCategory,
                      value: categories[summary.topExpenseCategoryId]?.name ??
                          (summary.topExpenseCategoryId == null
                              ? '—'
                              : l10n.txNoCategory),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Kategoriyalar bo'yicha donut + legenda.
        const SizedBox(height: 20),
        SectionTitle(l10n.statByCategory),
        const SizedBox(height: 8),
        Padding(
          padding: _gutter,
          child: SegmentedTrack<bool>(
            segments: [(false, l10n.txExpense), (true, l10n.txIncome)],
            selected: showIncome,
            onChanged: onKindChanged,
          ),
        ),
        const SizedBox(height: 12),
        if (slices.isEmpty)
          Padding(
            padding: _gutter,
            child: DesignCard(
              child: EmptyState(
                compact: true,
                icon: Icons.donut_large_outlined,
                title: l10n.statEmptyTitle,
              ),
            ),
          )
        else ...[
          Padding(
            padding: _gutter,
            child: DesignCard(
              child: Row(
                children: [
                  CategoryDonut(
                    slices: slices,
                    categories: categories,
                    currency: currency,
                    total: sliceTotal,
                    hidden: hidden,
                    diameter: 132,
                    centerLabel: showIncome ? l10n.txIncome : l10n.txExpense,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _Legend(
                      slices: slices,
                      categories: categories,
                      l10n: l10n,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: _gutter,
            child: DesignCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  for (final slice in slices)
                    _ShareRow(
                      iconKey: categories[slice.categoryId]?.iconKey ?? 'other',
                      colorValue: categories[slice.categoryId]?.colorValue ??
                          AppColors.neutral.toARGB32(),
                      name: categories[slice.categoryId]?.name ??
                          l10n.txNoCategory,
                      amount: slice.amount,
                      share: slice.share,
                      currency: currency,
                      hidden: hidden,
                      onTap: slice.categoryId == null
                          ? null
                          : () => _openCategory(ref, context, slice.categoryId!),
                    ),
                ],
              ),
            ),
          ),
        ],

        // Kirim va chiqim ustunlari.
        const SizedBox(height: 20),
        SectionTitle(l10n.statIncomeVsExpense),
        const SizedBox(height: 8),
        Padding(
          padding: _gutter,
          child: DesignCard(
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 12),
            child: Column(
              children: [
                IncomeExpenseBarChart(
                  series: summary.series,
                  granularity: summary.granularity,
                  currency: currency,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ChartLegendItem(
                      color: context.incomeColor,
                      label: l10n.txIncome,
                    ),
                    const SizedBox(width: 20),
                    _ChartLegendItem(
                      color: context.expenseColor,
                      label: l10n.txExpense,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Balans dinamikasi.
        const SizedBox(height: 20),
        SectionTitle(l10n.statBalanceTrend),
        const SizedBox(height: 8),
        Padding(
          padding: _gutter,
          child: DesignCard(
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 12),
            child: opening.hasValue
                ? BalanceTrendChart(
                    series: summary.series,
                    granularity: summary.granularity,
                    openingBalance: opening.requireValue,
                    currency: currency,
                  )
                : const SizedBox(
                    height: 190,
                    child: Center(child: CircularProgressIndicator()),
                  ),
          ),
        ),

        // Hisoblar bo'yicha taqsimot.
        if (summary.byAccount.isNotEmpty) ...[
          const SizedBox(height: 20),
          SectionTitle(l10n.statByAccount),
          const SizedBox(height: 8),
          _ByAccountList(
            byAccount: summary.byAccount,
            total: summary.expense,
            currency: currency,
            hidden: hidden,
          ),
        ],
      ],
    );
  }

  /// Kategoriya ichiga kirish — shu davrdagi barcha yozuvlari.
  void _openCategory(WidgetRef ref, BuildContext context, int categoryId) {
    ref.read(txFilterProvider.notifier).replace(
          TransactionFilter(
            range: ref.read(periodProvider),
            categoryIds: {categoryId},
          ),
        );
    context.go(Routes.transactions);
  }
}

/// Donut yonidagi legenda: 12×12 nuqta, nom va foiz (maketdagi tartib).
class _Legend extends StatelessWidget {
  const _Legend({
    required this.slices,
    required this.categories,
    required this.l10n,
  });

  final List<CategorySlice> slices;
  final Map<int, Category> categories;
  final AppL10n l10n;

  /// Maketda to'rtta qator — qolgani "Boshqa"ga yig'iladi.
  static const _visible = 4;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final shown = slices.take(_visible).toList();
    final restShare =
        slices.skip(_visible).fold<double>(0, (sum, s) => sum + s.share);

    Widget row(Color color, String name, double share) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              LegendDot(color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.small.copyWith(color: palette.textPrimary),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${(share * 100).round()}%',
                style: AppText.small.copyWith(color: palette.textPrimary),
              ),
            ],
          ),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final slice in shown)
          row(
            palette.adapt(
              Color(
                categories[slice.categoryId]?.colorValue ??
                    AppColors.neutral.toARGB32(),
              ),
            ),
            categories[slice.categoryId]?.name ?? l10n.txNoCategory,
            slice.share,
          ),
        if (restShare > 0)
          row(palette.neutral, l10n.accTypeOther, restShare),
      ],
    );
  }
}

/// Davrda kurs topilmagan valyuta bo'lsa ogohlantiradi — aks holda
/// raqamlar jimgina noto'g'ri bo'lib qolardi.
class _MissingRateBanner extends ConsumerWidget {
  const _MissingRateBanner({required this.currencies});

  final Set<String> currencies;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final converter = ref.watch(currencyConverterProvider).value;
    if (converter == null || !converter.hasMissingRate(currencies)) {
      return const SizedBox.shrink();
    }

    final l10n = AppL10n.of(context);
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDims.pagePadding,
        12,
        AppDims.pagePadding,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: palette.expenseTint,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              Icons.currency_exchange_outlined,
              size: 18,
              color: palette.expense,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.statMissingRate,
                style: AppText.hint.copyWith(color: palette.expense),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.amount,
    required this.type,
    required this.currency,
    required this.hidden,
    this.change,
    this.showSign = true,
    this.higherIsBetter = true,
  });

  final String label;
  final int amount;
  final TransactionType type;
  final Currency currency;
  final bool hidden;

  /// Oldingi davrga nisbatan o'zgarish (0.12 = +12%).
  final double? change;

  final bool showSign;
  final bool higherIsBetter;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      children: [
        Icon(TxVisuals.icon(type), size: 18, color: palette.textMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppText.label.copyWith(color: palette.textMuted),
              ),
              if (change != null) ...[
                const SizedBox(height: 2),
                _ChangeChip(change: change!, higherIsBetter: higherIsBetter),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: AmountText(
              amount: amount,
              currency: currency,
              type: type,
              hidden: hidden,
              showSign: showSign,
              style: AppText.strong,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChangeChip extends StatelessWidget {
  const _ChangeChip({required this.change, required this.higherIsBetter});

  final double change;
  final bool higherIsBetter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final grew = change > 0;
    final good = grew == higherIsBetter;
    final color = change == 0
        ? palette.textMuted
        : (good ? palette.income : palette.expense);
    final percent = (change.abs() * 100).round();

    return Row(
      children: [
        Icon(
          change == 0
              ? Icons.remove
              : (grew ? Icons.arrow_upward : Icons.arrow_downward),
          size: 12,
          color: color,
        ),
        const SizedBox(width: 2),
        Text(
          '$percent%  ${l10n.statVsPrevious}',
          style: AppText.tiny.copyWith(color: color),
        ),
      ],
    );
  }
}

class _ByAccountList extends ConsumerWidget {
  const _ByAccountList({
    required this.byAccount,
    required this.total,
    required this.currency,
    required this.hidden,
  });

  final Map<int, int> byAccount;
  final int total;
  final Currency currency;
  final bool hidden;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(allAccountsProvider).value;
    if (accounts == null) return const SizedBox.shrink();

    final byId = {for (final item in accounts) item.id: item};
    final entries = byAccount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDims.pagePadding),
      child: DesignCard(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            for (final entry in entries)
              if (byId[entry.key] case final account?)
                _ShareRow(
                  iconKey: account.account.iconKey,
                  colorValue: account.account.colorValue,
                  name: account.name,
                  amount: entry.value,
                  share: total == 0 ? 0 : entry.value / total,
                  currency: currency,
                  hidden: hidden,
                ),
          ],
        ),
      ),
    );
  }
}

/// Nomi + ulush progressi + summa. Kategoriya va hisob ro'yxatlari uchun.
class _ShareRow extends StatelessWidget {
  const _ShareRow({
    required this.iconKey,
    required this.colorValue,
    required this.name,
    required this.amount,
    required this.share,
    required this.currency,
    required this.hidden,
    this.onTap,
  });

  final String iconKey;
  final int colorValue;
  final String name;
  final int amount;
  final double share;
  final Currency currency;
  final bool hidden;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            IconBadge(iconKey: iconKey, colorValue: colorValue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.rowTitle.copyWith(
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ProgressBar(
                    value: share,
                    height: 6,
                    color: palette.adapt(Color(colorValue)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AmountText(
                  amount: amount,
                  currency: currency,
                  hidden: hidden,
                  showSign: false,
                  colorize: false,
                  style: AppText.rowAmount,
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.statShareOfTotal((share * 100).toStringAsFixed(1)),
                  style: AppText.tiny.copyWith(color: palette.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartLegendItem extends StatelessWidget {
  const _ChartLegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        LegendDot(color, size: 10),
        const SizedBox(width: 6),
        Text(label, style: AppText.small.copyWith(color: palette.textMuted)),
      ],
    );
  }
}
