import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../database/enums.dart';
import '../utils/money.dart';

/// Pul summasi: katta, tabular raqamlar + ishora + rang.
///
/// Rang yolg'iz ma'no tashimasligi uchun `+`/`−` ishorasi ham chiqadi,
/// `Semantics` esa screen reader uchun to'liq matn beradi.
class AmountText extends StatelessWidget {
  const AmountText({
    required this.amount,
    required this.currency,
    super.key,
    this.type,
    this.style,
    this.hidden = false,
    this.compact = false,
    this.showSign = true,
    this.colorize = true,
  });

  final int amount;
  final Currency currency;

  /// Berilgan bo'lsa rang va ishora shu turdan olinadi.
  final TransactionType? type;

  final TextStyle? style;

  /// Balansni yashirish rejimi.
  final bool hidden;
  final bool compact;
  final bool showSign;
  final bool colorize;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? Theme.of(context).textTheme.titleMedium;
    final effectiveStyle = baseStyle?.copyWith(
      color: colorize && type != null
          ? context.colorForTxType(type!)
          : baseStyle.color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    if (hidden) {
      return Text('••••••', style: effectiveStyle);
    }

    final sign = showSign && type != null ? TxVisuals.sign(type!) : '';
    final text = Money.format(
      amount,
      currency: currency,
      compact: compact,
      forcedSign: sign.isEmpty ? null : sign,
    );

    return Semantics(
      label: text,
      excludeSemantics: true,
      child: Text(text, style: effectiveStyle, maxLines: 1),
    );
  }
}
