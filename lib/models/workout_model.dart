import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutModel {
  final String id;
  final String memberId;
  final String? trainerId;
  final DateTime date;
  final String notes;
  final List<Map<String, dynamic>> exercises;

  WorkoutModel({
    required this.id,
    required this.memberId,
    this.trainerId,
    required this.date,
    required this.notes,
    required this.exercises,
  });

  factory WorkoutModel.fromMap(Map<String, dynamic> map, String id) {
    return WorkoutModel(
      id: id,
      memberId: map['memberId'] ?? '',
      trainerId: map['trainerId'],
      date: (map['date'] as Timestamp).toDate(),
      notes: map['notes'] ?? '',
      exercises: List<Map<String, dynamic>>.from(map['exercises'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'trainerId': trainerId,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'exercises': exercises,
    };
  }
}
