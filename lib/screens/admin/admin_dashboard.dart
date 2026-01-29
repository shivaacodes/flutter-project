import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/database_service.dart';
import '../../models/plan_model.dart';
import '../../models/user_model.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthService>(context, listen: false).signOut(),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: "Plans"),
                Tab(text: "Members"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPlansTab(context),
                  _buildMembersTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansTab(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<PlanModel>>(
            stream: DatabaseService().getPlans(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final plans = snapshot.data!;
              if (plans.isEmpty) return const Center(child: Text("No plans added."));
              return ListView.builder(
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return Card(
                    child: ListTile(
                      title: Text(plan.name),
                      subtitle: Text('\$${plan.price} - ${plan.durationMonths} months'),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () => _showAddPlanDialog(context),
            child: const Text('Add New Plan'),
          ),
        ),
      ],
    );
  }

  Widget _buildMembersTab() {
    return StreamBuilder<List<UserModel>>(
      stream: DatabaseService().getMembers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final members = snapshot.data!;
        if (members.isEmpty) return const Center(child: Text("No members found."));
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
                trailing: const Icon(Icons.check_circle, color: Colors.green), // Mock approval
              ),
            );
          },
        );
      },
    );
  }

  void _showAddPlanDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Plan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Plan Name")),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              DatabaseService().addPlan(PlanModel(
                id: '',
                name: nameController.text,
                price: double.tryParse(priceController.text) ?? 0,
                durationMonths: 1,
                features: [],
              ));
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
