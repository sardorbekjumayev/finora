import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/utils/date_labels.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../../core/widgets/design_kit.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../accounts/data/account_repository.dart';
import '../../categories/data/category_repository.dart';

/// "Yana" bo'limi — boshqaruv ekranlariga kirish nuqtasi.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final settings = ref.watch(settingsProvider);
    final accounts = ref.watch(accountsProvider).value;
    final categories = ref.watch(activeCategoriesProvider).value;

    final palette = context.palette;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(title: l10n.navMore),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(
                  bottom: AppDims.navBarClearance,
                ),
                children: [
                  if (_backupIsStale(settings.lastBackupAt))
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDims.pagePadding,
                      ),
                      child:
                          _BackupReminder(lastBackupAt: settings.lastBackupAt),
                    ),
                  const SizedBox(height: 20),
                  SectionTitle(l10n.setSectionData),
                  const SizedBox(height: 8),
                  _TileGroup(
                    children: [
                      _Tile(
                        icon: Icons.account_balance_wallet_outlined,
                        title: l10n.setManageAccounts,
                        subtitle: accounts == null ? null : '${accounts.length}',
                        onTap: () => context.push(Routes.accounts),
                      ),
                      _Tile(
                        showDivider: true,
                        icon: Icons.category_outlined,
                        title: l10n.setManageCategories,
                        subtitle:
                            categories == null ? null : '${categories.length}',
                        onTap: () => context.push(Routes.categories),
                      ),
                      _Tile(
                        showDivider: true,
                        icon: Icons.backup_outlined,
                        title: l10n.setBackup,
                        subtitle: settings.lastBackupAt == null
                            ? l10n.bkpNever
                            : l10n.bkpLast(
                                DateLabels.shortDate(
                                  context,
                                  settings.lastBackupAt!,
                                ),
                              ),
                        onTap: () => context.push(Routes.backup),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SectionTitle(l10n.setSectionGeneral),
                  const SizedBox(height: 8),
                  _TileGroup(
                    children: [
                      _Tile(
                        icon: Icons.settings_outlined,
                        title: l10n.setTitle,
                        onTap: () => context.push(Routes.settings),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SectionTitle(l10n.setSectionAbout),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDims.pagePadding,
                    ),
                    child: DesignCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BrandLogo(
                            markSize: 40,
                            wordmarkSize: 26,
                            showTagline: true,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 20,
                                color: palette.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.setPrivacyBody,
                                  style: AppText.hint.copyWith(
                                    color: palette.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  /// 14 kundan ortiq zaxira olinmagan bo'lsa eslatiladi — ilova o'chirilsa
  /// data butunlay yo'qoladi, shuning uchun bu eslatma muhim.
  static bool _backupIsStale(DateTime? last) {
    if (last == null) return true;
    return DateTime.now().difference(last).inDays >= 14;
  }
}

class _BackupReminder extends StatelessWidget {
  const _BackupReminder({required this.lastBackupAt});

  final DateTime? lastBackupAt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final days = lastBackupAt == null
        ? null
        : DateTime.now().difference(lastBackupAt!).inDays;

    return DesignCard(
      color: palette.expenseTint,
      padding: const EdgeInsets.all(14),
      onTap: () => context.push(Routes.backup),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, size: 22, color: palette.expense),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              days == null ? l10n.bkpNever : l10n.bkpReminder(days),
              style: AppText.label.copyWith(color: palette.expense),
            ),
          ),
          Icon(Icons.chevron_right, size: 22, color: palette.expense),
        ],
      ),
    );
  }
}

/// Bir nechta qatorni bitta kartochkaga yig'adi — maketdagi guruhlangan
/// ro'yxatlar shaklida.
class _TileGroup extends StatelessWidget {
  const _TileGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDims.pagePadding),
      child: DesignCard(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: children),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.showDivider = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  /// Kartochka ichidagi birinchi qatordan keyin 1px chegara chiziladi.
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return ValueRow(
      icon: icon,
      label: title,
      value: subtitle ?? '',
      onTap: onTap,
      showDivider: showDivider,
    );
  }
}
