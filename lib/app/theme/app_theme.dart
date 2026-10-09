import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// Maketdagi matn uslublari (`plan/*.dc.html`). O'lchamlar va vaznlar
/// bir joyda turadi — ekranlarda sehrli raqamlar bo'lmasligi uchun.
///
/// Rang berilmaydi: har bir uslub ishlatilgan joyda `copyWith(color:)`
/// bilan rang oladi, shunda yorug'/qorong'u tema ikkisi ham to'g'ri chiqadi.
class AppText {
  const AppText._();

  static const _numeric = [FontFeature.tabularFigures()];

  /// Yangi yozuv ekranidagi summa — 48/800.
  static const amountHuge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 1.1,
    fontFeatures: _numeric,
  );

  /// Umumiy balans — 36/800.
  static const amountHero = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 1.1,
    fontFeatures: _numeric,
  );

  /// Hisoblar ekranidagi jami — 30/800.
  static const amountLarge = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 1.15,
    fontFeatures: _numeric,
  );

  /// Onboarding sarlavhasi va summa kiritish maydoni — 28/800.
  static const display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.2,
  );

  /// Ekran sarlavhasi — 24/800.
  static const pageTitle = TextStyle(fontSize: 24, fontWeight: FontWeight.w800);

  /// Modal / forma sarlavhasi — 20/800.
  static const sheetTitle =
      TextStyle(fontSize: 20, fontWeight: FontWeight.w800);

  /// Onboardingdagi jami — 22/800.
  static const totalValue = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    fontFeatures: _numeric,
  );

  /// Klaviatura raqami — 22/800.
  static const keypad = TextStyle(fontSize: 22, fontWeight: FontWeight.w800);

  /// Metrika plitkasi qiymati — 18/800.
  static const metricValue = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    fontFeatures: _numeric,
  );

  /// Hisob kartasidagi summa — 17/800.
  static const accountAmount = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    fontFeatures: _numeric,
  );

  /// Bo'lim sarlavhasi, hisob nomi, tugma matni — 16/800.
  static const strong = TextStyle(fontSize: 16, fontWeight: FontWeight.w800);

  /// Balans pilli qiymati — 16/800.
  static const pillValue = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    fontFeatures: _numeric,
  );

  /// Yozuv summasi — 15/800.
  static const rowAmount = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    fontFeatures: _numeric,
  );

  /// Yozuv nomi — 15/700.
  static const rowTitle = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);

  /// Onboarding tavsifi — 15/500, qator balandligi 22.
  static const body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 22 / 15,
  );

  /// Qator yorlig'i, kartochka sarlavhasi — 14/700.
  static const label = TextStyle(fontSize: 14, fontWeight: FontWeight.w700);

  /// Kartochka ichidagi bo'lim sarlavhasi — 14/800.
  static const cardTitle = TextStyle(fontSize: 14, fontWeight: FontWeight.w800);

  /// Qator qiymati ("Oziq-ovqat", "Naqd") — 14/800.
  static const rowValue = TextStyle(fontSize: 14, fontWeight: FontWeight.w800);

  /// Chip, legenda, hisob turi — 13/700.
  static const small = TextStyle(fontSize: 13, fontWeight: FontWeight.w700);

  /// Kun sarlavhasi, qadam ko'rsatkichi — 13/800.
  static const smallStrong =
      TextStyle(fontSize: 13, fontWeight: FontWeight.w800);

  /// Meta matn ("Naqd · 14:20") — 12/700.
  static const meta = TextStyle(fontSize: 12, fontWeight: FontWeight.w700);

  /// Yordam matni — 12/500, qator balandligi 18.
  static const hint = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 18 / 12,
  );

  /// Navigatsiya yorlig'i va diagramma o'qi — 11/700.
  static const tiny = TextStyle(fontSize: 11, fontWeight: FontWeight.w700);

  /// Logo yozuvi: kichik harflar, 800 vazn, siqilgan harf oralig'i
  /// ("Fimora logo" bordidagi `.w` klassi).
  static TextStyle wordmark(double size) => TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w800,
        letterSpacing: size * -0.03,
        height: 1,
      );
}

