import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/section_card.dart';
import '../../../l10n/generated/app_localizations.dart';

/// `pubspec.yaml`dagi `version` bilan mos turishi kerak.
const String kAppVersion = '1.0.0';

/// Qo'llab-quvvatlanadigan tillar — nomi har doim o'z tilida yoziladi.
const List<(String, String)> kAppLanguages = [
  ('uz', "O'zbekcha"),
  ('ru', 'Русский'),
  ('en', 'English'),
];

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.setTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          SectionHeader(l10n.setSectionGeneral),
          ListTile(
            leading: const Icon(Icons.translate_outlined),
            title: Text(l10n.setLanguage),
            subtitle: Text(_languageLabel(settings.localeCode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickLanguage(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.payments_outlined),
            title: Text(l10n.setCurrency),
            subtitle: Text(
              '${settings.mainCurrency.code}  ·  '
              '${settings.mainCurrency.symbol}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickCurrency(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.event_outlined),
            title: Text(l10n.setMonthStartDay),
            subtitle: Text(
              '${settings.monthStartDay}  ·  ${l10n.setMonthStartDayBody}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickMonthStartDay(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_view_week_outlined),
            title: Text(l10n.setWeekStartDay),
            subtitle: Text(
              settings.weekStartsOn == DateTime.sunday
                  ? l10n.setSunday
                  : l10n.setMonday,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickWeekStart(context, ref),
          ),

          SectionHeader(l10n.setSectionAppearance),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SectionCard(
              title: l10n.setTheme,
              child: SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: const Icon(Icons.light_mode_outlined),
                    label: Text(l10n.setThemeLight),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: const Icon(Icons.dark_mode_outlined),
                    label: Text(l10n.setThemeDark),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: const Icon(Icons.brightness_auto_outlined),
                    label: Text(l10n.setThemeSystem),
                  ),
                ],
                selected: {settings.themeMode},
                showSelectedIcon: false,
                onSelectionChanged: (selection) {
                  HapticFeedback.selectionClick();
                  ref
                      .read(settingsProvider.notifier)
                      .setThemeMode(selection.first);
                },
              ),
            ),
          ),

          SectionHeader(l10n.setSectionData),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: Text(l10n.setManageAccounts),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.accounts),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: Text(l10n.setManageCategories),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.categories),
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: Text(l10n.setBackup),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.backup),
          ),
          ListTile(
            leading: Icon(
              Icons.delete_forever_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              l10n.setWipe,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () => _wipe(context, ref),
          ),

          SectionHeader(l10n.setSectionAbout),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SectionCard(
              title: l10n.setPrivacyTitle,
              child: Text(
                l10n.setPrivacyBody,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.setVersion),
            subtitle: const Text(kAppVersion),
          ),
        ],
      ),
    );
  }

  static String _languageLabel(String code) {
    for (final (value, label) in kAppLanguages) {
      if (value == code) return label;
    }
    return code;
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final current = ref.read(settingsProvider).localeCode;

    final picked = await _showOptions<String>(
      context,
      title: l10n.setLanguage,
      options: [
        for (final (code, label) in kAppLanguages)
          _Option(value: code, label: label, selected: code == current),
      ],
    );
    if (picked != null) {
      await ref.read(settingsProvider.notifier).setLocale(picked);
    }
  }

  Future<void> _pickCurrency(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final current = ref.read(settingsProvider).mainCurrencyCode;

    final picked = await _showOptions<String>(
      context,
      title: l10n.setCurrency,
      options: [
        for (final currency in Currency.all)
          _Option(
            value: currency.code,
            label: '${currency.code}  ·  ${currency.symbol}',
            selected: currency.code == current,
          ),
      ],
    );
    if (picked != null) {
      await ref.read(settingsProvider.notifier).setMainCurrency(picked);
    }
  }

  Future<void> _pickMonthStartDay(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final current = ref.read(settingsProvider).monthStartDay;

    final picked = await _showOptions<int>(
      context,
      title: l10n.setMonthStartDay,
      message: l10n.setMonthStartDayBody,
      options: [
        for (var day = 1; day <= 28; day++)
          _Option(value: day, label: '$day', selected: day == current),
      ],
    );
    if (picked != null) {
      await ref.read(settingsProvider.notifier).setMonthStartDay(picked);
    }
  }

  Future<void> _pickWeekStart(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final current = ref.read(settingsProvider).weekStartsOn;

    final picked = await _showOptions<int>(
      context,
      title: l10n.setWeekStartDay,
      options: [
        _Option(
          value: DateTime.monday,
          label: l10n.setMonday,
          selected: current == DateTime.monday,
        ),
        _Option(
          value: DateTime.sunday,
          label: l10n.setSunday,
          selected: current == DateTime.sunday,
        ),
      ],
    );
    if (picked != null) {
      await ref.read(settingsProvider.notifier).setWeekStartsOn(picked);
    }
  }

  /// Ikki bosqichli o'chirish: ogohlantirish, so'ng so'zni yozib tasdiqlash.
  Future<void> _wipe(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final warned = await confirm(
      context,
      title: l10n.setWipeTitle,
      message: l10n.setWipeBody,
      confirmLabel: l10n.actionContinue,
      destructive: true,
      icon: Icons.delete_forever_outlined,
    );
    if (!warned || !context.mounted) return;

    final confirmed = await confirmByTyping(
      context,
      title: l10n.setWipeConfirmTitle,
      message: l10n.setWipeConfirmBody(l10n.setWipeWord),
      word: l10n.setWipeWord,
    );
    if (!confirmed) return;

    await ref.read(databaseProvider).wipeEverything();
    await ref.read(settingsProvider.notifier).markBackupCleared();
    // Kategoriyalar ham o'chdi — ilova qaytadan onboardingdan boshlanadi.
    await ref.read(settingsProvider.notifier).resetOnboarding();

    messenger.showSnackBar(SnackBar(content: Text(l10n.setWipeDone)));
  }
}

class _Option<T> {
  const _Option({
    required this.value,
    required this.label,
    required this.selected,
  });

  final T value;
  final String label;
  final bool selected;
}

/// Bitta tanlov uchun pastdan chiqadigan ro'yxat.
Future<T?> _showOptions<T>(
  BuildContext context, {
  required String title,
  required List<_Option<T>> options,
  String? message,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => _OptionsSheet<T>(
      title: title,
      options: options,
      message: message,
    ),
  );
}

class _OptionsSheet<T> extends StatefulWidget {
  const _OptionsSheet({
    required this.title,
    required this.options,
    this.message,
  });

  final String title;
  final List<_Option<T>> options;
  final String? message;

  @override
  State<_OptionsSheet<T>> createState() => _OptionsSheetState<T>();
}

class _OptionsSheetState<T> extends State<_OptionsSheet<T>> {
  static const double _itemExtent = 56;

  late final ScrollController _controller = ScrollController(
    // Tanlangan element ro'yxat uzun bo'lsa ham darhol ko'rinib turadi.
    initialScrollOffset: () {
      final index = widget.options.indexWhere((o) => o.selected);
      return index <= 3 ? 0.0 : (index - 3) * _itemExtent;
    }(),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (widget.message != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.message!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.55,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              controller: _controller,
              itemExtent: _itemExtent,
              itemCount: widget.options.length,
              itemBuilder: (context, index) {
                final option = widget.options[index];
                return ListTile(
                  title: Text(option.label),
                  trailing: option.selected
                      ? Icon(Icons.check, color: scheme.primary)
                      : null,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pop(option.value);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
