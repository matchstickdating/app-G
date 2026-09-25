import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/match_card.dart';
import '../../domain/entities/date_plan_entity.dart';

class DateItineraryCard extends StatelessWidget {
  final DatePlanEntity plan;

  const DateItineraryCard({
    super.key,
    required this.plan,
  });

  IconData _getVenueIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cafe':
        return Icons.local_cafe_outlined;
      case 'walk':
        return Icons.directions_walk_outlined;
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'dessert':
        return Icons.icecream_outlined;
      case 'bar':
        return Icons.wine_bar_outlined;
      default:
        return Icons.place_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MatchCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan.city.toLowerCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                  letterSpacing: -0.01 * 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${plan.vibe} • ${plan.budgetTier}',
                  style: AppTypography.caption(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            plan.title.toLowerCase(),
            style: AppTypography.headingSmall(),
          ),
          const SizedBox(height: 20),

          // Itinerary Timeline
          ...List.generate(plan.itinerary.length, (index) {
            final stop = plan.itinerary[index];
            final isLast = index == plan.itinerary.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline Indicator
                  Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Icon(
                          _getVenueIcon(stop.venueType),
                          size: 14,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 1,
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),

                  // Stop Details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                stop.time.toLowerCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  stop.title.toLowerCase(),
                                  style: AppTypography.bodyMedium().copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stop.description,
                            style: AppTypography.caption(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
