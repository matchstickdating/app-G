import '../entities/date_plan_entity.dart';

abstract class DatePlannerRepository {
  Future<DatePlanEntity> generatePlan({
    required String city,
    required String budgetTier,
    required String vibe,
    required List<String> sharedInterests,
  });

  Future<void> savePlan(DatePlanEntity plan);
  Future<List<DatePlanEntity>> getSavedPlans(String userId);
}
