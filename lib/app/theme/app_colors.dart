import 'package:flutter/material.dart';

import '../../core/database/enums.dart';

/// Dizayn maketidagi xom qiymatlar.
///
/// Yorug' tema — `plan/*.dc.html` bordlari, qorong'u tema esa
/// `plan/Moliya Tracker — UI dizayn.html` ichidagi "Dark · …" bordlari.
/// Brend belgisi "Fimora logo" bordidan olingan.
///
/// Rang **yakka ma'no tashuvchi emas** — har joyda ikonka va `+`/`−`
/// ishorasi bilan birga keladi (rang-ko'rlik uchun).
class AppColors {
  const AppColors._();

  // --- Brend (logo bordi) ---

  /// Logo belgisining asosiy ko'ki.
  static const brandBlue = Color(0xFF2F4BDB);

  /// Logodagi tilla nuqta; qorong'u temada asosiy harakat rangi.
  static const brandGold = Color(0xFFFFC857);

  /// Logoning to'q fonli varianti.
  static const brandInk = Color(0xFF14183A);

  // --- Yorug' tema (maketdan to'g'ridan-to'g'ri) ---
  static const bg = Color(0xFFF4F5F7);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF151A22);
  static const textMuted = Color(0xFF5B6472);
  static const border = Color(0xFFE3E6EB);
  static const primary = Color(0xFF2F4BDB);
  static const primaryTint = Color(0xFFE8ECFD);

  /// Umumiy balans kartasining to'q ko'k foni.
  static const hero = Color(0xFF1E2A78);

  static const income = Color(0xFF0E7490);
  static const incomeTint = Color(0xFFE0F2F7);
  static const expense = Color(0xFFB54A00);
  static const expenseTint = Color(0xFFFDEEE3);
  static const transfer = Color(0xFF2F4BDB);
  static const transferTint = Color(0xFFE8ECFD);

  /// "Qo'shish" uchun uzuq-uzuq ramka.
  static const dashed = Color(0xFFB9C0CC);

  /// Betaraf kulrang — diagrammadagi "Boshqa" uchun.
  static const neutral = Color(0xFF8A94A6);

  // --- Qorong'u tema ("Dark · …" bordlaridan to'g'ridan-to'g'ri) ---
  //
  // Maketda qorong'u temada asosiy harakat rangi ko'k emas, **tilla**:
  // tugmalar, FAB, faol navigatsiya, qadam chiziqlari — hammasi #FFC857.
  // Ko'k esa faqat balans kartasining foni sifatida qoladi.
  static const bgDark = Color(0xFF0D1024);
  static const surfaceDark = Color(0xFF181C3A);
  static const surfaceAltDark = Color(0xFF2A3060);
  static const textPrimaryDark = Color(0xFFF2F4FF);
  static const textMutedDark = Color(0xFFA3ABCB);
  static const borderDark = Color(0xFF2A3060);
  static const primaryDark = brandGold;
  static const primaryTintDark = Color(0xFF232A5C);
  static const heroDark = Color(0xFF2F4BDB);
  static const incomeDark = Color(0xFF38C6E4);
  static const incomeTintDark = Color(0xFF12303A);
  static const expenseDark = Color(0xFFFF9A52);
  static const expenseTintDark = Color(0xFF3A2418);
  static const transferDark = brandGold;
  static const transferTintDark = Color(0xFF232A5C);
  static const dashedDark = Color(0xFF3A4175);
  static const neutralDark = Color(0xFF8A94A6);

  /// Diagramma bo'laklari — maketdagi tartibda, so'ng qo'shimcha ranglar.
  /// Oxirgisi doim betaraf kulrang ("Boshqa" uchun).
  static const chart = <Color>[
    Color(0xFF1E2A78),
    Color(0xFFC2570C),
    Color(0xFF0E7490),
    Color(0xFF2F4BDB),
    Color(0xFF7C3AED),
    Color(0xFFB54A00),
    Color(0xFF0F766E),
    Color(0xFFBE123C),
    Color(0xFF4D7C0F),
    Color(0xFF8A94A6),
  ];

  /// Qorong'u fonda o'qiladigan diagramma ranglari (dark statistika bordi).
  static const chartDark = <Color>[
    Color(0xFF7C8CFF),
    Color(0xFFFF9A52),
    Color(0xFF38C6E4),
    brandGold,
    Color(0xFFC4A6FF),
    Color(0xFFFFB07A),
    Color(0xFF4FD1C5),
    Color(0xFFFF8FA3),
    Color(0xFFA3E635),
    Color(0xFF8A94A6),
  ];

  /// Kategoriya / hisob uchun tanlanadigan palitra.
  static const palette = <Color>[
    Color(0xFF2F4BDB),
    Color(0xFF1E2A78),
    Color(0xFF0E7490),
    Color(0xFF0F766E),
    Color(0xFF15803D),
    Color(0xFF4D7C0F),
    Color(0xFFA16207),
    Color(0xFFC2570C),
    Color(0xFFB54A00),
    Color(0xFFBE123C),
    Color(0xFFBE185D),
    Color(0xFF7C3AED),
    Color(0xFF4F46E5),
    Color(0xFF0369A1),
    Color(0xFF0E7490),
    Color(0xFF065F46),
    Color(0xFF854D0E),
    Color(0xFF7C2D12),
    Color(0xFF5B6472),
    Color(0xFF8A94A6),
  ];
}

