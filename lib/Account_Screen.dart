
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wie_moet_er_bier_gaan_halen/name_list_screen.dart'; // For Drink Enum

// The main entry point for the screen. It's a stateless widget that
// uses a StreamBuilder to reactively switch between logged-in and logged-out views.
class AccountScreen extends StatelessWidget {
  final Future<void> Function() onResetCounters;

  const AccountScreen({Key? key, required this.onResetCounters}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account & Settings'),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;

          if (user != null) {
            // If the user is logged in, show the full profile editor.
            return ProfileEditor(user: user, onResetCounters: onResetCounters);
          } else {
            // If logged out, show a simple view with login and reset buttons.
            return LoggedOutView(onResetCounters: onResetCounters);
          }
        },
      ),
    );
  }
}

// A dedicated stateless widget for the logged-out state.
class LoggedOutView extends StatelessWidget {
  final Future<void> Function() onResetCounters;

  const LoggedOutView({Key? key, required this.onResetCounters}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/auth'),
            icon: const Icon(Icons.login),
            label: const Text('Login or Register'),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 32),
          _buildResetCountersButton(context, onResetCounters),
        ],
      ),
    );
  }
}

// A dedicated stateful widget that contains the form for editing the user's profile.
class ProfileEditor extends StatefulWidget {
  final User user;
  final Future<void> Function() onResetCounters;

  const ProfileEditor({Key? key, required this.user, required this.onResetCounters}) : super(key: key);

  @override
  State<ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<ProfileEditor> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameInitialController;
  Drink? _selectedDrink;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameInitialController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameInitialController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final ref = _database.ref('users/${widget.user.uid}');
      final snapshot = await ref.get();
      if (mounted && snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          _firstNameController.text = data['firstName'] ?? '';
          _lastNameInitialController.text = data['lastNameInitial'] ?? '';
          final drinkString = data['preferredDrink'];
          _selectedDrink = Drink.values.firstWhere(
                (e) => e.toString() == drinkString,
            orElse: () => Drink.beer, // Default to beer if parsing fails
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      try {
        final ref = _database.ref('users/${widget.user.uid}');
        await ref.update({
          'firstName': _firstNameController.text.trim(),
          'lastNameInitial': _lastNameInitialController.text.trim(),
          'preferredDrink': _selectedDrink.toString(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_group', 'local');

    await FirebaseAuth.instance.signOut();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Logged in as:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SelectableText(
              widget.user.email ?? 'No email provided',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
              validator: (value) => value!.isEmpty ? 'Please enter your first name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameInitialController,
              decoration: const InputDecoration(labelText: 'First Letter of Last Name'),
              maxLength: 1,
              validator: (value) => value!.isEmpty ? 'Please enter the first letter of your last name' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Drink>(
              value: _selectedDrink,
              decoration: const InputDecoration(labelText: 'Preferred Drink'),
              items: Drink.values.map((Drink drink) {
                return DropdownMenuItem<Drink>(
                  value: drink,
                  child: Text(drink.displayName),
                );
              }).toList(),
              onChanged: (Drink? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedDrink = newValue;
                  });
                }
              },
              validator: (value) => value == null ? 'Please select your preferred drink' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _updateUserData,
              child: const Text('Update Profile'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),
            _buildResetCountersButton(context, widget.onResetCounters),
          ],
        ),
      ),
    );
  }
}

// Helper function for the reset button, usable by both logged-in and logged-out views.
Widget _buildResetCountersButton(BuildContext context, Future<void> Function() onResetCounters) {
  return ElevatedButton(
    onPressed: () async {
      final bool? shouldReset = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Reset Counters'),
            content: const Text('Are you sure you want to reset all beer counters?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ElevatedButton(
                child: const Text('Reset'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      if (shouldReset == true) {
        await onResetCounters();
        if (ScaffoldMessenger.of(context).mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Counters have been reset.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    },
    child: const Text('Reset All Beer Counters'),
  );
}
