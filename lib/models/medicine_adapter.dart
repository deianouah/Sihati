import 'package:hive/hive.dart';
import '../models/medicine.dart';

class MedicineAdapter extends TypeAdapter<Medicine> {
  @override
  final int typeId = 2; // Updated to avoid conflict with MealLogAdapter

  @override
  Medicine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final field = reader.readByte();
      fields[field] = reader.read();
    }
    return Medicine(
      id: fields[0] as String,
      name: fields[1] as String,
      dosage: fields[2] as String,
      frequency: fields[3] as String,
      notes: fields[4] as String,
      reminderTime: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Medicine obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.dosage)
      ..writeByte(3)
      ..write(obj.frequency)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.reminderTime);
  }
}
