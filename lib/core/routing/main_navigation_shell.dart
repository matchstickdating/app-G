import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../../features/chat/presentation/screens/matches_and_chat_screen.dart';
import '../../features/community/presentation/screens/community_feed_screen.dart';
import '../../features/discovery/presentation/screens/discovery_screen.dart';
import '../../features/matching/presentation/screens/likes_screen.dart';
import '../../features/profile/presentation/screens/profile_detail_screen.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({super.key, this.initialIndex = 0});

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
    final isDiscover = _currentIndex == 0;

    final pages = const [
      DiscoveryScreen(),
      LikesScreen(),
      CommunityFeedScreen(),
      MatchesAndChatScreen(),
      ProfileDetailScreen(isMyProfile: true),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDiscover
              ? const Color(0xFF101311)
              : (isDark ? AppColors.darkSurface : const Color(0xFFE8FFF5)),
          border: Border(
            top: BorderSide(
              color: isDiscover
                  ? Colors.white12
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: isDiscover ? 64 : 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  0,
                  'Discover',
                  Icons.explore_outlined,
                  Icons.explore,
                  isDark,
                ),
                _buildNavItem(
                  1,
                  'Likes',
                  Icons.favorite_border,
                  Icons.favorite,
                  isDark,
                ),
                _buildNavItem(
                  2,
                  'Lounges',
                  Icons.forum_outlined,
                  Icons.forum,
                  isDark,
                ),
                _buildNavItem(
                  3,
                  'Messages',
                  Icons.chat_bubble_outline,
                  Icons.chat_bubble,
                  isDark,
                ),
                _buildNavItem(
                  4,
                  'Profile',
                  Icons.person_outline,
                  Icons.person,
                  isDark,
                ),
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
    final isDiscover = _currentIndex == 0;
    final color = isDiscover
        ? (isSelected ? const Color(0xFFFF70AB) : Colors.white60)
        : isSelected
        ? (index == 1
              ? AppColors.accent
              : (isDark ? AppColors.primaryLight : AppColors.primary))
        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);

    return Expanded(
      child: Center(
        child: Semantics(
          button: true,
          selected: isSelected,
          label: label,
          child: Tooltip(
            message: label,
            excludeFromSemantics: true,
            child: InkWell(
              onTap: () => setState(() => _currentIndex = index),
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                width: 72,
                height: isDiscover ? 60 : 76,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 44,
                      height: isDiscover ? 32 : 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDiscover
                            ? (isSelected ? Colors.white12 : Colors.transparent)
                            : isSelected
                            ? (isDark
                                  ? AppColors.darkSurfaceSubtle
                                  : AppColors.primarySubtle)
                            : Colors.transparent,
                      ),
                      child: Icon(
                        isSelected ? selectedIcon : unselectedIcon,
                        size: index == 2 ? 22 : 23,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 3),
                    ExcludeSemantics(
                      child: Text(
                        label,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
