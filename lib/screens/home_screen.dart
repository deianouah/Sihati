import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/meal.dart';
import '../models/medicine.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../providers/meal_provider.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import 'add_meal_screen.dart';
import 'meal_confirm_screen.dart';
import 'ocr_screen.dart';
import 'medicine_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Update every second for live countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() { _now = DateTime.now(); });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Meal? _getNextMeal(List<Meal> meals) {
    if (meals.isEmpty) return null;
    final nowMinutes = _now.hour * 60 + _now.minute;
    for (final meal in meals) {
      final mealMinutes = meal.hour * 60 + meal.minute;
      if (mealMinutes > nowMinutes) return meal;
    }
    return meals.first; // wrap around to next day
  }

  Duration _getTimeUntilMeal(Meal meal) {
    var mealTime = DateTime(_now.year, _now.month, _now.day, meal.hour, meal.minute);
    if (mealTime.isBefore(_now)) {
      mealTime = mealTime.add(const Duration(days: 1));
    }
    return mealTime.difference(_now);
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '$hس $mد';
    if (m > 0) return '$m دقيقة ${s.toString().padLeft(2, '0')}ث';
    return '$s ثانية';
  }

  String _formatTime(Meal meal) {
    return '${meal.hour.toString().padLeft(2, '0')}:${meal.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'تطبيق خاص بـ مصطفى بوعراب',
          style: GoogleFonts.elMessiri(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: AppTheme.primaryColor),
            tooltip: 'اختبار الصوت',
            onPressed: () => NotificationService.speak('السلام عليكم يا مصطفى'),
          ),
        ],
      ),
      body: Consumer<MealProvider>(
        builder: (context, provider, _) {
          final nextMeal = _getNextMeal(provider.meals);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Next Meal Card ---
                _NextMealCard(
                  nextMeal: nextMeal,
                  timeLeft: nextMeal != null ? _getTimeUntilMeal(nextMeal) : null,
                  formattedTime: nextMeal != null ? _formatTime(nextMeal) : null,
                  formatDuration: _formatDuration,
                  onConfirm: nextMeal != null
                      ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MealConfirmScreen(
                                mealId: nextMeal.id,
                                mealName: nextMeal.name,
                              ),
                            ),
                          )
                      : null,
                ),
                const SizedBox(height: 16),
                // --- Compliance Card ---
                _ComplianceCard(provider: provider),
                const SizedBox(height: 16),
                // Mixed Meal Card
                _MixedMealCard(onAdd: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMealScreen()))),
                const SizedBox(height: 16),
                // Medicine Summary Card
                _MedicineSummaryCard(),
                const SizedBox(height: 16),
                // --- All Meals List ---
                if (provider.meals.isNotEmpty) ...[
                  Text(
                    'جدول الوجبات اليومي',
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...provider.meals.map((meal) => _MealTile(
                        meal: meal,
                        isNext: meal.id == nextMeal?.id,
                        todayLogs: provider.todayLogs,
                        onDelete: () => provider.deleteMeal(meal.id),
                        onConfirm: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MealConfirmScreen(
                              mealId: meal.id,
                              mealName: meal.name,
                            ),
                          ),
                        ),
                      )),
                ],
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/medicines'),
                  icon: const Icon(Icons.medication),
                  label: Text('قائمة الأدوية', style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () => _showAddOptions(context),
        label: Text('إضافة وجبة', style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('كيف تريد إضافة الوجبة؟',
                style: GoogleFonts.elMessiri(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: CircleAvatar(backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: const Icon(Icons.edit, color: AppTheme.primaryColor)),
              title: Text('إضافة يدوية', style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.w600)),
              subtitle: Text('أدخل اسم الوجبة والوقت', style: GoogleFonts.tajawal()),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMealScreen()));
              },
            ),
            ListTile(
              leading: CircleAvatar(
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  child: const Icon(Icons.document_scanner, color: Colors.blue)),
              title: Text('قراءة وصفة الطبيب (OCR)', style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.w600)),
              subtitle: Text('صوّر الورقة وسيستخرج البيانات تلقائياً\nيدعم: العربية، الفرنسية، الإنجليزية', style: GoogleFonts.tajawal()),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OcrScreen()));
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// --- Sub-widgets ---

class _NextMealCard extends StatelessWidget {
  final Meal? nextMeal;
  final Duration? timeLeft;
  final String? formattedTime;
  final String Function(Duration) formatDuration;
  final VoidCallback? onConfirm;

