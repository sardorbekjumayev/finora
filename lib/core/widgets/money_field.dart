import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/generated/app_localizations.dart';
import '../utils/amount_expression.dart';
import '../utils/money.dart';

/// Summa kiritish maydoni. Ichida oddiy kalkulyator ishlaydi:
/// `12000+5000*2` yozilsa, pastda natija ko'rinadi va saqlashda shu olinadi.
class MoneyField extends StatefulWidget {
  const MoneyField({
    required this.controller,
    required this.currency,
    super.key,
    this.label,
    this.autofocus = false,
    this.large = false,
    this.validator,
    this.onSubmitted,
    this.textInputAction,
  });

  final TextEditingController controller;
  final Currency currency;
  final String? label;
  final bool autofocus;

  /// Katta raqamli ko'rinish — tranzaksiya formasining asosiy maydoni uchun.
  final bool large;

  final String? Function(String?)? validator;
  final VoidCallback? onSubmitted;
  final TextInputAction? textInputAction;

  /// Matndan minor unit'ni oladi. Kalkulyator ifodasi ham qo'llanadi.
  static int? toMinor(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    final value = AmountExpression.evaluate(trimmed);
    if (value == null) return null;
    return (value * kMinorUnits).round();
  }

  @override
  State<MoneyField> createState() => _MoneyFieldState();
}

class _MoneyFieldState extends State<MoneyField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final text = widget.controller.text;

    final showResult = AmountExpression.hasOperator(text);
    final minor = MoneyField.toMinor(text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.controller,
          autofocus: widget.autofocus,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: widget.large ? TextAlign.center : TextAlign.start,
          textInputAction: widget.textInputAction ?? TextInputAction.next,
          onFieldSubmitted: (_) => widget.onSubmitted?.call(),
          validator: widget.validator,
          style: widget.large
              ? theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                )
              : theme.textTheme.titleLarge?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-*/().,]')),
          ],
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: '0',
            suffixText: widget.currency.symbol,
            suffixStyle: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            contentPadding: widget.large
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 20)
                : null,
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.topCenter,
          child: showResult && minor != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    l10n.txCalcResult(
                      Money.format(minor, currency: widget.currency),
                    ),
                    textAlign:
                        widget.large ? TextAlign.center : TextAlign.start,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
