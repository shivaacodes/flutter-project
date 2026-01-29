import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/database_service.dart';
import '../../models/user_model.dart';
import '../../models/workout_model.dart';
import 'package:provider/provider.dart';

class TrainerDashboard extends StatelessWidget {
  const TrainerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthService>(context, listen: false).signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: DatabaseService().getMembers(), // Ideally filter by assigned trainer
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final members = snapshot.data!;
          if (members.isEmpty) return const Center(child: Text("No members assigned."));
          
          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: member.profilePhotoUrl != null ? NetworkImage(member.profilePhotoUrl!) : null,
                    child: member.profilePhotoUrl == null ? const Icon(Icons.person) : null,
                  ),
                  title: Text(member.name),
                  subtitle: Text(member.email),
                  trailing: IconButton(
                    icon: const Icon(Icons.fitness_center),
                    onPressed: () => _showAssignWorkoutDialog(context, member.uid),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAssignWorkoutDialog(BuildContext context, String memberId) {
    final notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Assign Workout"),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(labelText: "Workout Logic (e.g. 5x5 Squats)"),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              DatabaseService().logWorkout(WorkoutModel(
                id: '',
                memberId: memberId,
                date: DateTime.now(),
                notes: notesController.text,
                exercises: [],
                trainerId: 'Trainer', // Should get current trainer ID
              ));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Workout Assigned!")));
            },
            child: const Text("Assign"),
          ),
        ],
      ),
    );
  }
}
