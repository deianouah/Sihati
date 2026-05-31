import 'package:hive/hive.dart';

part 'meal.g.dart';

@HiveType(typeId: 0)
class Meal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int hour;

  @HiveField(3)
  int minute;

  @HiveField(4)
  String notes;

  Meal({
    required this.id,
    required this.name,
    required this.hour,
    required this.minute,
    this.notes = "",
  });
}

@HiveType(typeId: 1)
class MealLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String mealId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  bool isCompleted;

  MealLog({
    required this.id,
    required this.mealId,
    required this.date,
    required this.isCompleted,
  });
}
