import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'match_avatar.dart';
import 'match_bottom_sheet.dart';
import 'match_button.dart';
import 'match_card.dart';
import 'match_chip.dart';
import 'match_loading_indicator.dart';
import 'match_text.dart';
import 'match_text_field.dart';
import 'match_toast.dart';

class DesignSystemShowcase extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const DesignSystemShowcase({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  State<DesignSystemShowcase> createState() => _DesignSystemShowcaseState();
}

class _DesignSystemShowcaseState extends State<DesignSystemShowcase> {
  final Set<String> _selectedChips = {'specialty coffee', 'film & cinema'};
  final TextEditingController _inputController = TextEditingController();
  bool _isButtonLoading = false;

  final List<String> _sampleInterests = [
    'specialty coffee',
    'vinyl records',
    'film & cinema',
    'architecture',
    'contemporary art',
    'minimalism',
    'night walks',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Scaffold(
      appBar: AppBar(
        title: const MatchText(
          'match stick design system',
          style: MatchTextStyle.navigation,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
            ),
            tooltip: 'Toggle Theme',
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            // Hero Title
            const MatchText(
              'meet someone\nworth knowing.',
              style: MatchTextStyle.hero,
            ),
            const SizedBox(height: 12),
            const MatchText(
              'less swiping. more connection. intentional dating combining intelligent matching, editorial aesthetics, and thoughtful ai assistance.',
              style: MatchTextStyle.bodyLarge,
            ),
            const SizedBox(height: 36),

            // Section: Colors & Theme Tokens
            _buildSectionHeader('01 / color foundation'),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildColorBox('bg', isDark ? AppColors.darkBackground : AppColors.lightBackground, border: true),
                const SizedBox(width: 10),
                _buildColorBox('surface', isDark ? AppColors.darkSurface : AppColors.lightSurface, border: true),
                const SizedBox(width: 10),
                _buildColorBox('primary', isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                const SizedBox(width: 10),
                _buildColorBox('secondary', isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                const SizedBox(width: 10),
                _buildColorBox('accent', AppColors.accent),
              ],
            ),
            const SizedBox(height: 36),

            // Section: Typography Hierarchy
            _buildSectionHeader('02 / readex pro typography'),
            const SizedBox(height: 16),
            MatchCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MatchText('heading large (32px)', style: MatchTextStyle.headingLarge),
                  const SizedBox(height: 8),
                  const MatchText('heading medium (24px)', style: MatchTextStyle.headingMedium),
                  const SizedBox(height: 8),
                  const MatchText('heading small (18px)', style: MatchTextStyle.headingSmall),
                  const SizedBox(height: 12),
                  const MatchText(
                    '"always planning my next trip and probably my next meal."',
                    style: MatchTextStyle.prompt,
                  ),
                  const SizedBox(height: 12),
                  const MatchText(
                    'body large (16px) — comfortable editorial line height for profiles and messaging.',
                    style: MatchTextStyle.bodyLarge,
                  ),
                  const SizedBox(height: 6),
                  const MatchText(
                    'body medium (14px) — secondary metadata and contextual captions.',
                    style: MatchTextStyle.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Section: Action Buttons
            _buildSectionHeader('03 / buttons & motion'),
            const SizedBox(height: 16),
            MatchButton(
              text: 'primary action',
              variant: MatchButtonVariant.primary,
              isLoading: _isButtonLoading,
              onPressed: () async {
                setState(() => _isButtonLoading = true);
                await Future.delayed(const Duration(milliseconds: 900));
                if (mounted) setState(() => _isButtonLoading = false);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MatchButton(
                    text: 'accent',
                    variant: MatchButtonVariant.accent,
                    onPressed: () {
                      MatchToast.show(
                        context,
                        message: 'accent button tapped with haptic feedback',
                        type: ToastType.success,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MatchButton(
                    text: 'secondary',
                    variant: MatchButtonVariant.secondary,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            MatchButton(
              text: 'outline variant',
              variant: MatchButtonVariant.outline,
              onPressed: () {},
            ),
            const SizedBox(height: 36),

            // Section: Selection Chips
            _buildSectionHeader('04 / animated interest chips'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sampleInterests.map((interest) {
                final isSelected = _selectedChips.contains(interest);
                return MatchChip(
                  label: interest,
                  isSelected: isSelected,
                  onSelected: () {
                    setState(() {
                      if (isSelected) {
                        _selectedChips.remove(interest);
                      } else {
                        _selectedChips.add(interest);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 36),

            // Section: Avatars & Badges
            _buildSectionHeader('05 / avatars & verification'),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MatchAvatar(name: 'Ananya Rao', size: MatchAvatarSize.small),
                MatchAvatar(name: 'Marcus Chen', size: MatchAvatarSize.medium, isOnline: true),
                MatchAvatar(name: 'Sofia Val', size: MatchAvatarSize.large, isVerified: true),
                MatchAvatar(name: 'Leo V', size: MatchAvatarSize.hero, isVerified: true),
              ],
            ),
            const SizedBox(height: 36),

            // Section: Form Input
            _buildSectionHeader('06 / editorial input'),
            const SizedBox(height: 16),
            MatchTextField(
              controller: _inputController,
              label: 'what are you looking for?',
              hintText: 'type a thought...',
              maxLength: 120,
            ),
            const SizedBox(height: 36),

            // Section: Loading Indicators
            _buildSectionHeader('07 / loading indicators'),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MatchLoadingIndicator(type: MatchLoadingType.dots),
                MatchLoadingIndicator(type: MatchLoadingType.thinking, message: 'ai thinking...'),
                MatchLoadingIndicator(type: MatchLoadingType.pulse),
              ],
            ),
            const SizedBox(height: 36),

            // Section: Overlays & Modals
            _buildSectionHeader('08 / overlays & bottom sheets'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MatchButton(
                    text: 'open sheet',
                    variant: MatchButtonVariant.secondary,
                    onPressed: () {
                      MatchBottomSheet.show(
                        context: context,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const MatchText(
                                'why you match',
                                style: MatchTextStyle.headingMedium,
                              ),
                              const SizedBox(height: 16),
                              const MatchText(
                                '• shared interest in vinyl records\n• both looking for something serious\n• both enjoy quiet coffee shops\n• active in the same neighborhood',
                                style: MatchTextStyle.bodyLarge,
                              ),
                              const SizedBox(height: 24),
                              MatchButton(
                                text: 'got it',
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MatchButton(
                    text: 'show toast',
                    variant: MatchButtonVariant.outline,
                    onPressed: () {
                      MatchToast.show(
                        context,
                        message: 'welcome to match stick. foundation ready.',
                        type: ToastType.info,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final isDark = widget.isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MatchText(
          title,
          style: MatchTextStyle.caption,
          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 4),
        Container(
          height: 1,
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ],
    );
  }

  Widget _buildColorBox(String label, Color color, {bool border = false}) {
    final isDark = widget.isDark;
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: border
                  ? Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.caption(
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
