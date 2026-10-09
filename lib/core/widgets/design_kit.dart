import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';

/// Maketda qaytalanadigan qurilish bloklari (`plan/*.dc.html`).
///
/// Ekranlar shu vidjetlardan yig'iladi — o'lcham va radiuslar bitta joyda
/// turadi, shuning uchun dizayn bilan farq paydo bo'lmaydi.

/// Ekran sarlavhasi: `24px 20px 12px` ichki masofa, chapda 24/800 matn,
/// o'ngda 44px oq doira tugmalar.
class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    super.key,
    this.actions = const [],
    this.leading,
    this.subtitle,
    this.titleStyle,
  });

  final String title;
  final List<Widget> actions;

  /// Berilsa, sarlavhadan chapda turadi (orqaga tugmasi yoki logo).
  final Widget? leading;

  final Widget? subtitle;

  /// Berilmasa: `leading` bo'lsa 20/800 (forma sarlavhasi), aks holda
  /// 24/800 (ekran sarlavhasi).
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDims.pagePadding,
        24,
        AppDims.pagePadding,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (titleStyle ??
                          (leading == null
                              ? AppText.pageTitle
                              : AppText.sheetTitle))
                      .copyWith(color: palette.textPrimary),
                ),
              ),
              for (final action in actions) ...[
                const SizedBox(width: 8),
                action,
              ],
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            subtitle!,
          ],
        ],
      ),
    );
  }
}

/// Sarlavhadagi 44px oq doira tugma (qidirish, qo'shish).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    super.key,
    this.filled = true,
    this.foreground,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  /// `false` — fonsiz (orqaga tugmasi uchun).
  final bool filled;

  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: InkWell(
          onTap: onPressed == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onPressed!();
                },
          customBorder: const CircleBorder(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: filled ? palette.surface : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 22,
              color: foreground ?? palette.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Oq kartochka: radius 20, soyasiz, ichki masofa 16.
class DesignCard extends StatelessWidget {
  const DesignCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.radius = AppDims.card,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final shape = BorderRadius.circular(radius);

    return Material(
      color: color ?? palette.surface,
      borderRadius: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Umumiy balans kartasi (`plan/Main.dc.html`): to'q fon, radius 24,
/// ichki masofa 20. Ikki temada ham fon to'q — matn doim oq.
class HeroCard extends StatelessWidget {
  const HeroCard({
    required this.label,
    required this.amount,
    super.key,
    this.trailing,
    this.pills = const [],
  });

  final String label;

  /// Summani chaqiruvchi beradi (yashirish rejimi, valyuta formati
  /// ekranda hal qilinadi).
  final Widget amount;

  /// Sarlavha yonidagi tugma — maketda "balansni yashirish" ko'zi.
  final Widget? trailing;

  final List<HeroPill> pills;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final onHero = palette.onHero;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.hero,
        borderRadius: BorderRadius.circular(AppDims.hero),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppText.label.copyWith(color: onHero),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 8),
          amount,
          if (pills.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                for (final (index, pill) in pills.indexed) ...[
                  if (index > 0) const SizedBox(width: 10),
                  Expanded(child: _HeroPillBox(pill: pill, onHero: onHero)),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Balans kartasi ichidagi kichik ko'rsatkich (kirim / chiqim).
class HeroPill {
  const HeroPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final Widget value;
}

class _HeroPillBox extends StatelessWidget {
  const _HeroPillBox({required this.pill, required this.onHero});

  final HeroPill pill;
  final Color onHero;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: onHero.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppDims.tile),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(pill.icon, size: 18, color: onHero),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  pill.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.meta.copyWith(color: onHero),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: pill.value,
          ),
        ],
      ),
    );
  }
}

