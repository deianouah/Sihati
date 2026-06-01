import 'dart:convert';

class Medicine {
  final String id;
  final String name;
  final String dosage; // e.g., 500mg
  final String frequency; // e.g., twice a day
  final String notes;
  final DateTime? reminderTime;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.notes = '',
    this.reminderTime,
  });

  factory Medicine.fromMap(Map<String, dynamic> map) => Medicine(
        id: map['id'] as String,
        name: map['name'] as String,
        dosage: map['dosage'] as String,
        frequency: map['frequency'] as String,
        notes: map['notes'] as String? ?? '',
        reminderTime: map['reminderTime'] != null
            ? DateTime.parse(map['reminderTime'] as String)
            : null,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'notes': notes,
        'reminderTime': reminderTime?.toIso8601String(),
      };

  String toJson() => json.encode(toMap());

  factory Medicine.fromJson(String source) => Medicine.fromMap(json.decode(source));
}