  const _NextMealCard({
    required this.nextMeal,
    required this.timeLeft,
    required this.formattedTime,
    required this.formatDuration,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    if (nextMeal == null) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.primaryColor.withValues(alpha: 0.7)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            const Text('🍽️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('لا توجد وجبات مضافة بعد',
                style: GoogleFonts.elMessiri(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('اضغط + لإضافة أول وجبة',
                style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 16)),
          ],
        ),
      );
    }

    final isSoon = timeLeft != null && timeLeft!.inMinutes < 30;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSoon
              ? [const Color(0xFFE65100), const Color(0xFFFF6D00)]
              : [AppTheme.primaryColor, const Color(0xFF2E7D32)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الوجبة القادمة',
              style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  nextMeal!.name,
                  style: GoogleFonts.elMessiri(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formattedTime ?? '',
                      style: GoogleFonts.tajawal(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.timer, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text(
                'باقي: ${formatDuration(timeLeft!)}',
                style: GoogleFonts.tajawal(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          if (nextMeal!.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('📝 ${nextMeal!.notes}',
                style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 14)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onConfirm,
              child: Text('تأكيد تناول الوجبة',
                  style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}

class _ComplianceCard extends StatelessWidget {
  final MealProvider provider;
  const _ComplianceCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final completed = provider.todayLogs.where((l) => l.isCompleted).length;
    final missed = provider.todayLogs.where((l) => !l.isCompleted).length;
    final total = provider.meals.length;
    final percent = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الالتزام اليومي',
              style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${(percent * 100).toInt()}%',
                        style: GoogleFonts.elMessiri(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: percent >= 0.7 ? AppTheme.primaryColor : Colors.orange,
                        )),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 10,
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor: AlwaysStoppedAnimation(
                          percent >= 0.7 ? AppTheme.primaryColor : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  _StatBadge(icon: '✅', count: completed, label: 'مُنجزة'),
                  const SizedBox(height: 8),
                  _StatBadge(icon: '❌', count: missed, label: 'فائتة'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String icon;
  final int count;
  final String label;
  const _StatBadge({required this.icon, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(icon, style: const TextStyle(fontSize: 20)),
      Text('$count', style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold)),
      Text(label, style: GoogleFonts.tajawal(fontSize: 12, color: AppTheme.textSecondary)),
    ]);
  }
}

class _MealTile extends StatelessWidget {
  final Meal meal;
  final bool isNext;
  final List todayLogs;
  final VoidCallback onDelete;
  final VoidCallback onConfirm;

  const _MealTile({
    required this.meal,
    required this.isNext,
    required this.todayLogs,
    required this.onDelete,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final log = todayLogs.firstWhere((l) => l.mealId == meal.id, orElse: () => null);
    final isCompleted = log?.isCompleted ?? false;
    final hasFeedback = log != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isNext ? AppTheme.primaryColor.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNext ? AppTheme.primaryColor : const Color(0xFFE5E7EB),
          width: isNext ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: hasFeedback
               ? (isCompleted ? AppTheme.successColor : AppTheme.errorColor)
               : AppTheme.primaryColor.withValues(alpha: 0.1),
          child: Text(
            hasFeedback ? (isCompleted ? '✅' : '❌') : '🍽️',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        title: Text(
          meal.name,
          style: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${meal.hour.toString().padLeft(2, '0')}:${meal.minute.toString().padLeft(2, '0')}',
              style: GoogleFonts.tajawal(fontSize: 16, color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
            ),
            if (meal.notes.isNotEmpty)
              Text(meal.notes, style: GoogleFonts.tajawal(fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!hasFeedback)
              IconButton(
                icon: const Icon(Icons.check_circle_outline, color: AppTheme.primaryColor, size: 28),
                tooltip: 'تأكيد',
                onPressed: onConfirm,
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 26),
              tooltip: 'حذف',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// ----- Additional Widgets -----

class _MixedMealCard extends StatelessWidget {
  final VoidCallback onAdd;
  const _MixedMealCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('وجبة مختلطة', style: GoogleFonts.elMessiri(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text('أضف وجبة تحتوي على مزيج من المكونات.', style: GoogleFonts.tajawal(color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text('إضافة وجبة مختلطة', style: GoogleFonts.tajawal()),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicineSummaryCard extends StatelessWidget {
  const _MedicineSummaryCard();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Medicine>>(
      valueListenable: Hive.box<Medicine>('medicines_box').listenable(),
      builder: (context, box, _) {
        final medicines = box.values.toList();
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ملخص الأدوية', style: GoogleFonts.elMessiri(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Text('عدد الأدوية المضافة: ${medicines.length}', style: GoogleFonts.tajawal(color: AppTheme.textSecondary)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MedicineListScreen())),
                  icon: const Icon(Icons.medication),
                  label: Text('عرض جميع الأدوية', style: GoogleFonts.tajawal()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

