import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/database/enums.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../../core/widgets/design_kit.dart';
import '../../../core/widgets/money_field.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../accounts/data/account_repository.dart';
import '../../categories/data/category_repository.dart';
import '../data/seed_catalog.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _stepCount = 4;

  final _pageController = PageController();
  final _cashController = TextEditingController();
  final List<_CardDraft> _cards = [];

  int _step = 0;
  bool _saving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _cashController.dispose();
    for (final card in _cards) {
      card.dispose();
    }
    super.dispose();
  }

  void _goTo(int step) {
    if (step < 0 || step >= _stepCount) return;
    HapticFeedback.selectionClick();
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);

    final l10n = AppL10n.of(context);
    final settings = ref.read(settingsProvider);
    final categories = ref.read(categoryRepositoryProvider);
    final accounts = ref.read(accountRepositoryProvider);

    try {
      if (!await categories.hasAny()) {
        await categories.seedDefaults(defaultCategories(l10n));
      }

      final currency = settings.mainCurrencyCode;

      await accounts.create(
        name: l10n.seedAccCash,
        type: AccountType.cash,
        currency: currency,
        initialBalance: MoneyField.toMinor(_cashController.text) ?? 0,
        iconKey: AppIcons.defaultIconForAccountType('cash'),
        colorValue: paletteColorAt(1),
      );

      for (var i = 0; i < _cards.length; i++) {
        final card = _cards[i];
        final name = card.name.text.trim();
        final amount = MoneyField.toMinor(card.amount.text);
        if (name.isEmpty && amount == null) continue;
        await accounts.create(
          name: name.isEmpty ? '${l10n.seedAccCard} ${i + 1}' : name,
          type: AccountType.card,
          currency: currency,
          initialBalance: amount ?? 0,
          iconKey: AppIcons.defaultIconForAccountType('card'),
          colorValue: paletteColorAt(13 + i),
        );
      }

      await ref.read(settingsProvider.notifier).completeOnboarding();
      if (mounted) context.go(Routes.home);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Progress(step: _step, total: _stepCount),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const _WelcomeStep(),
                  const _LanguageStep(),
                  const _CurrencyStep(),
                  _BalanceStep(
                    cashController: _cashController,
                    cards: _cards,
                    onAddCard: () => setState(() => _cards.add(_CardDraft())),
                    onRemoveCard: (index) => setState(() {
                      _cards.removeAt(index).dispose();
                    }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PrimaryAction(
                    label: switch (_step) {
                      0 => l10n.onbStart,
                      3 => l10n.onbFinish,
                      _ => l10n.actionNext,
                    },
                    icon: _step == _stepCount - 1
                        ? Icons.check
                        : Icons.arrow_forward,
                    loading: _saving,
                    onPressed: () {
                      if (_step == _stepCount - 1) {
                        _finish();
                      } else {
                        _goTo(_step + 1);
                      }
                    },
                  ),
                  SizedBox(
                    height: 44,
                    child: _step == 0
                        ? null
                        : TextButton(
                            onPressed: _saving ? null : () => _goTo(_step - 1),
                            child: Text(l10n.actionPrevious),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardDraft {
  final name = TextEditingController();
  final amount = TextEditingController();

  void dispose() {
    name.dispose();
    amount.dispose();
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Maketdagi qadam chiziqlari: 4px balandlik, radius 2, oraliq 6.
          Row(
            children: [
              for (var i = 0; i < total; i++)
                Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: i <= step ? palette.primary : palette.surfaceAlt,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.onbStepOf(step + 1, total),
            style: AppText.smallStrong.copyWith(color: palette.primary),
          ),
        ],
      ),
    );
  }
}

/// Qadamlar uchun bir xil maket (`plan/Boshlash.dc.html`):
/// 28/800 sarlavha, 15/500 tavsif, so'ng kontent.
class _StepLayout extends StatelessWidget {
  const _StepLayout({
    required this.title,
    this.body,
    this.child,
    this.header,
  });

  final String title;
  final String? body;
  final Widget? child;

  /// Sarlavha ustidagi blok (birinchi qadamdagi logo).
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) ...[
            header!,
            const SizedBox(height: 24),
          ],
          Text(
            title,
            style: AppText.display.copyWith(color: palette.textPrimary),
          ),
          if (body != null) ...[
            const SizedBox(height: 8),
            Text(
              body!,
              style: AppText.body.copyWith(color: palette.textMuted),
            ),
          ],
          if (child != null) ...[
            const SizedBox(height: 24),
            child!,
          ],
        ],
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;

    return _StepLayout(
      header: const BrandLogo(markSize: 56, wordmarkSize: 36, showTagline: true),
      title: l10n.onbWelcomeTitle,
      body: l10n.onbWelcomeBody,
      child: DesignCard(
        color: palette.primaryTint,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_outline, size: 22, color: palette.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.onbPrivacyNote,
                style: AppText.hint.copyWith(color: palette.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageStep extends ConsumerWidget {
  const _LanguageStep();

  static const _languages = [
    ('uz', "O'zbekcha"),
    ('ru', 'Русский'),
    ('en', 'English'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final current = ref.watch(settingsProvider).localeCode;

    return _StepLayout(
      title: l10n.onbLanguageTitle,
      child: Column(
        children: [
          for (final (code, label) in _languages)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ChoiceTile(
                title: label,
                selected: code == current,
                onTap: () =>
                    ref.read(settingsProvider.notifier).setLocale(code),
              ),
            ),
        ],
      ),
    );
  }
}

class _CurrencyStep extends ConsumerWidget {
  const _CurrencyStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final current = ref.watch(settingsProvider).mainCurrencyCode;

    return _StepLayout(
      title: l10n.onbCurrencyTitle,
      body: l10n.onbCurrencyBody,
      child: Column(
        children: [
          for (final currency in Currency.all)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ChoiceTile(
                title: currency.code,
                subtitle: currency.symbol,
                selected: currency.code == current,
                onTap: () => ref
                    .read(settingsProvider.notifier)
                    .setMainCurrency(currency.code),
              ),
            ),
        ],
      ),
    );
  }
}

/// Boshlang'ich qoldiq qadami (`plan/Boshlash.dc.html`): har bir hisob
/// oq kartochkada, ichida 28/800 summa maydoni; pastda uzuq-uzuq
/// "karta qo'shish" tugmasi va "Jami" qatori.
class _BalanceStep extends ConsumerStatefulWidget {
  const _BalanceStep({
    required this.cashController,
    required this.cards,
    required this.onAddCard,
    required this.onRemoveCard,
  });

  final TextEditingController cashController;
  final List<_CardDraft> cards;
  final VoidCallback onAddCard;
  final ValueChanged<int> onRemoveCard;

  @override
  ConsumerState<_BalanceStep> createState() => _BalanceStepState();
}

class _BalanceStepState extends ConsumerState<_BalanceStep> {
  /// Kiritilgan summalarning yig'indisi — maketdagi "Jami" qatori.
  int get _total {
    var sum = MoneyField.toMinor(widget.cashController.text) ?? 0;
    for (final card in widget.cards) {
      sum += MoneyField.toMinor(card.amount.text) ?? 0;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final currency = ref.watch(settingsProvider).mainCurrency;

    return _StepLayout(
      title: l10n.onbCashQuestion,
      body: l10n.onbBalanceBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InlineAmountCard(
            icon: AppIcons.resolve(
              AppIcons.defaultIconForAccountType('cash'),
            ),
            label: l10n.seedAccCash,
            controller: widget.cashController,
            currencySymbol: currency.symbol,
            onChanged: () => setState(() {}),
          ),
          for (var i = 0; i < widget.cards.length; i++)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: InlineAmountCard(
                icon: AppIcons.resolve(
                  AppIcons.defaultIconForAccountType('card'),
                ),
                controller: widget.cards[i].amount,
                currencySymbol: currency.symbol,
                onChanged: () => setState(() {}),
                labelField: TextField(
                  controller: widget.cards[i].name,
                  style: AppText.label.copyWith(color: palette.textPrimary),
                  decoration: InputDecoration(
                    hintText: l10n.onbCardNameHint,
                    hintStyle:
                        AppText.label.copyWith(color: palette.textMuted),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                trailing: IconButton(
                  onPressed: () => widget.onRemoveCard(i),
                  tooltip: l10n.actionDelete,
                  visualDensity: VisualDensity.compact,
                  iconSize: 20,
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: palette.textMuted,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          DashedButton(
            label: l10n.onbAddCard,
            onPressed: widget.onAddCard,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.labelTotal,
                  style: AppText.label.copyWith(color: palette.textMuted),
                ),
              ),
              Text(
                Money.format(_total, currency: currency),
                style: AppText.totalValue.copyWith(color: palette.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDims.card),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDims.card),
            color: selected ? palette.primaryTint : palette.surface,
            border: selected
                ? Border.all(color: palette.primary, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppText.strong.copyWith(
                        color: palette.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: AppText.meta.copyWith(color: palette.textMuted),
                      ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 22,
                color: selected ? palette.primary : palette.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
