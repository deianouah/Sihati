import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';

class MealProvider extends ChangeNotifier {
  List<Meal> _meals = [];
  List<MealLog> _todayLogs = [];

  List<Meal> get meals => _meals;
  List<MealLog> get todayLogs => _todayLogs;

  MealProvider() {
    _loadData();
  }

  void _loadData() {
    _meals = HiveService.getAllMeals();
    _todayLogs = HiveService.getLogsForDate(DateTime.now());
    notifyListeners();
  }

  Future<void> addMeal(Meal meal) async {
    await HiveService.addMeal(meal);
    await NotificationService.scheduleMealNotifications(meal);
    _loadData();
  }

  Future<void> deleteMeal(String id) async {
    await HiveService.deleteMeal(id);
    await NotificationService.cancelMealNotifications(id);
    _loadData();
  }

  Future<void> markMeal(String mealId, bool completed) async {
    final now = DateTime.now();
    final logId = '${mealId}_${now.year}_${now.month}_${now.day}';

    final log = MealLog(
      id: logId,
      mealId: mealId,
      date: now,
      isCompleted: completed,
    );

    await HiveService.addOrUpdateMealLog(log);
    _loadData();
  }

  /// Compliance for current day only (0.0 – 1.0)
  double get dailyCompliance {
    if (_meals.isEmpty) return 0.0;
    final done = _todayLogs.where((l) => l.isCompleted).length;
    return (done / _meals.length).clamp(0.0, 1.0);
  }

  /// Compliance across the last 7 days (0.0 – 1.0)
  double get weeklyCompliance {
    if (_meals.isEmpty) return 0.0;
    int total = 0;
    int completed = 0;
    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final logs = HiveService.getLogsForDate(date);
      total += _meals.length;
      completed += logs.where((l) => l.isCompleted).length;
    }
    if (total == 0) return 0.0;
    return (completed / total).clamp(0.0, 1.0);
  }

  /// Confirmed count today
  int get completedToday => _todayLogs.where((l) => l.isCompleted).length;

  /// Missed count today
  int get missedToday => _todayLogs.where((l) => !l.isCompleted).length;
}
