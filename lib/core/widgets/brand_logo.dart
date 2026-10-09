import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';

/// Brend belgisi variantlari (`plan/Moliya Tracker — UI dizayn.html`,
/// "Fimora logo" bordi).
enum BrandMarkVariant {
  /// Ko'k plitka + oq belgi + tilla nuqta. Yorug' va to'q fonlar uchun.
  solid,

  /// Oq plitka + ko'k belgi. Ko'k fon ustida ishlatiladi.
  inverse,
}

/// Logo belgisi: 120×120 to'rda chizilgan yumaloq kvadrat, uchta brus
/// va burchakdagi tilla nuqta.
///
/// Rasm fayli emas — har qanday o'lchamda aniq chiqadi va ilova hajmini
/// oshirmaydi (maketda ham `<symbol viewBox="0 0 120 120">` sifatida).
class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 40,
    this.variant = BrandMarkVariant.solid,
  });

  final double size;
  final BrandMarkVariant variant;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppL10n.of(context).appTitle,
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: _BrandMarkPainter(variant),
      ),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  const _BrandMarkPainter(this.variant);

  final BrandMarkVariant variant;

  /// Maket to'ri — barcha koordinatalar shu o'lchamga nisbatan.
  static const double _grid = 120;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / _grid;
    final inverse = variant == BrandMarkVariant.inverse;

    final tile = inverse ? Colors.white : AppColors.brandBlue;
    final glyph = inverse ? AppColors.brandBlue : Colors.white;
    // Oq plitkada tilla to'qroq bo'ladi, aks holda ko'rinmaydi.
    final dot = inverse ? const Color(0xFFE8A100) : AppColors.brandGold;

    void rect(double x, double y, double w, double h, double r, Color color) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x * k, y * k, w * k, h * k),
          Radius.circular(r * k),
        ),
        Paint()..color = color,
      );
    }

    rect(0, 0, 120, 120, 30, tile);
    rect(36, 30, 14, 60, 7, glyph);
    rect(36, 30, 48, 14, 7, glyph);
    rect(36, 53, 32, 14, 7, glyph);
    canvas.drawCircle(
      Offset(82 * k, 82 * k),
      10 * k,
      Paint()..color = dot,
    );
  }

  @override
  bool shouldRepaint(_BrandMarkPainter old) => old.variant != variant;
}

/// Belgi + yozuv. Yozuv maketdagidek kichik harflarda, 800 vaznda va
/// siqilgan harf oralig'ida chiqadi.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.markSize = 56,
    this.wordmarkSize = 34,
    this.variant = BrandMarkVariant.solid,
    this.color,
    this.showTagline = false,
  });

  final double markSize;
  final double wordmarkSize;
  final BrandMarkVariant variant;

  /// Yozuv rangi; berilmasa temadan olinadi.
  final Color? color;

  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final textColor = color ?? palette.textPrimary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandMark(size: markSize, variant: variant),
        SizedBox(width: markSize * 0.28),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appTitle.toLowerCase(),
              style: AppText.wordmark(wordmarkSize).copyWith(color: textColor),
            ),
            if (showTagline) ...[
              SizedBox(height: wordmarkSize * 0.22),
              Text(
                l10n.brandTagline,
                style: AppText.label.copyWith(color: palette.textMuted),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
