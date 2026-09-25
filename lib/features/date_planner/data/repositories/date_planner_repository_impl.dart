import '../../../ai/domain/repositories/ai_repository.dart';
import '../../domain/entities/date_plan_entity.dart';
import '../../domain/repositories/date_planner_repository.dart';

class DatePlannerRepositoryImpl implements DatePlannerRepository {
  final AiRepository _aiRepository;
  final List<DatePlanEntity> _savedPlans = [];

  DatePlannerRepositoryImpl(this._aiRepository);

  @override
  Future<DatePlanEntity> generatePlan({
    required String city,
    required String budgetTier,
    required String vibe,
    required List<String> sharedInterests,
  }) async {
    return _aiRepository.generateDatePlan(
      city: city,
      budgetTier: budgetTier,
      vibe: vibe,
      sharedInterests: sharedInterests,
    );
  }

  @override
  Future<void> savePlan(DatePlanEntity plan) async {
    _savedPlans.removeWhere((p) => p.id == plan.id);
    _savedPlans.insert(0, plan);
  }

  @override
  Future<List<DatePlanEntity>> getSavedPlans(String userId) async {
    return List.from(_savedPlans);
  }
}
