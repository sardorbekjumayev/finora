import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/date_labels.dart';
import '../../../../core/utils/money.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/period_summary.dart';

/// O'q yorliqlari uchun qisqa format: `1,2 mln`.
String _axisLabel(double minor, Currency currency) {
  if (minor == 0) return '0';
  return Money.format(
    minor.round(),
    currency: currency,
    compact: true,
    withSymbol: false,
  );
}

/// Seriya nuqtasining o'q yorligi: soat / kun / oy.
String _bucketLabel(
  BuildContext context,
  DateTime start,
  SeriesGranularity granularity,
) {
  return switch (granularity) {
    SeriesGranularity.hour => '${start.hour}',
    SeriesGranularity.day => '${start.day}',
    SeriesGranularity.month => DateLabels.monthShort(context, start),
  };
}

/// Grafiklar balandligi — bitta ekranda ikkitasi ham sig'adi.
const double _chartHeight = 190;

// ---------------------------------------------------------------------------
// Kategoriyalar bo'yicha donut
// ---------------------------------------------------------------------------

/// Chiqim/kirim taqsimoti. Bo'laklarda yozuv yo'q — nomlar pastdagi
/// ro'yxatda, shunda kichik bo'laklar ham o'qilishi oson bo'ladi.
class CategoryDonut extends StatefulWidget {
  const CategoryDonut({
    required this.slices,
    required this.categories,
    required this.currency,
    required this.total,
    required this.hidden,
    super.key,
    this.diameter = 220,
    this.centerLabel,
  });

  final List<CategorySlice> slices;
  final Map<int, Category> categories;
  final Currency currency;
  final int total;
  final bool hidden;

  /// Maketdagi donut 132px — kartochka ichida legenda yonida turadi.
  final double diameter;

  /// Markazdagi yorliq; berilmasa "Kategoriyalar bo'yicha".
  final String? centerLabel;

  @override
  State<CategoryDonut> createState() => _CategoryDonutState();
}

class _CategoryDonutState extends State<CategoryDonut> {
  int? _touched;

  Color _colorFor(FinoraPalette palette, int? categoryId, int index) {
    final category = categoryId == null ? null : widget.categories[categoryId];
    if (category != null) return palette.adapt(Color(category.colorValue));
    // Kategoriyasiz yoki o'chirilgan kategoriya — temaga mos palitradan.
    return palette.chart[index % palette.chart.length];
  }

  String _nameFor(AppL10n l10n, int? categoryId) =>
      widget.categories[categoryId]?.name ?? l10n.txNoCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;

    final focused = _touched != null && _touched! < widget.slices.length
        ? widget.slices[_touched!]
        : null;

    // Maketda halqa qalinligi diametrning ~13%i, markaz esa qolgani.
    final thickness = widget.diameter * 0.135;
    final centerRadius = widget.diameter / 2 - thickness;

