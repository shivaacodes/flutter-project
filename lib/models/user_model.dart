
class UserModel {
  final String uid;
  final String email;
  final String role; // 'admin', 'trainer', 'member'
  final String name;
  final String? profilePhotoUrl;
  final String? membershipPlanId;
  final String? assignedTrainerId;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
    this.profilePhotoUrl,
    this.membershipPlanId,
    this.assignedTrainerId,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      role: map['role'] ?? 'member',
      name: map['name'] ?? '',
      profilePhotoUrl: map['profilePhotoUrl'],
      membershipPlanId: map['membershipPlanId'],
      assignedTrainerId: map['assignedTrainerId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'name': name,
      'profilePhotoUrl': profilePhotoUrl,
      'membershipPlanId': membershipPlanId,
      'assignedTrainerId': assignedTrainerId,
    };
  }
}