/// Ro'yxat ustidagi sarlavha: 16/800 matn + o'ngda havola
/// ("Oxirgi yozuvlar — Hammasi").
class SectionTitle extends StatelessWidget {
  const SectionTitle(
    this.title, {
    super.key,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppDims.pagePadding,
    ),
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppText.strong.copyWith(color: palette.textPrimary),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

/// "Chiqim / Kirim / O'tkazma" tanlagichi (`plan/Qoshish.dc.html`):
/// 40px pillar, tanlangani shu turning rangi bilan to'ladi.
class TypePills<T> extends StatelessWidget {
  const TypePills({
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.colorOf,
    super.key,
  });

  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onChanged;

  /// Har bir variantning to'ldirish rangi.
  final Color Function(T) colorOf;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Row(
      children: [
        for (final (index, (value, label)) in options.indexed) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: Semantics(
              button: true,
              selected: value == selected,
              child: GestureDetector(
                onTap: () {
                  if (value == selected) return;
                  HapticFeedback.selectionClick();
                  onChanged(value);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: AppDims.typePill,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: value == selected
                        ? colorOf(value)
                        : palette.surface,
                    borderRadius:
                        BorderRadius.circular(AppDims.typePill / 2),
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.rowValue.copyWith(
                      color: value == selected
                          ? palette.onPrimary
                          : palette.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Summa kiritish klaviaturasi (`plan/Qoshish.dc.html`): 3 ustun,
/// 52px oq plitkalar, 22/800 raqamlar.
class AmountKeypad extends StatelessWidget {
  const AmountKeypad({
    required this.onKey,
    required this.onBackspace,
    super.key,
    this.decimalSeparator = ',',
    this.backspaceTooltip = '',
  });

  /// Bosilgan belgi: `0`–`9` yoki ajratgich.
  final ValueChanged<String> onKey;

  final VoidCallback onBackspace;
  final String decimalSeparator;
  final String backspaceTooltip;

  @override
  Widget build(BuildContext context) {
    final keys = <String>[
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      decimalSeparator, '0', '',
    ];

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        // Maketdagi tugma balandligi — ekran kengligiga bog'liq emas.
        mainAxisExtent: AppDims.keypadTile,
      ),
      children: [
        for (final key in keys)
          if (key.isEmpty)
            _KeypadTile(
              tooltip: backspaceTooltip,
              onTap: onBackspace,
              child: const Icon(Icons.backspace_outlined, size: 22),
            )
          else
            _KeypadTile(
              tooltip: key,
              onTap: () => onKey(key),
              child: Text(key, style: AppText.keypad),
            ),
      ],
    );
  }
}

class _KeypadTile extends StatelessWidget {
  const _KeypadTile({
    required this.child,
    required this.onTap,
    required this.tooltip,
  });

  final Widget child;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      button: true,
      label: tooltip,
      child: Material(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppDims.tile),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDims.tile),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Center(
            child: DefaultTextStyle.merge(
              style: TextStyle(color: palette.textPrimary),
              child: IconTheme.merge(
                data: IconThemeData(color: palette.textPrimary),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartochka ichidagi summa maydoni (`plan/Boshlash.dc.html`):
/// yuqorida ikonka + yorliq, ostida 28/800 raqam va valyuta belgisi.
class InlineAmountCard extends StatelessWidget {
  const InlineAmountCard({
    required this.icon,
    required this.controller,
    required this.currencySymbol,
    super.key,
    this.label,
    this.labelField,
    this.onChanged,
    this.trailing,
  });

  final IconData icon;
  final TextEditingController controller;
  final String currencySymbol;

  /// Qat'iy yorliq ("Naqd pul").
  final String? label;

  /// Yorliq o'rniga tahrirlanadigan maydon (karta nomi).
  final Widget? labelField;

  final VoidCallback? onChanged;

  /// Yorliq qatorining o'ng chetidagi tugma (masalan "o'chirish").
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: palette.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: labelField ??
                    Text(
                      label ?? '',
                      style: AppText.label.copyWith(color: palette.textMuted),
                    ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => onChanged?.call(),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9+\-*/().,]'),
                    ),
                  ],
                  style: AppText.display.copyWith(color: palette.textPrimary),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: AppText.display.copyWith(
                      color: palette.textMuted.withValues(alpha: 0.5),
                    ),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                currencySymbol,
                style: AppText.label.copyWith(color: palette.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Diagramma legendasidagi kvadrat nuqta (12×12, radius 4).
class LegendDot extends StatelessWidget {
  const LegendDot(this.color, {super.key, this.size = 12});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 3),
      ),
    );
  }
}

/// Ikonka plitkasi: yumaloq kvadrat, rangning och foni + to'q ikonkasi.
/// Maketdagi 44×44/r14 (yozuvlar) va 48×48/r16 (hisoblar) o'lchamlari.
class IconTile extends StatelessWidget {
  const IconTile({
    required this.icon,
    required this.color,
    super.key,
    this.size = AppDims.rowIcon,
    this.radius,
    this.background,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double? radius;

  /// Berilmasa, [color]dan och fon hisoblanadi.
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    // Maketdagi plitkalar shaffof emas — fon kartochka rangidan rangga
    // qarab aralashtiriladi, shunda qorong'u temada ham xira chiqmaydi.
    final tint = background ??
        Color.lerp(palette.surface, color, palette.isDark ? 0.26 : 0.14)!;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(radius ?? size * (14 / 44)),
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: palette.adapt(color),
      ),
    );
  }
}

/// Uzuq-uzuq 2px ramka: "bu yerga qo'shish mumkin" ishorasi.
class DashedBox extends StatelessWidget {
  const DashedBox({
    required this.child,
    super.key,
    this.radius = 18,
    this.onTap,
  });

  final Widget child;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return CustomPaint(
      painter: _DashedBorderPainter(
        color: palette.dashed,
        radius: radius,
        strokeWidth: 2,
      ),
      child: onTap == null
          ? child
          : InkWell(
              borderRadius: BorderRadius.circular(radius),
              onTap: () {
                HapticFeedback.selectionClick();
                onTap!();
              },
              child: child,
            ),
    );
  }
}

/// "Yana karta qo'shish" uslubidagi uzuq-uzuq ramkali tugma.
class DashedButton extends StatelessWidget {
  const DashedButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon = Icons.add,
    this.height = AppDims.secondaryButton,
    this.radius = 18,
    this.vertical = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;
  final double height;
  final double radius;

  /// `true` — ikonka matn ustida turadi (tor kartochka uchun).
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final content = <Widget>[
      Icon(icon, size: 22, color: palette.primary),
      SizedBox(width: vertical ? 0 : 8, height: vertical ? 6 : 0),
      Flexible(
        child: Text(
          label,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: AppText.strong.copyWith(color: palette.primary),
        ),
      ),
    ];

    return DashedBox(
      radius: radius,
      onTap: onPressed,
      child: SizedBox(
        height: vertical ? null : height,
        child: Center(
          child: vertical
              ? Column(mainAxisSize: MainAxisSize.min, children: content)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: content,
                ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  final Color color;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      );

    const dash = 6.0;
    const gap = 5.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}

/// Statistika ekranidagi davr tanlagich: kulrang yo'lka ichida oq "thumb".
class SegmentedTrack<T> extends StatelessWidget {
  const SegmentedTrack({
    required this.segments,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  /// `(qiymat, yorliq)` juftliklari.
  final List<(T, String)> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(AppDims.tile),
      ),
      child: Row(
        children: [
          for (final (value, label) in segments)
            Expanded(
              child: Semantics(
                button: true,
                selected: value == selected,
                child: GestureDetector(
                  onTap: () {
                    if (value == selected) return;
                    HapticFeedback.selectionClick();
                    onChanged(value);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: value == selected
                          ? palette.surface
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.smallStrong.copyWith(
                        color: value == selected
                            ? palette.textPrimary
                            : palette.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Tarix ekranidagi filtr chiplari: 36px, tanlangani to'q fonli.
class PillChips<T> extends StatelessWidget {
  const PillChips({
    required this.options,
    required this.selected,
    required this.onChanged,
    super.key,
    this.padding =
        const EdgeInsets.symmetric(horizontal: AppDims.pagePadding),
  });

  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (final (index, (value, label)) in options.indexed) ...[
            if (index > 0) const SizedBox(width: 8),
            Semantics(
              button: true,
              selected: value == selected,
              child: GestureDetector(
                onTap: () {
                  if (value == selected) return;
                  HapticFeedback.selectionClick();
                  onChanged(value);
                },
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        value == selected ? palette.inverse : palette.surface,
                    borderRadius: BorderRadius.circular(AppDims.chipRadius),
                  ),
                  child: Text(
                    label,
                    style: AppText.small.copyWith(
                      color: value == selected
                          ? palette.onInverse
                          : palette.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Formadagi bitta qator: ikonka · yorliq · qiymat · `›`.
/// Oq kartochka ichida ketma-ket turadi, orasida 1px chegara.
class ValueRow extends StatelessWidget {
  const ValueRow({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
    this.onTap,
    this.valueColor,
    this.showDivider = true,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final Color? valueColor;

  /// Kartochkadagi birinchi qatorda `false`.
  final bool showDivider;

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: showDivider
            ? BoxDecoration(
                border: Border(top: BorderSide(color: palette.border)),
              )
            : null,
        child: Row(
          children: [
            Icon(icon, size: 22, color: palette.textMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppText.label.copyWith(color: palette.textMuted),
              ),
            ),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: AppText.rowValue.copyWith(
                  color: valueColor ?? palette.textPrimary,
                ),
              ),
            ),
            ?trailing,
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 22, color: palette.textMuted),
            ],
          ],
        ),
      ),
    );
  }
}

/// Statistikadagi kichik ko'rsatkich plitkasi: 12/700 yorliq + 18/800 qiymat.
class StatTile extends StatelessWidget {
  const StatTile({
    required this.label,
    required this.value,
    super.key,
    this.valueColor,
    this.footnote,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return DesignCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.meta.copyWith(color: palette.textMuted),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: AppText.metricValue.copyWith(
                color: valueColor ?? palette.textPrimary,
              ),
            ),
          ),
          if (footnote != null) ...[
            const SizedBox(height: 2),
            Text(
              footnote!,
              style: AppText.tiny.copyWith(color: palette.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

/// Byudjet va kategoriya ulushi uchun progress chizig'i (8px, r4).
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    required this.value,
    super.key,
    this.color,
    this.height = 8,
  });

  /// 0.0–1.0 oralig'idan tashqari qiymat ham beriladi (limitdan oshgan
  /// byudjet) — chiziq to'liq to'ladi, rang chaqiruvchida o'zgaradi.
  final double value;

  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          value: value.clamp(0.0, 1.0),
          minHeight: height,
          backgroundColor: palette.surfaceAlt,
          valueColor: AlwaysStoppedAnimation(color ?? palette.primary),
        ),
      ),
    );
  }
}

/// Ekran pastidagi asosiy tugma: 56px, to'liq yumaloq, o'ngda belgi.
class PrimaryAction extends StatelessWidget {
  const PrimaryAction({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon = Icons.check,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          if (loading) ...[
            const SizedBox(width: 10),
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: context.palette.onPrimary,
              ),
            ),
          ] else if (icon != null) ...[
            const SizedBox(width: 8),
            Icon(icon, size: 22),
          ],
        ],
      ),
    );
  }
}
