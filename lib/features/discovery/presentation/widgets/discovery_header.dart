import 'package:flutter/material.dart';

import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/widgets/profile_photo.dart';
import '../../../ai/presentation/screens/match_coach_screen.dart';
import '../../../date_planner/presentation/screens/date_ideas_screen.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../../../profile/presentation/screens/profile_detail_screen.dart';
import '../../../safety/presentation/screens/safety_center_screen.dart';

class DiscoveryHeader extends StatelessWidget {
  final ProfileEntity? profile;
  final bool todaysPicks;
  final VoidCallback onToggleFeed;
  final VoidCallback? onRewind;
  final VoidCallback? onSearch;

  const DiscoveryHeader({
    super.key,
    this.profile,
    required this.todaysPicks,
    required this.onToggleFeed,
    this.onRewind,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    void open(Widget screen) =>
        Navigator.of(context)
            .push(MotionTokens.editorialPageRoute(page: screen));
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Material(
                color: Colors.white.withValues(alpha: .18),
                shape: const StadiumBorder(
                  side: BorderSide(color: Colors.white24),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () =>
                      open(const ProfileDetailScreen(isMyProfile: true)),
                  child: Tooltip(
                    message: 'My profile',
                    child: Semantics(
                      button: true,
                      label: 'My profile',
                      child: Padding(
                        padding: const EdgeInsets.all(7),
                        child: Row(
                          children: [
                            ClipOval(
                              child: SizedBox(
                                width: 34,
                                height: 34,
                                child: profile?.primaryPhotoUrl == null
                                    ? const ColoredBox(
                                        color: Color(0xFF66736C),
                                        child: Icon(
                                          Icons.person_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      )
                                    : FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                          width: 160,
                                          height: 200,
                                          child: ProfilePhoto(
                                            url: profile!.primaryPhotoUrl,
                                            name: profile!.displayName,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(
                                Icons.add_rounded,
                                size: 19,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              _glassButton(
                'Search people or interests',
                Icons.search_rounded,
                onSearch,
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.white.withValues(alpha: .18),
                shape: const CircleBorder(
                  side: BorderSide(color: Colors.white24),
                ),
                child: PopupMenuButton<String>(
                  tooltip: 'Discovery options',
                  icon: const Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'rewind':
                        onRewind?.call();
                      case 'dates':
                        open(const DateIdeasScreen());
                      case 'coach':
                        open(const MatchCoachScreen());
                      case 'safety':
                        open(const SafetyCenterScreen());
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'rewind',
                      enabled: onRewind != null,
                      child: const Text('Rewind last profile'),
                    ),
                    const PopupMenuItem(
                      value: 'dates',
                      child: Text('Date ideas'),
                    ),
                    const PopupMenuItem(value: 'coach', child: Text('Coach')),
                    const PopupMenuItem(value: 'safety', child: Text('Safety')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _feedChip('All', !todaysPicks, () {
                if (todaysPicks) onToggleFeed();
              }),
              const SizedBox(width: 8),
              Flexible(
                child: _feedChip("Today's picks", todaysPicks, () {
                  if (!todaysPicks) onToggleFeed();
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _glassButton(String label, IconData icon, VoidCallback? onTap) {
    return Material(
      color: Colors.white.withValues(alpha: .18),
      shape: const CircleBorder(side: BorderSide(color: Colors.white24)),
      child: IconButton(
        tooltip: label,
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _feedChip(String label, bool selected, VoidCallback onTap) {
    return Semantics(
      selected: selected,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: selected ? Colors.white : Colors.white70,
          backgroundColor: selected
              ? Colors.white.withValues(alpha: .2)
              : Colors.black26,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          minimumSize: const Size(48, 48),
          side: BorderSide(
            color: selected ? Colors.white38 : Colors.transparent,
          ),
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
