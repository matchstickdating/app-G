import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/match_button.dart';
import '../../../../core/widgets/match_card.dart';
import '../../../../core/widgets/match_text.dart';
import '../../../../core/widgets/match_text_field.dart';
import '../../../../core/widgets/match_toast.dart';
import '../../../ai/presentation/widgets/profile_polish_modal.dart';
import '../controllers/profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _bioController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  late TextEditingController _promptAnswerController;

  String _selectedGoal = 'serious';
  String _promptQuestion = 'my perfect sunday is...';
  String? _promptId;

  final List<String> _promptQuestions = [
    'my perfect sunday is...',
    'we\'ll get along if...',
    'a random thing about me...',
    'my green flag is...',
    'the key to my heart is...',
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider).profile;
    _bioController = TextEditingController(text: profile?.bio ?? '');
    _cityController = TextEditingController(text: profile?.locationCity ?? '');
    _countryController = TextEditingController(text: profile?.locationCountry ?? '');
    _selectedGoal = profile?.relationshipGoal ?? 'serious';

    if (profile != null && profile.prompts.isNotEmpty) {
      _promptId = profile.prompts.first.id;
      _promptQuestion = profile.prompts.first.question;
      _promptAnswerController = TextEditingController(text: profile.prompts.first.answer);
    } else {
      _promptAnswerController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _promptAnswerController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final notifier = ref.read(profileControllerProvider.notifier);
    await notifier.updateBio(_bioController.text.trim());
    await notifier.updateLocation(_cityController.text.trim(), _countryController.text.trim());
    await notifier.updateRelationshipGoal(_selectedGoal);

    if (_promptAnswerController.text.trim().isNotEmpty) {
      await notifier.updatePrompt(
        _promptId ?? 'prompt-1',
        _promptQuestion,
        _promptAnswerController.text.trim(),
      );
    }

    if (mounted) {
      MatchToast.show(context, message: 'profile updated successfully.', type: ToastType.success);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final profile = profileState.profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const MatchText(
          'edit profile',
          style: MatchTextStyle.navigation,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: Text(
              'save',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photos Grid
              Text(
                'photos',
                style: AppTypography.caption(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              if (profile != null) ...[
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: (profile.photos.length + 1).clamp(0, 6),
                  itemBuilder: (context, index) {
                    if (index < profile.photos.length) {
                      final photo = profile.photos[index];
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(photo.url, fit: BoxFit.cover),
                          ),
                          if (index == 0)
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'main',
                                  style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                ref.read(profileControllerProvider.notifier).removePhoto(photo.id);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 12, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return MatchCard(
                        borderRadius: 12,
                        padding: EdgeInsets.zero,
                        onTap: () {
                          final sample = [
                            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
                            'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800',
                            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800',
                          ];
                          ref.read(profileControllerProvider.notifier).addPhoto(
                                sample[profile.photos.length % sample.length],
                              );
                        },
                        child: Center(
                          child: Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 24,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
              const SizedBox(height: 28),

              // Bio
              MatchTextField(
                controller: _bioController,
                label: 'about you',
                hintText: 'share what inspires you...',
                maxLines: 3,
                maxLength: 250,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: MatchButton(
                  text: '✦ polish bio with ai',
                  variant: MatchButtonVariant.outline,
                  size: MatchButtonSize.compact,
                  isFullWidth: false,
                  leadingIcon: const Icon(Icons.auto_awesome, size: 14, color: AppColors.accent),
                  onPressed: () {
                    ProfilePolishModal.show(
                      context: context,
                      originalText: _bioController.text,
                      title: 'about you',
                      onApply: (polished) {
                        setState(() => _bioController.text = polished);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Location
              Row(
                children: [
                  Expanded(
                    child: MatchTextField(
                      controller: _cityController,
                      label: 'city',
                      hintText: 'Chennai',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MatchTextField(
                      controller: _countryController,
                      label: 'country',
                      hintText: 'India',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Relationship Goal Dropdown
              Text(
                'relationship goal',
                style: AppTypography.caption(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGoal,
                    isExpanded: true,
                    dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    items: const [
                      DropdownMenuItem(value: 'serious', child: Text('something serious')),
                      DropdownMenuItem(value: 'long_term', child: Text('long-term relationship')),
                      DropdownMenuItem(value: 'casual', child: Text('casual dating')),
                      DropdownMenuItem(value: 'new_connections', child: Text('new connections')),
                      DropdownMenuItem(value: 'figuring_it_out', child: Text('still figuring it out')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedGoal = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Prompt Editor
              Text(
                'featured prompt',
                style: AppTypography.caption(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _promptQuestion,
                    isExpanded: true,
                    dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    items: _promptQuestions.map((q) {
                      return DropdownMenuItem(value: q, child: Text(q));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _promptQuestion = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              MatchTextField(
                controller: _promptAnswerController,
                label: 'prompt answer',
                hintText: 'type your answer...',
                maxLines: 2,
                maxLength: 140,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: MatchButton(
                  text: '✦ polish prompt with ai',
                  variant: MatchButtonVariant.outline,
                  size: MatchButtonSize.compact,
                  isFullWidth: false,
                  leadingIcon: const Icon(Icons.auto_awesome, size: 14, color: AppColors.accent),
                  onPressed: () {
                    ProfilePolishModal.show(
                      context: context,
                      originalText: _promptAnswerController.text,
                      title: _promptQuestion,
                      onApply: (polished) {
                        setState(() => _promptAnswerController.text = polished);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 36),

              // Save Button
              MatchButton(
                text: 'save changes',
                variant: MatchButtonVariant.primary,
                onPressed: _handleSave,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
