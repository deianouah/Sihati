// import 'package:hive/hive.dart'; // Removed unused import
import '../models/medicine.dart';
import 'hive_service.dart';

class MedicineService {
  // Retrieve all medicines
  List<Medicine> getAll() => HiveService.medicineBox.values.toList();

  // Add a new medicine
  Future<void> add(Medicine med) async {
    await HiveService.medicineBox.put(med.id, med);
  }

  // Update an existing medicine (by id)
  Future<void> update(Medicine med) async {
    await HiveService.medicineBox.put(med.id, med);
  }

  // Delete a medicine
  Future<void> delete(String id) async {
    await HiveService.medicineBox.delete(id);
  }
}
