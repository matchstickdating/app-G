import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/match_button.dart';
import '../../../../core/widgets/match_card.dart';
import '../../../../core/widgets/match_chip.dart';
import '../../../../core/widgets/match_text.dart';
import '../../../../core/widgets/match_toast.dart';
import '../controllers/date_planner_controller.dart';
import 'date_planner_screen.dart';

class DateIdeaItem {
  final String id;
  final String title;
  final String category;
  final String description;
  final String vibe;
  final String duration;
  final String budget;
  final String bestTime;
  final List<String> tags;

  const DateIdeaItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.vibe,
    required this.duration,
    required this.budget,
    required this.bestTime,
    required this.tags,
  });
}

class DateIdeasScreen extends ConsumerStatefulWidget {
  final String? partnerName;
  final ValueChanged<String>? onShareToChat;

  const DateIdeasScreen({
    super.key,
    this.partnerName,
    this.onShareToChat,
  });

  @override
  ConsumerState<DateIdeasScreen> createState() => _DateIdeasScreenState();
}

class _DateIdeasScreenState extends ConsumerState<DateIdeasScreen> {
  String _selectedCategory = 'all';

  final List<String> _categories = [
    'all',
    'cozy',
    'cultural',
    'culinary',
    'adventurous',
    'scenic',
  ];

  final List<DateIdeaItem> _ideas = const [
    DateIdeaItem(
      id: 'idea-1',
      title: 'vintage bookstore & quiet pour-over',
      category: 'cozy',
      description:
          'browse second-hand literature, pick out a book for each other, and discuss the first chapter over single-origin filter coffee.',
      vibe: 'cozy',
      duration: '2 hours',
      budget: '\$',
      bestTime: 'weekend afternoon',
      tags: ['books', 'coffee', 'conversation'],
    ),
    DateIdeaItem(
      id: 'idea-2',
      title: 'modern gallery crawl & natural wine',
      category: 'cultural',
      description:
          'explore contemporary exhibitions at local independent galleries, followed by small plates and low-intervention wine.',
      vibe: 'cultural',
      duration: '3 hours',
      budget: '\$\$',
      bestTime: 'friday evening',
      tags: ['art', 'wine', 'architecture'],
    ),
    DateIdeaItem(
      id: 'idea-3',
      title: 'sunset beach stroll & artisanal gelato',
      category: 'scenic',
      description:
          'take an unhurried seaside walk along the promenade during golden hour, concluding at a local craft gelateria.',
      vibe: 'scenic',
      duration: '1.5 hours',
      budget: '\$',
      bestTime: 'sunset / 5:30 pm',
      tags: ['outdoors', 'sunset', 'dessert'],
    ),
    DateIdeaItem(
      id: 'idea-4',
      title: 'vinyl listening bar & cocktail tasting',
      category: 'cultural',
      description:
          'listen to analog Japanese jazz and vintage soul records over bespoke cocktails in a warm, low-lit acoustic haven.',
      vibe: 'intimate',
      duration: '2.5 hours',
      budget: '\$\$\$',
      bestTime: 'late evening / 9 pm',
      tags: ['music', 'vinyl', 'nightlife'],
    ),
    DateIdeaItem(
      id: 'idea-5',
      title: 'farmers market scavenger & homemade brunch',
      category: 'culinary',
      description:
          'discover fresh sourdough, organic berries, and artisanal cheese together, then brew pour-overs on a park lawn.',
      vibe: 'culinary',
      duration: '2.5 hours',
      budget: '\$',
      bestTime: 'saturday morning',
      tags: ['food', 'farmers market', 'morning'],
    ),
    DateIdeaItem(
      id: 'idea-6',
      title: 'pottery wheel throwing workshop',
      category: 'adventurous',
      description:
          'get your hands dirty in a beginner-friendly ceramics studio. create custom cups and share laughs over messy clay.',
      vibe: 'adventurous',
      duration: '2 hours',
      budget: '\$\$',
      bestTime: 'sunday afternoon',
      tags: ['craft', 'workshop', 'interactive'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredIdeas = _selectedCategory == 'all'
        ? _ideas
        : _ideas.where((idea) => idea.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 16, color: AppColors.accent),
            const SizedBox(width: 8),
            const MatchText(
              'curated date ideas',
              style: MatchTextStyle.navigation,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            const MatchText(
              'intentional dates.',
              style: MatchTextStyle.hero,
            ),
            const SizedBox(height: 8),
            Text(
              widget.partnerName != null
                  ? 'low-pressure, high-chemistry concepts curated for you and ${widget.partnerName!.toLowerCase()}.'
                  : 'low-pressure, high-chemistry date concepts centered around authentic human connection.',
              style: AppTypography.bodyMedium(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: MatchChip(
                      label: cat,
                      isSelected: isSelected,
                      onSelected: () => setState(() => _selectedCategory = cat),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Date Idea Cards
            ...filteredIdeas.map((idea) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: MatchCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Badges
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              idea.category.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Text(
                            '${idea.budget} • ${idea.duration}',
                            style: AppTypography.caption(
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Title
                      Text(
                        idea.title.toLowerCase(),
                        style: AppTypography.headingSmall(),
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        idea.description,
                        style: AppTypography.bodyMedium(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Best Time & Tags
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 14,
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            idea.bestTime,
                            style: AppTypography.caption(
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: MatchButton(
                              text: '✦ build itinerary',
                              variant: MatchButtonVariant.secondary,
                              size: MatchButtonSize.compact,
                              onPressed: () {
                                ref.read(datePlannerControllerProvider.notifier).setVibe(idea.vibe);
                                ref.read(datePlannerControllerProvider.notifier).setBudget(idea.budget);
                                Navigator.of(context).push(
                                  MotionTokens.editorialPageRoute(
                                    page: DatePlannerScreen(
                                      partnerName: widget.partnerName,
                                      onShareToChat: widget.onShareToChat,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (widget.onShareToChat != null) ...[
                            const SizedBox(width: 8),
                            MatchButton(
                              text: 'suggest idea',
                              variant: MatchButtonVariant.outline,
                              size: MatchButtonSize.compact,
                              isFullWidth: false,
                              onPressed: () {
                                final shareText =
                                    '💡 Date Idea: "${idea.title}"\n${idea.description}\nBest time: ${idea.bestTime} (${idea.duration})';
                                widget.onShareToChat!(shareText);
                                MatchToast.show(context, message: 'date idea shared to conversation.');
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
