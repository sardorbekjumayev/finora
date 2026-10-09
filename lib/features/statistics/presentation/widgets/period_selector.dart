import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/date_labels.dart';
import '../../../../core/utils/date_range.dart';
import '../../../../core/widgets/design_kit.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../period_providers.dart';

String periodTypeLabel(AppL10n l10n, PeriodType type) => switch (type) {
      PeriodType.day => l10n.statPeriodDay,
      PeriodType.week => l10n.statPeriodWeek,
      PeriodType.month => l10n.statPeriodMonth,
      PeriodType.year => l10n.statPeriodYear,
      PeriodType.custom => l10n.statPeriodCustom,
    };

/// Davr filtri (`plan/Statistika.dc.html`): kulrang yo'lka ichidagi
/// segmentlar + ostida oldingi/keyingi davrga o'tish qatori.
///
/// Maketda uch segment (Hafta / Oy / Yil) ko'rsatilgan; "Kun" ham shu
/// yo'lkada turadi, "Maxsus oraliq" esa sana yorlig'ini bosganda ochiladi.
class PeriodSelector extends ConsumerWidget {
  const PeriodSelector({super.key});

  static const _segments = [
    PeriodType.day,
    PeriodType.week,
    PeriodType.month,
    PeriodType.year,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final range = ref.watch(periodProvider);
    final controller = ref.read(periodProvider.notifier);
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDims.pagePadding,
          ),
          child: SegmentedTrack<PeriodType>(
            segments: [
              for (final type in _segments) (type, periodTypeLabel(l10n, type)),
            ],
            selected: range.type,
            onChanged: controller.setType,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDims.pagePadding - 8,
            4,
            AppDims.pagePadding - 8,
            0,
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  controller.previous();
                },
                tooltip: l10n.actionPrevious,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _pickCustom(context, ref, range),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      DateLabels.rangeLabel(context, range),
                      textAlign: TextAlign.center,
                      style: AppText.label.copyWith(color: palette.textPrimary),
                    ),
                  ),
                ),
              ),
              IconButton(
                // Kelajakdagi davrga o'tishdan ma'no yo'q.
                onPressed: controller.canGoNext
                    ? () {
                        HapticFeedback.selectionClick();
                        controller.next();
                      }
                    : null,
                tooltip: l10n.actionNext,
                icon: Icon(
                  Icons.chevron_right,
                  color: controller.canGoNext ? null : palette.border,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickCustom(
    BuildContext context,
    WidgetRef ref,
    DateRange current,
  ) async {
    final l10n = AppL10n.of(context);
    final now = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: DateTimeRange(
        start: current.start,
        end: current.end.subtract(const Duration(days: 1)),
      ),
      helpText: l10n.statPickRange,
    );
    if (picked == null) return;

    ref.read(periodProvider.notifier).setCustom(picked.start, picked.end);
  }
}
