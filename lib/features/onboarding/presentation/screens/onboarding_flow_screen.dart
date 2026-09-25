import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/network/supabase_service.dart';
import '../../../../core/routing/main_navigation_shell.dart';
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
  bool _isUploadingPhoto = false;

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
      await notifier.finishOnboarding();
      if (mounted) {
        MatchToast.show(
          context,
          message: 'profile complete! welcome to match stick.',
          type: ToastType.success,
        );
        Navigator.of(context).pushAndRemoveUntil(
          MotionTokens.editorialPageRoute(
            page: const MainNavigationShell(),
          ),
          (route) => false,
        );
      }
    }
  }

  // --- Photo Upload & Selection Logic ---

  Future<void> _pickAndUploadImage({int? replaceIndex}) async {
    setState(() => _isUploadingPhoto = true);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (picked == null) {
        setState(() => _isUploadingPhoto = false);
        return;
      }

      final bytes = await picked.readAsBytes();
      final base64String = base64Encode(bytes);
      final mimeType = picked.mimeType ?? 'image/jpeg';
      String finalUrl = 'data:$mimeType;base64,$base64String';

      // Attempt Supabase storage upload if authenticated
      try {
        final currentAuthUser = SupabaseService.client?.auth.currentUser;
        if (currentAuthUser != null && SupabaseService.client != null) {
          final fileName = '${currentAuthUser.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
          await SupabaseService.client!.storage.from('avatars').uploadBinary(
            fileName,
            bytes,
          ).timeout(const Duration(seconds: 4));
          final publicUrl = SupabaseService.client!.storage.from('avatars').getPublicUrl(fileName);
          if (publicUrl.isNotEmpty) {
            finalUrl = publicUrl;
          }
        }
      } catch (_) {
        // Fallback to base64 data URL
      }

      final notifier = ref.read(onboardingControllerProvider.notifier);
      if (replaceIndex != null) {
        notifier.replacePhoto(replaceIndex, finalUrl);
      } else {
        notifier.addPhoto(finalUrl);
      }
      if (mounted) {
        MatchToast.show(context, message: 'photo added successfully', type: ToastType.success);
      }
    } catch (e) {
      if (mounted) {
        MatchToast.show(context, message: 'could not upload image. try again.', type: ToastType.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  Future<void> _takePhotoWithCamera({int? replaceIndex}) async {
    setState(() => _isUploadingPhoto = true);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (picked == null) {
        setState(() => _isUploadingPhoto = false);
        return;
      }

      final bytes = await picked.readAsBytes();
      final base64String = base64Encode(bytes);
      final mimeType = picked.mimeType ?? 'image/jpeg';
      String finalUrl = 'data:$mimeType;base64,$base64String';

      try {
        final currentAuthUser = SupabaseService.client?.auth.currentUser;
        if (currentAuthUser != null && SupabaseService.client != null) {
          final fileName = '${currentAuthUser.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
          await SupabaseService.client!.storage.from('avatars').uploadBinary(
            fileName,
            bytes,
          ).timeout(const Duration(seconds: 4));
          final publicUrl = SupabaseService.client!.storage.from('avatars').getPublicUrl(fileName);
          if (publicUrl.isNotEmpty) {
            finalUrl = publicUrl;
          }
        }
      } catch (_) {}

      final notifier = ref.read(onboardingControllerProvider.notifier);
      if (replaceIndex != null) {
        notifier.replacePhoto(replaceIndex, finalUrl);
      } else {
        notifier.addPhoto(finalUrl);
      }
      if (mounted) {
        MatchToast.show(context, message: 'photo captured successfully', type: ToastType.success);
      }
    } catch (e) {
      if (mounted) {
        MatchToast.show(context, message: 'could not open camera.', type: ToastType.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  void _showPhotoSourceSheet(BuildContext context, {int? replaceIndex}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  replaceIndex != null ? 'change photo' : 'add photo to profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'upload your own image or pick a curated portrait.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_outlined, color: AppColors.accent, size: 22),
                  ),
                  title: const Text('upload from gallery / device', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('choose any image from your computer or phone', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickAndUploadImage(replaceIndex: replaceIndex);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_outlined, color: AppColors.accent, size: 22),
                  ),
                  title: const Text('take a photo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('capture an instant shot with camera', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _takePhotoWithCamera(replaceIndex: replaceIndex);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.auto_awesome_outlined, color: isDark ? Colors.white70 : Colors.black87, size: 22),
                  ),
                  title: const Text('choose curated portrait', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('pick from editorial demo portraits', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showCuratedPortraitsDialog(context, replaceIndex: replaceIndex);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.link, color: isDark ? Colors.white70 : Colors.black87, size: 22),
                  ),
                  title: const Text('paste image url', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('link any web photo directly', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showUrlInputDialog(context, replaceIndex: replaceIndex);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUrlInputDialog(BuildContext context, {int? replaceIndex}) {
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (dlgContext) => AlertDialog(
        title: const Text('paste image url', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: TextField(
          controller: urlController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'https://images.unsplash.com/...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgContext),
            child: const Text('cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final url = urlController.text.trim();
              if (url.isNotEmpty) {
                final notifier = ref.read(onboardingControllerProvider.notifier);
                if (replaceIndex != null) {
                  notifier.replacePhoto(replaceIndex, url);
                } else {
                  notifier.addPhoto(url);
                }
              }
              Navigator.pop(dlgContext);
            },
            child: const Text('add photo'),
          ),
        ],
      ),
    );
  }

  void _showCuratedPortraitsDialog(BuildContext context, {int? replaceIndex}) {
    final curatedPortraits = [
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800',
      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800',
      'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=800',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800',
    ];

    showDialog(
      context: context,
      builder: (dlgContext) => AlertDialog(
        title: const Text('select curated portrait', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemCount: curatedPortraits.length,
            itemBuilder: (ctx, idx) {
              final url = curatedPortraits[idx];
              return InkWell(
                onTap: () {
                  final notifier = ref.read(onboardingControllerProvider.notifier);
                  if (replaceIndex != null) {
                    notifier.replacePhoto(replaceIndex, url);
                  } else {
                    notifier.addPhoto(url);
                  }
                  Navigator.pop(dlgContext);
                },
                borderRadius: BorderRadius.circular(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(url, fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgContext),
            child: const Text('cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoImage(String photoUrl, bool isDark) {
    if (photoUrl.startsWith('data:image')) {
      try {
        final commaIndex = photoUrl.indexOf(',');
        final base64String = commaIndex != -1 ? photoUrl.substring(commaIndex + 1) : photoUrl;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => _buildImagePlaceholder(isDark),
        );
      } catch (_) {
        return _buildImagePlaceholder(isDark);
      }
    } else {
      return Image.network(
        photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => _buildImagePlaceholder(isDark),
      );
    }
  }

  Widget _buildImagePlaceholder(bool isDark) {
    return Container(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
        ),
      ),
    );
  }

  // --- Editorial Visual Banner Component ---

  Widget _buildEditorialBanner({
    required String assetPath,
    required String tag,
    required String headline,
    required bool isDark,
    double height = 140,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              assetPath,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tag.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    headline,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
          const SizedBox(height: 20),

          // Editorial visual banner
          _buildEditorialBanner(
            assetPath: 'assets/images/onboarding_hero.jpg',
            tag: 'editorial dating',
            headline: 'designed for intentional connection',
            isDark: isDark,
          ),

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
          const SizedBox(height: 20),

          // Editorial visual banner
          _buildEditorialBanner(
            assetPath: 'assets/images/onboarding_connection.jpg',
            tag: 'intention',
            headline: 'real depth, not endless swiping',
            isDark: isDark,
          ),

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
          const SizedBox(height: 20),

          // Editorial visual banner
          _buildEditorialBanner(
            assetPath: 'assets/images/onboarding_lifestyle.jpg',
            tag: 'shared tastes',
            headline: 'bond over the things you love',
            isDark: isDark,
          ),

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

  // STEP 5: Visual Story (Photos + Custom Upload)
  Widget _buildStep5Photos(OnboardingState state, bool isDark) {
    final notifier = ref.read(onboardingControllerProvider.notifier);

    return SingleChildScrollView(
      key: const ValueKey('step_5'),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const MatchText(
                'your visual\nstory.',
                style: MatchTextStyle.hero,
              ),
              if (_isUploadingPhoto)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const MatchText(
            'upload your own photos from your device or pick curated portraits. at least 1 photo is required.',
            style: MatchTextStyle.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Quick upload button
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: MatchButton(
              text: 'upload photo from device',
              variant: MatchButtonVariant.secondary,
              leadingIcon: const Icon(Icons.upload_file, size: 18),
              onPressed: () => _pickAndUploadImage(),
            ),
          ),

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
                return GestureDetector(
                  onTap: () => _showPhotoSourceSheet(context, replaceIndex: index),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _buildPhotoImage(photoUrl, isDark),
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
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // Add photo slot
                return MatchCard(
                  onTap: () => _showPhotoSourceSheet(context),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 32,
                          color: AppColors.accent,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'add photo',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'device or web',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
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
          const SizedBox(height: 20),

          // Editorial visual banner
          _buildEditorialBanner(
            assetPath: 'assets/images/onboarding_prompts.jpg',
            tag: 'authenticity',
            headline: 'let your true voice lead the way',
            isDark: isDark,
          ),

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
