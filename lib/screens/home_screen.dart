import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../core/services/auth_service.dart';

// Placeholder imports for dashboards
import 'admin/admin_dashboard.dart';
import 'trainer/trainer_dashboard.dart';
import 'member/member_dashboard.dart';

class HomeScreen extends StatefulWidget {
  final String uid;
  const HomeScreen({super.key, required this.uid});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch user details when Home initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).setUser(widget.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = userProvider.user;

    if (user == null) {
      // User data missing in Firestore?
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("User profile not found."),
              ElevatedButton(
                onPressed: () => Provider.of<AuthService>(context, listen: false).signOut(),
                child: const Text("Logout"),
              ),
            ],
          ),
        ),
      );
    }

    // Role-based routing
    switch (user.role) {
      case 'admin':
        return const AdminDashboard();
      case 'trainer':
        return const TrainerDashboard();
      case 'member':
      default:
        return const MemberDashboard();
    }
  }
}
