import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/plan_model.dart';
import '../../models/workout_model.dart';
import '../../models/class_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get _users => _db.collection('users');
  CollectionReference get _plans => _db.collection('plans');
  CollectionReference get _workouts => _db.collection('workouts');
  CollectionReference get _classes => _db.collection('classes');

  // --- User Operations ---
  Future<void> createUser(UserModel user) async {
    await _users.doc(user.uid).set(user.toMap());
  }

  Future<void> updateUserProfile(String uid, String photoUrl) async {
    await _users.doc(uid).update({'profilePhotoUrl': photoUrl});
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _users.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Get all members (for Admin/Trainer)
  Stream<List<UserModel>> getMembers() {
    return _users.where('role', isEqualTo: 'member').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // --- Plan Operations (Admin) ---
  Future<void> addPlan(PlanModel plan) async {
    // If id is empty, let Firestore generate it
    if (plan.id.isEmpty) {
      await _plans.add(plan.toMap());
    } else {
      await _plans.doc(plan.id).set(plan.toMap());
    }
  }

  Stream<List<PlanModel>> getPlans() {
    return _plans.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return PlanModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // --- Workout Operations ---
  Future<void> logWorkout(WorkoutModel workout) async {
    await _workouts.add(workout.toMap());
  }

  Stream<List<WorkoutModel>> getUserWorkouts(String memberId) {
    return _workouts
        .where('memberId', isEqualTo: memberId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return WorkoutModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // --- Class Operations ---
  Stream<List<ClassModel>> getClasses() {
    return _classes.orderBy('startTime').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ClassModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> bookClass(String classId, String userId) async {
    final classDoc = _classes.doc(classId);
    final snapshot = await classDoc.get();
    
    if (!snapshot.exists) return;

    final data = snapshot.data() as Map<String, dynamic>;
    final List<dynamic> currentAttendees = data['registeredUserIds'] ?? [];
    
    if (!currentAttendees.contains(userId)) {
      await classDoc.update({
        'registeredUserIds': FieldValue.arrayUnion([userId])
      });
    }
  }

  // Helper to create dummy classes for testing
  Future<void> seedClasses() async {
    final now = DateTime.now();
    final classes = [
      ClassModel(id: '', name: 'Morning Yoga', instructor: 'Sarah', startTime: now.add(const Duration(hours: 2)), durationMinutes: 60, capacity: 20, registeredUserIds: []),
      ClassModel(id: '', name: 'HIIT Blast', instructor: 'Mike', startTime: now.add(const Duration(hours: 5)), durationMinutes: 45, capacity: 15, registeredUserIds: []),
      ClassModel(id: '', name: 'Evening Pilates', instructor: 'Sarah', startTime: now.add(const Duration(days: 1, hours: 10)), durationMinutes: 60, capacity: 15, registeredUserIds: []),
    ];

    for (var c in classes) {
      await _classes.add(c.toMap());
    }
  }
}
