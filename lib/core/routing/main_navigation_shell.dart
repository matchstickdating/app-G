import 'package:flutter/material.dart';

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
    final pages = const [
      DiscoveryScreen(),
      LikesScreen(),
      CommunityFeedScreen(),
      MatchesAndChatScreen(),
      ProfileDetailScreen(isMyProfile: true),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: ColoredBox(
        color: const Color(0xFFBA4C91),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Container(
              key: const Key('primary-navigation-pill'),
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _navItem(0, 'Discover', Icons.home_outlined),
                  _navItem(1, 'Likes', Icons.favorite_border_rounded),
                  _navItem(2, 'Community', Icons.groups_outlined),
                  _navItem(3, 'Messages', Icons.chat_bubble_outline_rounded),
                  _navItem(4, 'Profile', Icons.person_outline_rounded),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, String label, IconData icon) {
    final selected = _currentIndex == index;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Tooltip(
          message: label,
          excludeFromSemantics: true,
          child: InkWell(
            onTap: () => setState(() => _currentIndex = index),
            borderRadius: BorderRadius.circular(24),
            child: SizedBox.expand(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 27,
                    color: selected
                        ? const Color(0xFFAA357C)
                        : const Color(0xFF343638),
                  ),
                  const SizedBox(height: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: selected ? 38 : 0,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBA4C91),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
