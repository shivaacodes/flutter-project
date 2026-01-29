import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/database_service.dart';
import '../../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String name = '';
  bool isLogin = true;
  String selectedRole = 'member'; // Default role for registration

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (val) => email = val,
                validator: (val) => val!.isEmpty ? 'Enter email' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (val) => password = val,
                validator: (val) => val!.length < 6 ? 'Password too short' : null,
              ),
              if (!isLogin) ...[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  onChanged: (val) => name = val,
                  validator: (val) => val!.isEmpty ? 'Enter name' : null,
                ),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: ['member', 'trainer', 'admin']
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => selectedRole = val!),
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final auth = Provider.of<AuthService>(context, listen: false);
                    final db = DatabaseService();
                    
                    if (isLogin) {
                      await auth.signIn(email, password);
                    } else {
                      final user = await auth.signUp(email, password);
                      if (user != null) {
                        // Create user profile in Firestore
                        await db.createUser(UserModel(
                          uid: user.uid,
                          email: email,
                          role: selectedRole,
                          name: name,
                        ));
                      }
                    }
                  }
                },
                child: Text(isLogin ? 'Login' : 'Register'),
              ),
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(isLogin ? 'Create Account' : 'Have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
