import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/date_planner_repository_impl.dart';
import '../../domain/entities/date_plan_entity.dart';
import '../../domain/repositories/date_planner_repository.dart';
import '../../../ai/presentation/controllers/ai_controller.dart';

class DatePlannerState {
  final DatePlanEntity? currentPlan;
  final String city;
  final String budgetTier;
  final String vibe;
  final bool isGenerating;

  const DatePlannerState({
    this.currentPlan,
    this.city = 'Chennai',
    this.budgetTier = '\$\$',
    this.vibe = 'cozy',
    this.isGenerating = false,
  });

  DatePlannerState copyWith({
    DatePlanEntity? currentPlan,
    String? city,
    String? budgetTier,
    String? vibe,
    bool? isGenerating,
  }) {
    return DatePlannerState(
      currentPlan: currentPlan ?? this.currentPlan,
      city: city ?? this.city,
      budgetTier: budgetTier ?? this.budgetTier,
      vibe: vibe ?? this.vibe,
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }
}

final datePlannerRepositoryProvider = Provider<DatePlannerRepository>((ref) {
  final aiRepo = ref.watch(aiRepositoryProvider);
  return DatePlannerRepositoryImpl(aiRepo);
});

class DatePlannerController extends Notifier<DatePlannerState> {
  DatePlannerRepository get _repository => ref.read(datePlannerRepositoryProvider);

  @override
  DatePlannerState build() => const DatePlannerState();

  void setCity(String city) => state = state.copyWith(city: city);
  void setBudget(String budget) => state = state.copyWith(budgetTier: budget);
  void setVibe(String vibe) => state = state.copyWith(vibe: vibe);

  Future<void> generatePlan({
    List<String> sharedInterests = const ['specialty coffee', 'architecture'],
  }) async {
    state = state.copyWith(isGenerating: true);
    try {
      final plan = await _repository.generatePlan(
        city: state.city,
        budgetTier: state.budgetTier,
        vibe: state.vibe,
        sharedInterests: sharedInterests,
      );
      state = state.copyWith(currentPlan: plan, isGenerating: false);
    } catch (_) {
      state = state.copyWith(isGenerating: false);
    }
  }

  Future<void> makeCheaper() async {
    state = state.copyWith(budgetTier: '\$');
    await generatePlan();
  }

  Future<void> makeAdventurous() async {
    state = state.copyWith(vibe: 'adventurous');
    await generatePlan();
  }

  void makeShorter() {
    if (state.currentPlan == null) return;
    final shortenedStops = state.currentPlan!.itinerary.take(2).toList();
    final updated = DatePlanEntity(
      id: state.currentPlan!.id,
      createdBy: state.currentPlan!.createdBy,
      matchId: state.currentPlan!.matchId,
      title: '${state.currentPlan!.title} (compact)',
      city: state.currentPlan!.city,
      budgetTier: state.currentPlan!.budgetTier,
      vibe: state.currentPlan!.vibe,
      itinerary: shortenedStops,
      createdAt: state.currentPlan!.createdAt,
    );
    state = state.copyWith(currentPlan: updated);
  }
}

final datePlannerControllerProvider =
    NotifierProvider<DatePlannerController, DatePlannerState>(DatePlannerController.new);
