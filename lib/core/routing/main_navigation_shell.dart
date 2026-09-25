import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../features/chat/presentation/screens/matches_and_chat_screen.dart';
import '../../features/discovery/presentation/screens/discovery_screen.dart';
import '../../features/matching/presentation/screens/likes_screen.dart';
import '../../features/profile/presentation/screens/profile_detail_screen.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = const [
      DiscoveryScreen(),
      LikesScreen(),
      MatchesAndChatScreen(),
      ProfileDetailScreen(isMyProfile: true),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 62,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, 'discover', Icons.explore_outlined, Icons.explore, isDark),
                _buildNavItem(1, 'likes', Icons.favorite_border, Icons.favorite, isDark),
                _buildNavItem(2, 'messages', Icons.chat_bubble_outline, Icons.chat_bubble, isDark),
                _buildNavItem(3, 'profile', Icons.person_outline, Icons.person, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String label,
    IconData unselectedIcon,
    IconData selectedIcon,
    bool isDark,
  ) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
        : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minWidth: 64, minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              size: 20,
              color: color,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.navigation(
                color: color,
                isActive: isSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
