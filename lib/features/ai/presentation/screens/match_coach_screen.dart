import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/match_chip.dart';
import '../../../../core/widgets/match_loading_indicator.dart';
import '../../../../core/widgets/match_text.dart';
import '../controllers/ai_controller.dart';

class MatchCoachScreen extends ConsumerStatefulWidget {
  final String partnerName;

  const MatchCoachScreen({
    super.key,
    this.partnerName = 'your match',
  });

  @override
  ConsumerState<MatchCoachScreen> createState() => _MatchCoachScreenState();
}

class _MatchCoachScreenState extends ConsumerState<MatchCoachScreen> {
  final _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickPrompts = [
    'what should i ask next?',
    'help me suggest meeting for coffee.',
    'how to keep things natural?',
    'give me a thoughtful first date idea.',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend(String question) {
    if (question.trim().isEmpty) return;
    ref.read(aiControllerProvider.notifier).askCoach(question.trim(), widget.partnerName);
    _inputController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 16, color: AppColors.accent),
            const SizedBox(width: 8),
            const MatchText(
              'match coach',
              style: MatchTextStyle.navigation,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Quick Suggestion Chips
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: _quickPrompts.map((prompt) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: MatchChip(
                        label: prompt,
                        isSelected: false,
                        onSelected: () => _handleSend(prompt),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const Divider(height: 1),

            // Messages Stream
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: aiState.coachConversation.length,
                itemBuilder: (context, index) {
                  final msg = aiState.coachConversation[index];
                  final isUser = msg['role'] == 'user';

                  final bg = isUser
                      ? (isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle)
                      : (isDark ? const Color(0xFF1E1717) : const Color(0xFFFFF7F7));

                  final border = isUser
                      ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                      : AppColors.accent.withValues(alpha: 0.25);

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.82,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isUser) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_awesome, size: 12, color: AppColors.accent),
                                const SizedBox(width: 4),
                                Text(
                                  'coach advice',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                          ],
                          Text(
                            msg['text'] ?? '',
                            style: AppTypography.bodyMedium(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            if (aiState.isGenerating)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: MatchLoadingIndicator(
                  type: MatchLoadingType.thinking,
                  message: 'coach thinking...',
                ),
              ),

            // Bottom Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: TextField(
                        controller: _inputController,
                        style: AppTypography.bodyMedium(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'ask advice regarding ${widget.partnerName}...',
                          hintStyle: AppTypography.bodyMedium(
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: _handleSend,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _handleSend(_inputController.text),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_upward, size: 20, color: Colors.white),
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
}