/// O'lchamlar va radiuslar — maketda takrorlanadigan qiymatlar.
class AppDims {
  const AppDims._();

  /// Ekran chetidan gorizontal masofa.
  static const double pagePadding = 20;

  /// Oq kartochka radiusi.
  static const double card = 20;

  /// Umumiy balans kartasi radiusi.
  static const double hero = 24;

  /// Kichik plitka (ikonka kvadrati, klaviatura tugmasi) radiusi.
  static const double tile = 16;

  /// Yozuv ikonkasi: 44×44, radius 14.
  static const double rowIcon = 44;
  static const double rowIconRadius = 14;

  /// Hisob ikonkasi: 48×48, radius 16.
  static const double listIcon = 48;
  static const double listIconRadius = 16;

  /// Asosiy tugma balandligi (radius = balandlik / 2).
  static const double primaryButton = 56;

  /// Pastki navigatsiya balandligi.
  static const double navBar = 80;

  /// Markazdagi "qo'shish" tugmasi.
  static const double fab = 56;

  /// Ikkilamchi tugma (ramkali, dashed) balandligi.
  static const double secondaryButton = 52;

  /// Filtr chipi: 36px, radius 18.
  static const double chip = 36;
  static const double chipRadius = 18;

  /// Tur tanlash pili: 40px, radius 20.
  static const double typePill = 40;

  /// Klaviatura tugmasi balandligi.
  static const double keypadTile = 52;

  /// Bosh sahifadagi hisob kartochkasi kengligi.
  static const double accountCard = 150;

  /// Navigatsiya paneli ostida qoladigan bo'sh joy (ro'yxat pastki chekkasi).
  static const double navBarClearance = 116;
}

/// Temaga bog'langan dizayn ranglari. `ColorScheme`da o'rni yo'q
/// qiymatlar (hero foni, tur ranglarining och varianti) shu yerda.
@immutable
class FinoraPalette extends ThemeExtension<FinoraPalette> {
  const FinoraPalette({
    required this.isDark,
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.textPrimary,
    required this.textMuted,
    required this.border,
    required this.primary,
    required this.onPrimary,
    required this.primaryTint,
    required this.hero,
    required this.income,
    required this.incomeTint,
    required this.expense,
    required this.expenseTint,
    required this.transfer,
    required this.transferTint,
    required this.dashed,
    required this.neutral,
  });

  factory FinoraPalette.light() => const FinoraPalette(
        isDark: false,
        bg: AppColors.bg,
        surface: AppColors.surface,
        surfaceAlt: AppColors.border,
        textPrimary: AppColors.textPrimary,
        textMuted: AppColors.textMuted,
        border: AppColors.border,
        primary: AppColors.primary,
        onPrimary: AppColors.surface,
        primaryTint: AppColors.primaryTint,
        hero: AppColors.hero,
        income: AppColors.income,
        incomeTint: AppColors.incomeTint,
        expense: AppColors.expense,
        expenseTint: AppColors.expenseTint,
        transfer: AppColors.transfer,
        transferTint: AppColors.transferTint,
        dashed: AppColors.dashed,
        neutral: AppColors.neutral,
      );

  factory FinoraPalette.dark() => const FinoraPalette(
        isDark: true,
        bg: AppColors.bgDark,
        surface: AppColors.surfaceDark,
        surfaceAlt: AppColors.surfaceAltDark,
        textPrimary: AppColors.textPrimaryDark,
        textMuted: AppColors.textMutedDark,
        border: AppColors.borderDark,
        primary: AppColors.primaryDark,
        onPrimary: AppColors.bgDark,
        primaryTint: AppColors.primaryTintDark,
        hero: AppColors.heroDark,
        income: AppColors.incomeDark,
        incomeTint: AppColors.incomeTintDark,
        expense: AppColors.expenseDark,
        expenseTint: AppColors.expenseTintDark,
        transfer: AppColors.transferDark,
        transferTint: AppColors.transferTintDark,
        dashed: AppColors.dashedDark,
        neutral: AppColors.neutralDark,
      );

  /// Qorong'u variantmi — `Theme.of(context).brightness` ni qayta
  /// so'ramaslik uchun palitra ichida saqlanadi.
  final bool isDark;

  final Color bg;
  final Color surface;

  /// Segmented tugma yo'lkasi, progress trek kabi ikkinchi darajali fon.
  final Color surfaceAlt;

  final Color textPrimary;
  final Color textMuted;
  final Color border;
  final Color primary;

