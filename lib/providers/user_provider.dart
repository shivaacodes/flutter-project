import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../core/services/auth_service.dart';
import '../core/services/database_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  final DatabaseService _db = DatabaseService();

  UserModel? get user => _user;

  bool get isLoading => _user == null; // Simple loading check

  Future<void> refreshUser() async {
    if (_user != null) {
      _user = await _db.getUser(_user!.uid);
      notifyListeners();
    }
  }

  Future<void> setUser(String uid) async {
    _user = await _db.getUser(uid);
    notifyListeners();
  }
  
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
