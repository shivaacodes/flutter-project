import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change Password"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Feature coming soon!")));
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            trailing: Switch(value: true, onChanged: (val) {}),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About App"),
            subtitle: const Text("Version 1.0.0"),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              Provider.of<AuthService>(context, listen: false).signOut();
              Navigator.pop(context); // Go back to prevent back stack issues
            },
          ),
        ],
      ),
    );
  }
}