  /// Asosiy rang ustidagi matn/ikonka: yorug'da oq, qorong'uda to'q
  /// (tilla tugma ustida oq o'qilmaydi).
  final Color onPrimary;

  final Color primaryTint;
  final Color hero;
  final Color income;
  final Color incomeTint;
  final Color expense;
  final Color expenseTint;
  final Color transfer;
  final Color transferTint;
  final Color dashed;
  final Color neutral;

  /// Balans kartasi ikki temada ham to'q fonli — ustidagi matn doim oq.
  Color get onHero => Colors.white;

  /// Tanlangan chip / snackbar foni: matn rangining teskarisi.
  Color get inverse => textPrimary;

  /// [inverse] ustidagi matn.
  Color get onInverse => isDark ? bg : surface;

  /// Diagramma palitrasi — temaga mos.
  List<Color> get chart => isDark ? AppColors.chartDark : AppColors.chart;

  /// Bazada saqlangan foydalanuvchi rangi (kategoriya/hisob) yorug' tema
  /// uchun tanlangan. Qorong'u fonda o'qilishi uchun yorqinlashtiriladi.
  Color adapt(Color color) =>
      isDark ? Color.lerp(color, Colors.white, 0.34)! : color;

  Color forTxType(TransactionType type) => switch (type) {
        TransactionType.income => income,
        TransactionType.expense => expense,
        TransactionType.transfer => transfer,
      };

  Color tintForTxType(TransactionType type) => switch (type) {
        TransactionType.income => incomeTint,
        TransactionType.expense => expenseTint,
        TransactionType.transfer => transferTint,
      };

  @override
  FinoraPalette copyWith({
    bool? isDark,
    Color? bg,
    Color? surface,
    Color? surfaceAlt,
    Color? textPrimary,
    Color? textMuted,
    Color? border,
    Color? primary,
    Color? onPrimary,
    Color? primaryTint,
    Color? hero,
    Color? income,
    Color? incomeTint,
    Color? expense,
    Color? expenseTint,
    Color? transfer,
    Color? transferTint,
    Color? dashed,
    Color? neutral,
  }) {
    return FinoraPalette(
      isDark: isDark ?? this.isDark,
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryTint: primaryTint ?? this.primaryTint,
      hero: hero ?? this.hero,
      income: income ?? this.income,
      incomeTint: incomeTint ?? this.incomeTint,
      expense: expense ?? this.expense,
      expenseTint: expenseTint ?? this.expenseTint,
      transfer: transfer ?? this.transfer,
      transferTint: transferTint ?? this.transferTint,
      dashed: dashed ?? this.dashed,
      neutral: neutral ?? this.neutral,
    );
  }

  @override
  FinoraPalette lerp(ThemeExtension<FinoraPalette>? other, double t) {
    if (other is! FinoraPalette) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return FinoraPalette(
      isDark: t < 0.5 ? isDark : other.isDark,
      bg: mix(bg, other.bg),
      surface: mix(surface, other.surface),
      surfaceAlt: mix(surfaceAlt, other.surfaceAlt),
      textPrimary: mix(textPrimary, other.textPrimary),
      textMuted: mix(textMuted, other.textMuted),
      border: mix(border, other.border),
      primary: mix(primary, other.primary),
      onPrimary: mix(onPrimary, other.onPrimary),
      primaryTint: mix(primaryTint, other.primaryTint),
      hero: mix(hero, other.hero),
      income: mix(income, other.income),
      incomeTint: mix(incomeTint, other.incomeTint),
      expense: mix(expense, other.expense),
      expenseTint: mix(expenseTint, other.expenseTint),
      transfer: mix(transfer, other.transfer),
      transferTint: mix(transferTint, other.transferTint),
      dashed: mix(dashed, other.dashed),
      neutral: mix(neutral, other.neutral),
    );
  }
}

/// Tema ichidan dizayn ranglarini olish uchun kengaytma.
extension SemanticColors on BuildContext {
  FinoraPalette get palette =>
      Theme.of(this).extension<FinoraPalette>() ?? FinoraPalette.light();

  Color get incomeColor => palette.income;

  Color get expenseColor => palette.expense;

  Color get transferColor => palette.transfer;

  Color colorForTxType(TransactionType type) => palette.forTxType(type);

  Color tintForTxType(TransactionType type) => palette.tintForTxType(type);
}

/// Tranzaksiya turining ikonkasi va ishorasi.
class TxVisuals {
  const TxVisuals._();

  static IconData icon(TransactionType type) => switch (type) {
        TransactionType.income => Icons.south_west,
        TransactionType.expense => Icons.north_east,
        TransactionType.transfer => Icons.swap_horiz,
      };

  /// Rangdan mustaqil ishora — screen reader va rang-ko'rlar uchun.
  static String sign(TransactionType type) => switch (type) {
        TransactionType.income => '+',
        TransactionType.expense => '−',
        TransactionType.transfer => '',
      };
}
