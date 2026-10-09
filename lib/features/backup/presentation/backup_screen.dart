import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/services/settings_service.dart';
import '../../../core/utils/date_labels.dart';
import '../../../core/utils/date_range.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/section_card.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../statistics/presentation/period_providers.dart';
import '../data/backup_service.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  /// Bir vaqtda faqat bitta uzoq amal ishlaydi.
  String? _busy;

  bool get _idle => _busy == null;

  Future<void> _run(String tag, Future<void> Function() action) async {
    if (!_idle) return;
    setState(() => _busy = tag);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _createBackup() => _run('backup', () async {
        final l10n = AppL10n.of(context);
        final file = await ref.read(backupServiceProvider).writeBackupFile();

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path, mimeType: 'application/json')],
            subject: l10n.bkpShareSubject,
          ),
        );

        await ref.read(settingsProvider.notifier).markBackupNow();
        HapticFeedback.mediumImpact();
        _toast(l10n.bkpCreated);
      });

  Future<void> _restore() => _run('restore', () async {
        final l10n = AppL10n.of(context);

        final picked = await FilePicker.pickFile(
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
        final path = picked?.path;
        if (path == null || !mounted) return;

        final ok = await confirm(
          context,
          title: l10n.bkpRestoreTitle,
          message: l10n.bkpRestoreConfirmBody,
          confirmLabel: l10n.bkpRestore,
          destructive: true,
          icon: Icons.restore_outlined,
        );
        if (!ok) return;

        try {
          final content = await File(path).readAsString();
          final stats =
              await ref.read(backupServiceProvider).restoreFromJson(content);

          // Tiklangan bazada kategoriyalar bor — onboarding qayta kerak emas.
          await ref.read(settingsProvider.notifier).completeOnboarding();
          HapticFeedback.mediumImpact();
          _toast(
            l10n.bkpRestored(stats.accounts, stats.transactions),
          );
        } on BackupVersionException {
          _toast(l10n.bkpVersionMismatch);
        } on BackupFormatException {
          _toast(l10n.bkpInvalidFile);
        } on FileSystemException {
          _toast(l10n.bkpInvalidFile);
        }
      });

  Future<void> _exportCsv() => _run('csv', () async {
        final l10n = AppL10n.of(context);
        final period = ref.read(periodProvider);

        final range = await _pickCsvRange(period);
        if (range == null || !mounted) return;

        final file = await ref
            .read(backupServiceProvider)
            .writeCsvFile(range: range.value);

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path, mimeType: 'text/csv')],
            subject: l10n.bkpExportCsv,
          ),
        );
        _toast(l10n.bkpExported);
      });

  /// Davr tanlash: joriy davr yoki butun tarix.
  /// `null` qaytsa — foydalanuvchi bekor qildi.
  Future<_RangeChoice?> _pickCsvRange(DateRange period) {
    final l10n = AppL10n.of(context);

    return showModalBottomSheet<_RangeChoice>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Text(
                l10n.bkpExportCsv,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.date_range_outlined),
              title: Text(DateLabels.rangeLabel(sheetContext, period)),
              onTap: () => Navigator.of(sheetContext)
                  .pop(_RangeChoice(period)),
            ),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: Text(l10n.labelAll),
              onTap: () =>
                  Navigator.of(sheetContext).pop(const _RangeChoice(null)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final lastBackupAt = ref.watch(settingsProvider).lastBackupAt;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bkpTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          SectionHeader(l10n.bkpSectionBackup),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ActionCard(
                  icon: Icons.ios_share_outlined,
                  title: l10n.bkpCreate,
                  body: l10n.bkpCreateBody,
                  footnote: lastBackupAt == null
                      ? l10n.bkpNever
                      : l10n.bkpLast(
                          DateLabels.dateTime(context, lastBackupAt),
                        ),
                  loading: _busy == 'backup',
                  onTap: _idle ? _createBackup : null,
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  icon: Icons.restore_outlined,
                  title: l10n.bkpRestore,
                  body: l10n.bkpRestoreBody,
                  loading: _busy == 'restore',
                  onTap: _idle ? _restore : null,
                ),
              ],
            ),
          ),
          SectionHeader(l10n.bkpSectionExport),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ActionCard(
              icon: Icons.table_chart_outlined,
              title: l10n.bkpExportCsv,
              body: l10n.bkpExportCsvBody,
              loading: _busy == 'csv',
              onTap: _idle ? _exportCsv : null,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.setPrivacyBody,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// `null` — butun tarix. Bekor qilishni `null` javobdan ajratish uchun
/// tanlov o'ramga olingan.
class _RangeChoice {
  const _RangeChoice(this.value);

  final DateRange? value;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.loading,
    required this.onTap,
    this.footnote,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? footnote;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: loading
                    ? const CircularProgressIndicator(strokeWidth: 2.5)
                    : Icon(icon, color: scheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: text.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: text.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    if (footnote != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        footnote!,
                        style: text.labelSmall?.copyWith(color: scheme.primary),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
