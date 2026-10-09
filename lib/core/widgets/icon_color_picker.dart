import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../constants/app_icons.dart';
import 'design_kit.dart';

/// Ikonka tanlash — pastdan chiqadigan panel. Faqat Material ikonkalar.
Future<String?> showIconPicker(
  BuildContext context, {
  required String title,
  String? selected,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => _IconPickerSheet(
      title: title,
      selected: selected,
    ),
  );
}

class _IconPickerSheet extends StatelessWidget {
  const _IconPickerSheet({required this.title, this.selected});

  final String title;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final keys = AppIcons.keys;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: AppText.sheetTitle.copyWith(color: palette.textPrimary),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.5,
              ),
              child: GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: keys.length,
                itemBuilder: (context, index) {
                  final key = keys[index];
                  final isSelected = key == selected;
                  return Semantics(
                    selected: isSelected,
                    button: true,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).pop(key);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppDims.tile),
                          color: isSelected
                              ? palette.primaryTint
                              : palette.surfaceAlt,
                          border: isSelected
                              ? Border.all(color: palette.primary, width: 2)
                              : null,
                        ),
                        child: Icon(
                          AppIcons.resolve(key),
                          size: 22,
                          color: isSelected
                              ? palette.primary
                              : palette.textMuted,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rang tanlash — gorizontal lenta.
class ColorPickerRow extends StatelessWidget {
  const ColorPickerRow({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: AppColors.palette.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final color = AppColors.palette[index];
          final isSelected = color.toARGB32() == selected;
          return Semantics(
            selected: isSelected,
            button: true,
            label: 'Rang ${index + 1}',
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(color.toARGB32());
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: palette.adapt(color),
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: palette.textPrimary, width: 3)
                      : null,
                ),
                child: isSelected
                    ? Icon(Icons.check, color: palette.onHero, size: 20)
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Kategoriya / hisob ikonkasi: maketdagi yumaloq kvadrat plitka
/// (44×44 → radius 14, 48×48 → radius 16).
class IconBadge extends StatelessWidget {
  const IconBadge({
    required this.iconKey,
    required this.colorValue,
    super.key,
    this.size = AppDims.rowIcon,
    this.radius,
  });

  final String iconKey;
  final int colorValue;
  final double size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return IconTile(
      icon: AppIcons.resolve(iconKey),
      color: Color(colorValue),
      size: size,
      radius: radius,
    );
  }
}
