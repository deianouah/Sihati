import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/meal_provider.dart';
import '../theme/app_theme.dart';

class MealConfirmScreen extends StatelessWidget {
  final String mealId;
  final String mealName;

  const MealConfirmScreen({
    super.key,
    required this.mealId,
    required this.mealName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🍽️', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 24),
              Text(
                'هل تناولت وجبتك؟',
                style: GoogleFonts.elMessiri(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                mealName,
                style: GoogleFonts.tajawal(
                  fontSize: 22,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Yes button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle, size: 28),
                  label: const Text('نعم، تناولتها ✅', style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    await context.read<MealProvider>().markMeal(mealId, true);
                    if (context.mounted) {
                      _showFeedback(context, true);
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              // No button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cancel_outlined, size: 28),
                  label: const Text('لا، لم أتناولها بعد ❌', style: TextStyle(fontSize: 20)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                    side: BorderSide(color: AppTheme.errorColor, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    await context.read<MealProvider>().markMeal(mealId, false);
                    if (context.mounted) {
                      _showFeedback(context, false);
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'تذكيرني لاحقاً',
                  style: GoogleFonts.tajawal(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeedback(BuildContext context, bool ate) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(ate ? '🎉' : '😔', style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              ate ? 'ممتاز! استمر على هذا المنوال.' : 'لا بأس، حاول الالتزام بالوجبة القادمة.',
              style: GoogleFonts.tajawal(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('حسناً'),
            ),
          )
        ],
      ),
    );
  }
}
