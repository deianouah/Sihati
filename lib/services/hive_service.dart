import 'package:hive_flutter/hive_flutter.dart';
import '../models/meal.dart';

class HiveService {
  static const String mealBoxName = 'meals_box';
  static const String mealLogBoxName = 'meal_logs_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    Hive.registerAdapter(MealAdapter());
    Hive.registerAdapter(MealLogAdapter());

    // Open Boxes
    await Hive.openBox<Meal>(mealBoxName);
    await Hive.openBox<MealLog>(mealLogBoxName);
  }

  // --- Meal Operations ---
  static Box<Meal> get mealBox => Hive.box<Meal>(mealBoxName);

  static List<Meal> getAllMeals() {
    return mealBox.values.toList()
      ..sort((a, b) {
        int cmp = a.hour.compareTo(b.hour);
        if (cmp != 0) return cmp;
        return a.minute.compareTo(b.minute);
      });
  }

  static Future<void> addMeal(Meal meal) async {
    await mealBox.put(meal.id, meal);
  }

  static Future<void> deleteMeal(String id) async {
    await mealBox.delete(id);
  }

  // --- MealLog Operations ---
  static Box<MealLog> get mealLogBox => Hive.box<MealLog>(mealLogBoxName);

  static List<MealLog> getLogsForDate(DateTime date) {
    return mealLogBox.values.where((log) {
      return log.date.year == date.year &&
             log.date.month == date.month &&
             log.date.day == date.day;
    }).toList();
  }

  static Future<void> addOrUpdateMealLog(MealLog log) async {
    await mealLogBox.put(log.id, log);
  }
}
