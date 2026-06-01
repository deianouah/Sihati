import 'package:hive_flutter/hive_flutter.dart';
import '../models/meal.dart';
import '../models/medicine.dart';
import '../models/medicine_adapter.dart';

class HiveService {
  static const String mealBoxName = 'meals_box';
  static const String mealLogBoxName = 'meal_logs_box';
  static const String medicineBoxName = 'medicines_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    if (!Hive.isAdapterRegistered(MealAdapter().typeId)) {
      Hive.registerAdapter(MealAdapter());
    }
    if (!Hive.isAdapterRegistered(MealLogAdapter().typeId)) {
      Hive.registerAdapter(MealLogAdapter());
    }
    if (!Hive.isAdapterRegistered(MedicineAdapter().typeId)) {
      Hive.registerAdapter(MedicineAdapter());
    }

    // Open Boxes
    await Hive.openBox<Meal>(mealBoxName);
    await Hive.openBox<MealLog>(mealLogBoxName);
    await Hive.openBox<Medicine>(medicineBoxName);
  }

  // --- Meal Operations ---
  static Box<Meal> get mealBox => Hive.box<Meal>(mealBoxName);

  // Medicine box getter
  static Box<Medicine> get medicineBox => Hive.box<Medicine>(medicineBoxName);

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
