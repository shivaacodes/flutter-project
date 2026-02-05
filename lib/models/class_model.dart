class ClassModel {
  final String id;
  final String name;
  final String instructor;
  final DateTime startTime;
  final int durationMinutes;
  final int capacity;
  final List<String> registeredUserIds;

  ClassModel({
    required this.id,
    required this.name,
    required this.instructor,
    required this.startTime,
    required this.durationMinutes,
    required this.capacity,
    required this.registeredUserIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'instructor': instructor,
      'startTime': startTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'capacity': capacity,
      'registeredUserIds': registeredUserIds,
    };
  }

  factory ClassModel.fromMap(Map<String, dynamic> map, String id) {
    return ClassModel(
      id: id,
      name: map['name'] ?? '',
      instructor: map['instructor'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      durationMinutes: map['durationMinutes'] ?? 60,
      capacity: map['capacity'] ?? 20,
      registeredUserIds: List<String>.from(map['registeredUserIds'] ?? []),
    );
  }
}
