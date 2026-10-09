import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/database/enums.dart';
import '../../../../core/utils/date_labels.dart';
import '../../../../core/widgets/amount_text.dart';
import '../../../../core/widgets/design_kit.dart';
import '../../../../core/widgets/icon_color_picker.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/transaction_repository.dart';

/// Ro'yxatdagi bitta yozuv (`plan/Tarix.dc.html`):
/// 44×44 ikonka plitkasi · nom 15/700 + meta 12/700 · summa 15/800.
///
/// Rang yolg'iz ma'no tashimasligi uchun ikonka va `+`/`−` ishorasi
/// ham birga ishlaydi.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.item,
    super.key,
    this.onTap,
    this.showTime = true,
    this.hidden = false,
  });

  final TxWithRefs item;
  final VoidCallback? onTap;
  final bool showTime;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final tx = item.tx;
    final isTransfer = tx.type == TransactionType.transfer;

    final title = isTransfer
        ? '${item.account.name} → ${item.toAccount?.name ?? '—'}'
        : item.category?.name ?? l10n.txNoCategory;

    final meta = <String>[
      if (isTransfer) l10n.txTransfer else item.account.name,
      if (showTime) DateLabels.time(context, tx.date),
      if ((tx.note ?? '').trim().isNotEmpty) tx.note!.trim(),
    ].join(' · ');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            if (isTransfer)
              IconTile(
                icon: TxVisuals.icon(TransactionType.transfer),
                color: palette.transfer,
                background: palette.transferTint,
              )
            else
              IconBadge(
                iconKey: item.category?.iconKey ?? 'other',
                colorValue:
                    item.category?.colorValue ?? palette.neutral.toARGB32(),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.rowTitle.copyWith(
                      color: palette.textPrimary,
                    ),
                  ),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.meta.copyWith(color: palette.textMuted),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AmountText(
                  amount: tx.amount,
                  currency: item.currency,
                  type: tx.type,
                  hidden: hidden,
                  style: AppText.rowAmount,
                ),
                if (isTransfer && item.isCrossCurrency && !hidden) ...[
                  const SizedBox(height: 2),
                  AmountText(
                    amount: item.receivedAmount,
                    currency: item.toCurrency,
                    showSign: false,
                    colorize: false,
                    style: AppText.meta.copyWith(color: palette.textMuted),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
