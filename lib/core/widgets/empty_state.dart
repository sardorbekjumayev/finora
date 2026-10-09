import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';

/// Bo'sh holat: do'stona ikonka, sarlavha, tushuntirish va bitta harakat.
/// Illyustratsiya o'rniga **ikonka** ishlatiladi (stiker/emoji yo'q).
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    super.key,
    this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 32,
          vertical: compact ? 24 : 48,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 64 : 88,
              height: compact ? 64 : 88,
              decoration: BoxDecoration(
                color: palette.primaryTint,
                borderRadius: BorderRadius.circular(compact ? 20 : 28),
              ),
              child: Icon(
                icon,
                size: compact ? 30 : 40,
                color: palette.primary,
              ),
            ),
            SizedBox(height: compact ? 16 : 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.strong.copyWith(color: palette.textPrimary),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(color: palette.textMuted),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 22),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, AppDims.secondaryButton),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