    return SizedBox(
      width: widget.diameter,
      height: widget.diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: centerRadius,
              startDegreeOffset: -90,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  final index = response?.touchedSection?.touchedSectionIndex;
                  if (index == _touched) return;
                  if (event is FlTapUpEvent || event is FlPanEndEvent) {
                    HapticFeedback.selectionClick();
                  }
                  setState(() => _touched = index == -1 ? null : index);
                },
              ),
              sections: [
                for (var i = 0; i < widget.slices.length; i++)
                  PieChartSectionData(
                    value: widget.slices[i].amount.toDouble(),
                    color: _colorFor(palette, widget.slices[i].categoryId, i),
                    radius: _touched == i ? thickness * 1.3 : thickness,
                    showTitle: false,
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: thickness),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  focused == null
                      ? (widget.centerLabel ?? l10n.statByCategory)
                      : _nameFor(l10n, focused.categoryId),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.tiny.copyWith(color: palette.textMuted),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.hidden
                        ? '••••'
                        : Money.format(
                            focused?.amount ?? widget.total,
                            currency: widget.currency,
                            compact: true,
                          ),
                    style: AppText.rowAmount.copyWith(
                      color: palette.textPrimary,
                    ),
                  ),
                ),
                if (focused != null)
                  Text(
                    l10n.statShareOfTotal(
                      (focused.share * 100).toStringAsFixed(1),
                    ),
                    style: AppText.tiny.copyWith(color: palette.primary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kirim va chiqim — ustunli grafik
// ---------------------------------------------------------------------------

class IncomeExpenseBarChart extends StatelessWidget {
  const IncomeExpenseBarChart({
    required this.series,
    required this.granularity,
    required this.currency,
    super.key,
  });

  final List<SeriesPoint> series;
  final SeriesGranularity granularity;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final labelStyle = AppText.tiny.copyWith(color: palette.textMuted);

    var peak = 0;
    for (final point in series) {
      if (point.income > peak) peak = point.income;
      if (point.expense > peak) peak = point.expense;
    }
    final maxY = peak == 0 ? 1.0 : peak * 1.18;
    // 25 dan ortiq ustun bo'lsa yorliqlar ustma-ust tushadi.
    final labelStep = (series.length / 8).ceil().clamp(1, 1000);

    // Maketdagi ustunlar yo'g'on (22px). Kun soni ko'p bo'lsa sig'maydi,
    // shuning uchun kenglik nuqtalar soniga qarab tanlanadi.
    final barWidth = switch (series.length) {
      <= 8 => 14.0,
      <= 16 => 9.0,
      _ => 6.0,
    };

    return SizedBox(
      height: _chartHeight,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          alignment: BarChartAlignment.spaceBetween,
          barTouchData: const BarTouchData(enabled: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: palette.border,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 46,
                interval: maxY / 4,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(_axisLabel(value, currency), style: labelStyle),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (index < 0 || index >= series.length) {
                    return const SizedBox.shrink();
                  }
                  if (index % labelStep != 0) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      _bucketLabel(context, series[index].start, granularity),
                      style: labelStyle,
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < series.length; i++)
              BarChartGroupData(
                x: i,
                barsSpace: 2,
                barRods: [
                  BarChartRodData(
                    toY: series[i].income.toDouble(),
                    color: palette.income,
                    width: barWidth,
                    borderRadius: BorderRadius.circular(barWidth / 2.5),
                  ),
                  BarChartRodData(
                    toY: series[i].expense.toDouble(),
                    color: palette.expense,
                    width: barWidth,
                    borderRadius: BorderRadius.circular(barWidth / 2.5),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Balans dinamikasi — chiziqli grafik
// ---------------------------------------------------------------------------

class BalanceTrendChart extends StatelessWidget {
  const BalanceTrendChart({
    required this.series,
    required this.granularity,
    required this.openingBalance,
    required this.currency,
    super.key,
  });

  final List<SeriesPoint> series;
  final SeriesGranularity granularity;

  /// Davr boshidagi qoldiq — chiziq shu nuqtadan boshlanadi.
  final int openingBalance;

  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final labelStyle = AppText.tiny.copyWith(color: palette.textMuted);

    final spots = <FlSpot>[];
    var running = openingBalance;
    var lowest = openingBalance;
    var highest = openingBalance;
    for (var i = 0; i < series.length; i++) {
      running += series[i].net;
      if (running < lowest) lowest = running;
      if (running > highest) highest = running;
      spots.add(FlSpot(i.toDouble(), running.toDouble()));
    }

    if (spots.length < 2) {
      return SizedBox(
        height: _chartHeight,
        child: Center(
          child: Text(AppL10n.of(context).statEmptyTitle, style: labelStyle),
        ),
      );
    }

    // Chiziq chetlarga tegib ketmasligi uchun 10% bo'sh joy.
    final span = (highest - lowest).abs();
    final padding = span == 0 ? (highest.abs() * 0.1 + 1) : span * 0.1;
    final minY = lowest - padding;
    final maxY = highest + padding;
    final interval = (maxY - minY) / 4;
    final labelStep = (series.length / 8).ceil().clamp(1, 1000);

    return SizedBox(
      height: _chartHeight,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (series.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          lineTouchData: const LineTouchData(enabled: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (value) => FlLine(
              color: palette.border,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 46,
                interval: interval,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(_axisLabel(value, currency), style: labelStyle),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (index < 0 || index >= series.length) {
                    return const SizedBox.shrink();
                  }
                  if (index % labelStep != 0) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      _bucketLabel(context, series[index].start, granularity),
                      style: labelStyle,
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.2,
              preventCurveOverShooting: true,
              color: palette.primary,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: palette.primary.withValues(alpha: 0.14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
