import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// Ha/yo'q tasdiqlash. `true` — foydalanuvchi tasdiqladi.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  bool destructive = false,
  IconData? icon,
}) async {
  final l10n = AppL10n.of(context);
  final scheme = Theme.of(context).colorScheme;

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: icon == null
          ? null
          : Icon(icon, color: destructive ? scheme.error : scheme.primary),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                  minimumSize: const Size(0, 44),
                )
              : FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          child: Text(confirmLabel ?? l10n.actionOk),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Ikki bosqichli tasdiq: foydalanuvchi so'zni yozishi kerak.
/// "Barcha ma'lumotni o'chirish" kabi qaytarib bo'lmaydigan amallar uchun.
Future<bool> confirmByTyping(
  BuildContext context, {
  required String title,
  required String message,
  required String word,
}) async {
  final l10n = AppL10n.of(context);
  final scheme = Theme.of(context).colorScheme;
  final controller = TextEditingController();

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          final matches = controller.text.trim().toUpperCase() == word;
          return AlertDialog(
            icon: Icon(Icons.warning_amber_rounded, color: scheme.error),
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(message),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(hintText: word),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.actionCancel),
              ),
              FilledButton(
                onPressed: matches
                    ? () => Navigator.of(dialogContext).pop(true)
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                  minimumSize: const Size(0, 44),
                ),
                child: Text(l10n.actionDelete),
              ),
            ],
          );
        },
      );
    },
  );

  controller.dispose();
  return result ?? false;
}
