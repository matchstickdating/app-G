import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/match_button.dart';
import '../../../../core/widgets/match_card.dart';
import '../../../../core/widgets/match_chip.dart';
import '../../../../core/widgets/match_text.dart';
import '../../../../core/widgets/match_text_field.dart';
import '../../../../core/widgets/match_toast.dart';
import 'package:matchstick/features/auth/presentation/controllers/auth_controller.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _bioController = TextEditingController();
  final _promptAnswerController = TextEditingController();

  final List<String> _availableInterests = [
    'specialty coffee',
    'vinyl records',
    'film & cinema',
    'architecture',
    'contemporary art',
    'literature',
    'museums & galleries',
    'street photography',
    'live jazz',
    'natural wine',
    'night walks',
    'minimalism',
    'hiking trails',
    'urban cycling',
    'bouldering',
    'tea ceremonies',
    'botany & houseplants',
  ];

  final List<String> _promptQuestions = [
    'my perfect sunday is...',
    'we\'ll get along if...',
    'a random thing about me...',
    'my green flag is...',
    'the key to my heart is...',
  ];

  String _selectedPromptQuestion = 'my perfect sunday is...';

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingControllerProvider);
    _nameController.text = state.displayName;
    _cityController.text = state.locationCity;
    _countryController.text = state.locationCountry;
    _bioController.text = state.bio;
    if (state.prompts.isNotEmpty) {
      _selectedPromptQuestion = state.prompts.first['question'] ?? _promptQuestions.first;
      _promptAnswerController.text = state.prompts.first['answer'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _bioController.dispose();
    _promptAnswerController.dispose();
    super.dispose();
  }

  void _syncInputsToState() {
    final notifier = ref.read(onboardingControllerProvider.notifier);
    notifier.setDisplayName(_nameController.text.trim());
    notifier.setLocation(_cityController.text.trim(), _countryController.text.trim());
    notifier.setBio(_bioController.text.trim());
    notifier.updatePrompt(0, _selectedPromptQuestion, _promptAnswerController.text.trim());
  }

  Future<void> _handleNext() async {
    _syncInputsToState();
    final state = ref.read(onboardingControllerProvider);
    final notifier = ref.read(onboardingControllerProvider.notifier);

    if (state.currentStep < 6) {
      notifier.nextStep();
    } else {
      // Last step -> Finish onboarding
      final success = await notifier.finishOnboarding();
      if (!success && mounted) {
        MatchToast.show(context, message: 'could not save profile. try again.', type: ToastType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalSteps = 7;
    final progress = (state.currentStep + 1) / totalSteps;

    return Scaffold(
      appBar: AppBar(
        leading: state.currentStep > 0
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                onPressed: () {
                  ref.read(onboardingControllerProvider.notifier).previousStep();
                },
              )
            : null,
        title: Text(
          'step ${state.currentStep + 1} of $totalSteps',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            letterSpacing: -0.01 * 12,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
            child: Text(
              'sign out',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            minHeight: 2,
          ),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: MotionTokens.durationPage,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _buildCurrentStep(state.currentStep, state, isDark),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: MatchButton(
            text: state.currentStep == 6 ? 'complete profile' : 'continue',
            variant: MatchButtonVariant.primary,
            isLoading: state.isLoading,
            onPressed: state.canProceed ? _handleNext : null,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(int step, OnboardingState state, bool isDark) {
    switch (step) {
      case 0:
        return _buildStep0Name(state, isDark);
      case 1:
        return _buildStep1RelationshipGoal(state, isDark);
      case 2:
        return _buildStep2GenderPreference(state, isDark);
      case 3:
        return _buildStep3Location(state, isDark);
      case 4:
        return _buildStep4Interests(state, isDark);
      case 5:
        return _buildStep5Photos(state, isDark);
      case 6:
        return _buildStep6Prompts(state, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  // STEP 0: Name, Birthdate, Gender
  Widget _buildStep0Name(OnboardingState state, bool isDark) {
    final notifier = ref.read(onboardingControllerProvider.notifier);
    final age = state.birthdate != null
        ? DateTime.now().year - state.birthdate!.year
        : null;

    return SingleChildScrollView(
      key: const ValueKey('step_0'),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MatchText(
            'what should\nwe call you?',
            style: MatchTextStyle.hero,
          ),
          const SizedBox(height: 12),
          const MatchText(
            'this will be displayed on your profile. you can always edit this later.',
            style: MatchTextStyle.bodyMedium,
          ),
          const SizedBox(height: 36),
          MatchTextField(
            controller: _nameController,
            label: 'first name',
            hintText: 'e.g. Ananya',
            onChanged: (val) => notifier.setDisplayName(val),
          ),
          const SizedBox(height: 24),

          // Birthdate picker
          Text(
            'birthdate (age: ${age ?? "--"})',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          MatchCard(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: state.birthdate ?? DateTime(2000, 1, 1),
                firstDate: DateTime(1940),
                lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
              );
              if (picked != null) {
                notifier.setBirthdate(picked);
              }
            },
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state.birthdate != null
                      ? DateFormat('MMMM d, yyyy').format(state.birthdate!)
                      : 'select your birthdate',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Gender
          Text(
            'i identify as',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: ['woman', 'man', 'non-binary'].map((gender) {
              final isSelected = state.gender == gender;
              return MatchChip(
                label: gender,
                isSelected: isSelected,
                onSelected: () => notifier.setGender(gender),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // STEP 1: Relationship Goal
  Widget _buildStep1RelationshipGoal(OnboardingState state, bool isDark) {
    final notifier = ref.read(onboardingControllerProvider.notifier);

    final goals = [
      {'key': 'serious', 'title': 'something serious', 'desc': 'intentional, mindful dating'},
      {'key': 'long_term', 'title': 'long-term relationship', 'desc': 'open to building a future'},
      {'key': 'casual', 'title': 'casual dating', 'desc': 'fun dates and meeting new people'},
      {'key': 'new_connections', 'title': 'new connections', 'desc': 'expanding my creative circle'},
      {'key': 'figuring_it_out', 'title': 'still figuring it out', 'desc': 'taking things as they come'},
    ];

    return SingleChildScrollView(
      key: const ValueKey('step_1'),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MatchText(
            'what are you\nlooking for?',
            style: MatchTextStyle.hero,
          ),
          const SizedBox(height: 12),
          const MatchText(
            'be honest with your intentions. this helps match stick connect you with aligned people.',
            style: MatchTextStyle.bodyMedium,
          ),
          const SizedBox(height: 32),
          ...goals.map((item) {
            final isSelected = state.relationshipGoal == item['key'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MatchCard(
                onTap: () => notifier.setRelationshipGoal(item['key']!),
                borderColor: isSelected ? AppColors.accent : null,
                backgroundColor: isSelected
                    ? (isDark ? const Color(0xFF241515) : const Color(0xFFFFF5F5))
                    : null,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MatchText(
                            item['title']!,
                            style: MatchTextStyle.bodyLarge,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                          const SizedBox(height: 4),
                          MatchText(
                            item['desc']!,
                            style: MatchTextStyle.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, size: 20, color: AppColors.accent),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // STEP 2: Gender Preference
  Widget _buildStep2GenderPreference(OnboardingState state, bool isDark) {
    final notifier = ref.read(onboardingControllerProvider.notifier);

    return SingleChildScrollView(
      key: const ValueKey('step_2'),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MatchText(
            'who are you\ninterested in?',
            style: MatchTextStyle.hero,
          ),
          const SizedBox(height: 12),
          const MatchText(
            'you can select multiple options to broaden your discovery.',
            style: MatchTextStyle.bodyMedium,
          ),
          const SizedBox(height: 36),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ['woman', 'man', 'non-binary'].map((pref) {
              final isSelected = state.genderPreference.contains(pref);
              return MatchChip(
                label: pref,
                isSelected: isSelected,
                onSelected: () => notifier.toggleGenderPreference(pref),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // STEP 3: Location
  Widget _buildStep3Location(OnboardingState state, bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey('step_3'),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MatchText(
            'where are\nyou based?',
            style: MatchTextStyle.hero,
          ),
          const SizedBox(height: 12),
          const MatchText(
            'match stick prioritizes intentional discovery in your chosen city.',
            style: MatchTextStyle.bodyMedium,
          ),
          const SizedBox(height: 36),
          MatchTextField(
            controller: _cityController,
            label: 'city',
            hintText: 'e.g. Chennai',
            onChanged: (val) {
              ref.read(onboardingControllerProvider.notifier).setLocation(
                    val,
                    _countryController.text,
                  );
            },
          ),
          const SizedBox(height: 20),
          MatchTextField(
            controller: _countryController,
            label: 'country',
            hintText: 'e.g. India',
            onChanged: (val) {
              ref.read(onboardingControllerProvider.notifier).setLocation(
                    _cityController.text,
                    val,
                  );
            },
          ),
        ],
      ),
    );
  }

  // STEP 4: Interests
  Widget _buildStep4Interests(OnboardingState state, bool isDark) {
    final notifier = ref.read(onboardingControllerProvider.notifier);

    return SingleChildScrollView(
      key: const ValueKey('step_4'),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MatchText(
            'what makes\nyou, you?',
            style: MatchTextStyle.hero,
          ),
          const SizedBox(height: 12),
          MatchText(
            'select at least 3 interests (${state.interests.length} selected).',
            style: MatchTextStyle.bodyMedium,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: _availableInterests.map((interest) {
              final isSelected = state.interests.contains(interest);
              return MatchChip(
                label: interest,
                isSelected: isSelected,
                onSelected: () => notifier.toggleInterest(interest),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // STEP 5: Visual Story (Photos)
  Widget _buildStep5Photos(OnboardingState state, bool isDark) {
    final notifier = ref.read(onboardingControllerProvider.notifier);

    return SingleChildScrollView(
      key: const ValueKey('step_5'),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MatchText(
            'your visual\nstory.',
            style: MatchTextStyle.hero,
          ),
          const SizedBox(height: 12),
          const MatchText(
            'profiles with at least 2 authentic photos get 4x more meaningful replies.',
            style: MatchTextStyle.bodyMedium,
          ),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: (state.photos.length + 1).clamp(0, 6),
            itemBuilder: (context, index) {
              if (index < state.photos.length) {
                final photoUrl = state.photos[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                          child: const Icon(Icons.image_outlined),
                        ),
                      ),
                    ),
                    if (index == 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'main',
                            style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => notifier.removePhoto(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Add photo slot
                return MatchCard(
                  onTap: () {
                    // Pre-curated demo photos
                    final samplePhotos = [
                      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800',
                      'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=800',
                      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800',
                    ];
                    notifier.addPhoto(samplePhotos[state.photos.length % samplePhotos.length]);
                  },
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 28,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'add photo',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // STEP 6: Prompts & Bio
  Widget _buildStep6Prompts(OnboardingState state, bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey('step_6'),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MatchText(
            'prompts that\nspeak for you.',
            style: MatchTextStyle.hero,
          ),
          const SizedBox(height: 12),
          const MatchText(
            'prompts are natural conversation starters for your future matches.',
            style: MatchTextStyle.bodyMedium,
          ),
          const SizedBox(height: 32),

          // Select Prompt Question
          Text(
            'choose a prompt',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
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
                value: _selectedPromptQuestion,
                isExpanded: true,
                dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                items: _promptQuestions.map((q) {
                  return DropdownMenuItem(
                    value: q,
                    child: Text(
                      q,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedPromptQuestion = val);
                    ref.read(onboardingControllerProvider.notifier).updatePrompt(
                          0,
                          val,
                          _promptAnswerController.text,
                        );
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Prompt Answer
          MatchTextField(
            controller: _promptAnswerController,
            label: 'your answer',
            hintText: 'type an authentic answer...',
            maxLines: 3,
            maxLength: 140,
            onChanged: (val) {
              ref.read(onboardingControllerProvider.notifier).updatePrompt(
                    0,
                    _selectedPromptQuestion,
                    val,
                  );
            },
          ),
          const SizedBox(height: 24),

          // Bio
          MatchTextField(
            controller: _bioController,
            label: 'short bio',
            hintText: 'hunting for the quietest corner and the darkest roast...',
            maxLines: 2,
            maxLength: 200,
            onChanged: (val) {
              ref.read(onboardingControllerProvider.notifier).setBio(val);
            },
          ),
        ],
      ),
    );
  }
}
