import 'package:flutter/material.dart';
import '../services/ocr_service.dart';
import '../services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/meal.dart';
import '../providers/meal_provider.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  void _saveMeal() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال اسم الوجبة')),
      );
      return;
    }

    final meal = Meal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
      notes: _notesController.text.trim(),
    );

    context.read<MealProvider>().addMeal(meal);
    Navigator.pop(context);
  }

  // -----------------------------------------------------------------
  // Image picker & OCR helper
  // -----------------------------------------------------------------
  Future<void> _pickImageAndExtract() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final text = await OcrService.recognizeText(image.path);
    setState(() {
      _notesController.text = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة وجبة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الوجبة (مثال: إفطار)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('وقت الوجبة'),
              subtitle: Text('${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.access_time),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (time != null) {
                  setState(() { _selectedTime = time; });
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveMeal,
              child: const Text('حفظ'),
            ),
            const SizedBox(height: 16),
            // OCR and TTS buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImageAndExtract,
                  icon: const Icon(Icons.photo),
                  label: const Text('استيراد صورة'),
                ),
                ElevatedButton.icon(
                  onPressed: () => NotificationService.speak(_notesController.text),
                  icon: const Icon(Icons.volume_up),
                  label: const Text('قراءة بصوت'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
