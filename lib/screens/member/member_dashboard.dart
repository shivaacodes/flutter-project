import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/database_service.dart';
import '../../core/services/storage_service.dart';
import '../../providers/user_provider.dart';
import '../../models/workout_model.dart';
import '../../models/plan_model.dart';
import '../../models/class_model.dart';
import '../common/settings_screen.dart';

class MemberDashboard extends StatefulWidget {
  const MemberDashboard({super.key});

  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    if (user == null) return const Center(child: CircularProgressIndicator());

    final List<Widget> pages = [
      _buildHomeTab(context, user.uid, user.membershipPlanId),
      _buildWorkoutsTab(user.uid),
      _buildProfileTab(context, user.uid, user.profilePhotoUrl, user.name, user.email),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Home' : (_selectedIndex == 1 ? 'Workouts' : 'Profile')),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthService>(context, listen: false).signOut(),
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (idx) => setState(() => _selectedIndex = idx),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Workouts"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, String uid, String? planId) {
    return SingleChildScrollView( // Made scrollable
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.blue.shade50,
            child: ListTile(
              leading: const Icon(Icons.card_membership, color: Colors.blue),
              title: const Text("Membership Status"),
              subtitle: Text(planId != null ? "Active Plan: $planId" : "No Active Plan"),
              trailing: planId == null ? ElevatedButton(onPressed: () {}, child: const Text("Buy")) : const Icon(Icons.check_circle, color: Colors.green),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Upcoming Classes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextButton(
                onPressed: () => _showBookClassCallback(context, uid),
                child: const Text("Book Class"),
              ),
            ],
          ),
          StreamBuilder<List<ClassModel>>(
            stream: DatabaseService().getClasses(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final classes = snapshot.data!;
              final myClasses = classes.where((c) => c.registeredUserIds.contains(uid)).toList();
              
              if (myClasses.isEmpty) {
                return const Card(child: Padding(padding: EdgeInsets.all(20), child: Text("No classes booked yet.")));
              }

              return Column(
                children: myClasses.map((c) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.event),
                    title: Text(c.name),
                    subtitle: Text("${c.instructor} • ${c.startTime.toString().split('.')[0]}"), // Simple format
                    trailing: const Chip(label: Text("Booked", style: TextStyle(color: Colors.green))),
                  ),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showBookClassCallback(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Available Classes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<List<ClassModel>>(
                  stream: DatabaseService().getClasses(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final classes = snapshot.data!;
                    // Filter out already booked classes or past classes if desired
                    final available = classes.where((c) => !c.registeredUserIds.contains(uid)).toList();
                    
                    if (available.isEmpty) return const Center(child: Text("No available classes to book."));

                    return ListView.builder(
                      itemCount: available.length,
                      itemBuilder: (context, index) {
                        final c = available[index];
                        return Card(
                          child: ListTile(
                            title: Text(c.name),
                            subtitle: Text("${c.instructor} • ${c.startTime.hour}:${c.startTime.minute.toString().padLeft(2, '0')}"),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                await DatabaseService().bookClass(c.id, uid);
                                if (context.mounted) {
                                   Navigator.pop(context);
                                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Booked ${c.name}!")));
                                }
                              },
                              child: const Text("Book"),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkoutsTab(String uid) {
    return StreamBuilder<List<WorkoutModel>>(
      stream: DatabaseService().getUserWorkouts(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final workouts = snapshot.data!;
        if (workouts.isEmpty) return const Center(child: Text("No workouts logged."));
        return ListView.builder(
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final workout = workouts[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.history),
                title: Text(workout.notes.isEmpty ? "Workout" : workout.notes),
                subtitle: Text(workout.date.toString().split(' ')[0]),
                trailing: workout.trainerId != null ? const Chip(label: Text("Assigned")) : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileTab(BuildContext context, String uid, String? photoUrl, String name, String email) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _uploadImage(context, uid),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null ? const Icon(Icons.camera_alt, size: 40) : null,
            ),
          ),
          const SizedBox(height: 10),
          Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(email, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          const ListTile(leading: Icon(Icons.help), title: Text("Help & Support")),
        ],
      ),
    );
  }

  Future<void> _uploadImage(BuildContext context, String uid) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uploading image...")));
      String? url = await StorageService().uploadProfileImage(uid, File(image.path));
      if (url != null) {
        await DatabaseService().updateUserProfile(uid, url);
        await Provider.of<UserProvider>(context, listen: false).refreshUser(); // Should implement refresh
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload successful!")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload failed.")));
      }
    }
  }
}