/// Material 3 ustiga maketdagi dizayn tizimi.
class AppTheme {
  const AppTheme._();

  static const String fontFamily = 'Manrope';

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final palette = isDark ? FinoraPalette.dark() : FinoraPalette.light();

    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
        ).copyWith(
          primary: palette.primary,
          onPrimary: palette.onPrimary,
          primaryContainer: palette.primaryTint,
          onPrimaryContainer: palette.primary,
          inverseSurface: palette.inverse,
          onInverseSurface: palette.onInverse,
          surface: palette.surface,
          onSurface: palette.textPrimary,
          onSurfaceVariant: palette.textMuted,
          surfaceContainerLowest: palette.surface,
          surfaceContainerLow: palette.surface,
          surfaceContainer: palette.surface,
          surfaceContainerHigh: palette.surfaceAlt,
          surfaceContainerHighest: palette.surfaceAlt,
          outline: palette.textMuted,
          outlineVariant: palette.border,
          secondaryContainer: palette.primaryTint,
          onSecondaryContainer: palette.primary,
          tertiaryContainer: palette.expenseTint,
          onTertiaryContainer: palette.expense,
          // Xato va o'chirish — chiqim rangidan farqli qizil, aks holda
          // "chiqim" va "o'chirish" bir xil ko'rinadi.
          error: isDark ? const Color(0xFFFF8FA3) : const Color(0xFFBE123C),
          onError: palette.onPrimary,
          errorContainer:
              isDark ? const Color(0xFF3A1A26) : const Color(0xFFFCE7EB),
          onErrorContainer:
              isDark ? const Color(0xFFFF8FA3) : const Color(0xFFBE123C),
        );

    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: fontFamily,
      visualDensity: VisualDensity.standard,
    );

    final textTheme = _textTheme(base.textTheme, palette);

    return base.copyWith(
      extensions: [palette],
      scaffoldBackgroundColor: palette.bg,
      canvasColor: palette.bg,
      dividerColor: palette.border,
      textTheme: textTheme,
      primaryTextTheme: textTheme,

      // Sarlavha maketdagidek: fon bilan bir xil, chizig'siz, 24/800.
      appBarTheme: AppBarTheme(
        backgroundColor: palette.bg,
        foregroundColor: palette.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: AppDims.pagePadding,
        titleTextStyle: AppText.pageTitle.copyWith(
          fontFamily: fontFamily,
          color: palette.textPrimary,
        ),
        iconTheme: IconThemeData(color: palette.textPrimary, size: 22),
        actionsIconTheme:
            IconThemeData(color: palette.textPrimary, size: 22),
        // Status bar ikonkalari fon bilan kontrast bo'lishi uchun.
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDims.card),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        iconColor: palette.textMuted,
        titleTextStyle: AppText.rowTitle.copyWith(
          fontFamily: fontFamily,
          color: palette.textPrimary,
        ),
        subtitleTextStyle: AppText.meta.copyWith(
          fontFamily: fontFamily,
          color: palette.textMuted,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: palette.border,
        space: 1,
        thickness: 1,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        hintStyle: AppText.rowTitle.copyWith(color: palette.textMuted),
        labelStyle: AppText.label.copyWith(color: palette.textMuted),
        floatingLabelStyle: AppText.label.copyWith(color: palette.primary),
        border: _inputBorder(Colors.transparent),
        enabledBorder: _inputBorder(palette.border),
        focusedBorder: _inputBorder(palette.primary, width: 2),
        errorBorder: _inputBorder(scheme.error),
        focusedErrorBorder: _inputBorder(scheme.error, width: 2),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // Asosiy harakat: 56px balandlik, to'liq yumaloq, 16/800.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          minimumSize: const Size.fromHeight(AppDims.primaryButton),
          shape: const StadiumBorder(),
          elevation: 0,
          textStyle: AppText.strong.copyWith(fontFamily: fontFamily),
        ),
      ),

      // Ikkilamchi harakat: 2px ramka, 52px balandlik.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          minimumSize: const Size.fromHeight(AppDims.secondaryButton),
          side: BorderSide(color: palette.primary, width: 2),
          shape: const StadiumBorder(),
          textStyle: AppText.strong.copyWith(fontFamily: fontFamily),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          minimumSize: const Size(48, 44),
          textStyle: AppText.small.copyWith(fontFamily: fontFamily),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: palette.textPrimary,
          minimumSize: const Size(44, 44),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.primary,
        foregroundColor: palette.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: const CircleBorder(),
      ),

      // Tarix ekranidagi filtr chiplari: 36px, to'liq yumaloq, ramkasiz.
      chipTheme: ChipThemeData(
        backgroundColor: palette.surface,
        selectedColor: palette.inverse,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        labelStyle: AppText.small.copyWith(
          fontFamily: fontFamily,
          color: palette.textPrimary,
        ),
        secondaryLabelStyle: AppText.small.copyWith(
          fontFamily: fontFamily,
          color: palette.onInverse,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        showCheckmark: false,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: palette.primary,
        unselectedLabelColor: palette.textMuted,
        labelStyle: AppText.small.copyWith(fontFamily: fontFamily),
        unselectedLabelStyle: AppText.small.copyWith(fontFamily: fontFamily),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: palette.border,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: palette.primary, width: 2.5),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: AppText.sheetTitle.copyWith(
          fontFamily: fontFamily,
          color: palette.textPrimary,
        ),
        contentTextStyle: AppText.body.copyWith(
          fontFamily: fontFamily,
          color: palette.textMuted,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.inverse,
        contentTextStyle: AppText.rowTitle.copyWith(
          fontFamily: fontFamily,
          color: palette.onInverse,
        ),
        // Teskari fon ustida — qarama-qarshi temaning asosiy rangi.
        actionTextColor: isDark ? AppColors.primary : AppColors.brandGold,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDims.tile),
        ),
      ),

      // Byudjet progressi: 8px, radius 4.
      progressIndicatorTheme: ProgressIndicatorThemeData(
        linearMinHeight: 8,
        linearTrackColor: palette.surfaceAlt,
        color: palette.primary,
        borderRadius: BorderRadius.circular(4),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.onPrimary
              : palette.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.primary
              : palette.surfaceAlt,
        ),
        trackOutlineColor: WidgetStatePropertyAll(palette.border),
      ),

      datePickerTheme: DatePickerThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: palette.primary,
        headerForegroundColor: palette.onPrimary,
      ),

      timePickerTheme: TimePickerThemeData(
        backgroundColor: palette.surface,
        dialBackgroundColor: palette.bg,
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDims.tile),
        ),
        textStyle: AppText.rowTitle.copyWith(
          fontFamily: fontFamily,
          color: palette.textPrimary,
        ),
      ),

      splashFactory: InkSparkle.splashFactory,
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDims.tile),
      borderSide: color == Colors.transparent
          ? BorderSide.none
          : BorderSide(color: color, width: width),
    );
  }

  /// Material uslublarini maketdagi o'lchamlarga bog'laydi, shunda
  /// standart vidjetlar ham (ListTile, Dialog) to'g'ri ko'rinadi.
  static TextTheme _textTheme(TextTheme base, FinoraPalette palette) {
    TextStyle style(TextStyle source, {Color? color}) => source.copyWith(
          fontFamily: fontFamily,
          color: color ?? palette.textPrimary,
        );

    return base.copyWith(
      displayLarge: style(AppText.amountHuge),
      displayMedium: style(AppText.amountHero),
      displaySmall: style(AppText.amountLarge),
      headlineLarge: style(AppText.display),
      headlineMedium: style(AppText.display),
      headlineSmall: style(AppText.pageTitle),
      titleLarge: style(AppText.sheetTitle),
      titleMedium: style(AppText.strong),
      titleSmall: style(AppText.rowAmount),
      bodyLarge: style(AppText.rowTitle),
      bodyMedium: style(AppText.rowTitle),
      bodySmall: style(AppText.meta, color: palette.textMuted),
      labelLarge: style(AppText.label),
      labelMedium: style(AppText.small, color: palette.textMuted),
      labelSmall: style(AppText.tiny, color: palette.textMuted),
    );
  }
}
