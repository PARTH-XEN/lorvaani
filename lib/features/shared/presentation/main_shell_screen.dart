import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/comic_colors.dart';
import '../../../core/theme/comic_typography.dart';

/// Comic Universe Main Navigation Shell with Comic Bottom Bar
class MainShellScreen extends StatelessWidget {
  final Widget child;

  const MainShellScreen({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/create')) return 2;
    if (location.startsWith('/library')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/explore');
        break;
      case 2:
        context.go('/create');
        break;
      case 3:
        context.go('/library');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: ComicColors.cardBackground,
          border: const Border(
            top: BorderSide(color: ComicColors.comicBorder, width: 2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  index: 0,
                  icon: Icons.cottage_rounded,
                  label: 'Home',
                  isSelected: selectedIndex == 0,
                ),
                _buildNavItem(
                  context: context,
                  index: 1,
                  icon: Icons.explore_rounded,
                  label: 'Explore',
                  isSelected: selectedIndex == 1,
                ),
                _buildCenterCreateButton(
                  context: context,
                  isSelected: selectedIndex == 2,
                ),
                _buildNavItem(
                  context: context,
                  index: 3,
                  icon: Icons.auto_stories_rounded,
                  label: 'Library',
                  isSelected: selectedIndex == 3,
                ),
                _buildNavItem(
                  context: context,
                  index: 4,
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: selectedIndex == 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    final color = isSelected ? ComicColors.comicPink : ComicColors.textSecondary;

    return InkWell(
      onTap: () => _onItemTapped(index, context),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected
                    ? ComicColors.comicPink.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: ComicTypography.caption(
                fontSize: 11,
                color: color,
              ).copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterCreateButton({
    required BuildContext context,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _onItemTapped(2, context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: ComicColors.dimensionGradient,
          shape: BoxShape.circle,
          border: Border.all(color: ComicColors.comicBorder, width: 2),
          boxShadow: [
            BoxShadow(
              color: ComicColors.comicPurple.withValues(alpha: 0.6),
              offset: const Offset(0, 3),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: ComicColors.softWhite,
          size: 26,
        ),
      ),
    );
  }
}

