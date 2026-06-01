import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/medicine.dart';
import '../theme/app_theme.dart';

class MedicineListScreen extends StatelessWidget {
  const MedicineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'قائمة الأدوية',
          style: GoogleFonts.elMessiri(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<Box<Medicine>>(
        valueListenable: Hive.box<Medicine>('medicines_box').listenable(),
        builder: (context, box, _) {
          final medicines = box.values.toList();
          if (medicines.isEmpty) {
            return const Center(
              child: Text('لا توجد أدوية مضافّة.', style: TextStyle(fontSize: 16)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: medicines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final med = medicines[index];
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.name,
                      style: GoogleFonts.tajawal(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الجرعة: ${med.dosage}',
                      style: GoogleFonts.tajawal(fontSize: 14, color: AppTheme.textSecondary),
                    ),
                    if (med.frequency != null)
                      Text(
                        'التكرار: ${med.frequency}',
                        style: GoogleFonts.tajawal(fontSize: 14, color: AppTheme.textSecondary),
                      ),
                    if (med.reminderTime != null)
                      Text(
                        'وقت التذكير: ${med.reminderTime!.hour.toString().padLeft(2, '0')}:${med.reminderTime!.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.tajawal(fontSize: 14, color: AppTheme.textSecondary),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
