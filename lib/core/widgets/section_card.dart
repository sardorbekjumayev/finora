import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';

/// Bosh sahifadagi bo'limlar uchun bir xil kartochka.
class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.child,
    super.key,
    this.title,
    this.trailing,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final String? title;
  final Widget? trailing;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title!,
                          style: AppText.cardTitle.copyWith(
                            color: palette.textPrimary,
                          ),
                        ),
                      ),
                      ?trailing,
                    ],
                  ),
                ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Ro'yxatlar ustidagi sarlavha. Maketda bo'lim sarlavhalari 16/800 va
/// bosh harfga aylantirilmaydi (`plan/Main.dc.html`).
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDims.pagePadding,
        20,
        AppDims.pagePadding,
        8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppText.strong.copyWith(
                color: context.palette.textPrimary,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
