import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../features/chat/presentation/screens/matches_and_chat_screen.dart';
import '../../features/community/presentation/screens/community_feed_screen.dart';
import '../../features/discovery/presentation/screens/discovery_screen.dart';
import '../../features/matching/presentation/screens/likes_screen.dart';

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
    _currentIndex = widget.initialIndex >= 0 && widget.initialIndex < 4
        ? widget.initialIndex
        : 0;
  }

  @override
  Widget build(BuildContext context) {
    final pages = const [
      DiscoveryScreen(),
      LikesScreen(),
      CommunityFeedScreen(),
      MatchesAndChatScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                key: const Key('primary-navigation-pill'),
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0x993C5C65),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.white38),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _navItem(
                      0,
                      'Discover',
                      CupertinoIcons.compass,
                      CupertinoIcons.compass_fill,
                    ),
                    _navItem(
                      1,
                      'Likes',
                      CupertinoIcons.heart,
                      CupertinoIcons.heart_fill,
                    ),
                    _navItem(
                      2,
                      'Community',
                      CupertinoIcons.person_2,
                      CupertinoIcons.person_2_fill,
                    ),
                    _navItem(
                      3,
                      'Messages',
                      CupertinoIcons.chat_bubble_2,
                      CupertinoIcons.chat_bubble_2_fill,
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

  Widget _navItem(
    int index,
    String label,
    IconData icon,
    IconData selectedIcon,
  ) {
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
            borderRadius: BorderRadius.circular(36),
            child: SizedBox.expand(
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 64,
                  height: 60,
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(alpha: .17)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(34),
                  ),
                  child: Icon(
                    selected ? selectedIcon : icon,
                    size: 27,
                    color: selected ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
