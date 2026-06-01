import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../services/medicine_service.dart';
import 'package:uuid/uuid.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({Key? key}) : super(key: key);

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _frequencyCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _reminderEnabled = false;
  TimeOfDay? _reminderTime;

  final MedicineService _service = MedicineService();
  final _uuid = const Uuid();

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    DateTime? reminderDt;
    if (_reminderEnabled && _reminderTime != null) {
      final now = DateTime.now();
      reminderDt = DateTime(now.year, now.month, now.day, _reminderTime!.hour, _reminderTime!.minute);
      if (reminderDt.isBefore(now)) reminderDt = reminderDt.add(const Duration(days: 1));
    }
    final med = Medicine(
      id: _uuid.v4(),
      name: _nameCtrl.text.trim(),
      dosage: _dosageCtrl.text.trim(),
      frequency: _frequencyCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      reminderTime: reminderDt,
    );
    await _service.add(med);
    // Optionally schedule notification here if reminder enabled
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة دواء')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'اسم الدواء'),
                validator: (v) => v == null || v.isEmpty ? 'الاسم مطلوب' : null,
              ),
              TextFormField(
                controller: _dosageCtrl,
                decoration: const InputDecoration(labelText: 'الجرعة (مثال: 500mg)'),
                validator: (v) => v == null || v.isEmpty ? 'الجرعة مطلوبة' : null,
              ),
              TextFormField(
                controller: _frequencyCtrl,
                decoration: const InputDecoration(labelText: 'التكرار (مثال: مرتين يوميًا)'),
                validator: (v) => v == null || v.isEmpty ? 'التكرار مطلوب' : null,
              ),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)')),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('تذكير'),
                value: _reminderEnabled,
                onChanged: (val) => setState(() => _reminderEnabled = val),
              ),
              if (_reminderEnabled)
                ListTile(
                  title: Text(_reminderTime == null
                      ? 'اختر وقت التذكير'
                      : 'وقت التذكير: ${_reminderTime!.format(context)}'),
                  trailing: const Icon(Icons.access_time),
                  onTap: _pickTime,
                ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _save, child: const Text('حفظ')),
            ],
          ),
        ),
      ),
    );
  }
}
