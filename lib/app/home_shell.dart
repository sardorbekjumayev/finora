import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import 'router.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

/// Pastki navigatsiya: oq 80px panel, markazda 28px ko'tarilgan
/// "qo'shish" tugmasi (`plan/Main.dc.html`).
///
/// `NavigationBar` o'rniga qo'lda yig'ilgan — maketdagi ko'tarilgan tugma va
/// 11/700 yorliqlarni Material standarti bermaydi.
class HomeShell extends StatelessWidget {
  const HomeShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  /// Tugma panel ustiga qancha chiqib turadi.
  static const double _liftedBy = 28;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      body: Stack(
        children: [
          // Panel kontent ustida turadi — ro'yxatlar pastdan 120px bo'sh
          // joy qoldiradi, shunda oxirgi element panel ostida qolmaydi.
          Positioned.fill(child: shell),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: AppDims.navBar + bottomInset + _liftedBy,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: AppDims.navBar + bottomInset,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: palette.surface,
                        border: Border(
                          top: BorderSide(color: palette.border),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: bottomInset + 8,
                    height: AppDims.navBar - 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _NavItem(
                          icon: Icons.home_outlined,
                          activeIcon: Icons.home,
                          label: l10n.navHome,
                          selected: shell.currentIndex == 0,
                          onTap: () => _go(0),
                        ),
                        _NavItem(
                          icon: Icons.format_list_bulleted,
                          activeIcon: Icons.format_list_bulleted,
                          label: l10n.navTransactions,
                          selected: shell.currentIndex == 1,
                          onTap: () => _go(1),
                        ),
                        // Markazdagi tugma uchun bo'sh o'rin.
                        const SizedBox(width: AppDims.fab),
                        _NavItem(
                          icon: Icons.bar_chart_outlined,
                          activeIcon: Icons.bar_chart,
                          label: l10n.navStats,
                          selected: shell.currentIndex == 2,
                          onTap: () => _go(2),
                        ),
                        _NavItem(
                          icon: Icons.grid_view_outlined,
                          activeIcon: Icons.grid_view,
                          label: l10n.navMore,
                          selected: shell.currentIndex == 3,
                          onTap: () => _go(3),
                        ),
                      ],
                    ),
                  ),
                  // Tugma panelning yuqori chetiga markazlashadi.
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: AppDims.fab,
                    child: Center(
                      child: _AddButton(
                        tooltip: l10n.txNew,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          context.push(Routes.txNew);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _go(int index) {
    HapticFeedback.selectionClick();
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = selected ? palette.primary : palette.textMuted;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? activeIcon : icon, size: 22, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.tiny.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.tooltip, required this.onTap});

  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: Material(
          color: palette.primary,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: AppDims.fab,
              height: AppDims.fab,
              child: Icon(Icons.add, size: 28, color: palette.onPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
