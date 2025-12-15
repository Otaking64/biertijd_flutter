
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wie_moet_er_bier_gaan_halen/name_list_screen.dart'; // For Drink Enum

class AccountScreen extends StatefulWidget {
  final Future<void> Function() onResetCounters;
  final User? user;

  const AccountScreen({Key? key, required this.onResetCounters, this.user}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
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
    if (widget.user != null) {
      _loadUserData();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      final ref = _database.ref('users/${widget.user!.uid}');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          _firstNameController.text = data['firstName'] ?? '';
          _lastNameInitialController.text = data['lastNameInitial'] ?? '';
          // Convert string back to enum
          final drinkString = data['preferredDrink'];
          _selectedDrink = Drink.values.firstWhere(
                (e) => e.toString() == drinkString,
            orElse: () => Drink.beer, // Default value if parsing fails
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      try {
        final ref = _database.ref('users/${widget.user!.uid}');
        await ref.update({
          'firstName': _firstNameController.text.trim(),
          'lastNameInitial': _lastNameInitialController.text.trim(),
          'preferredDrink': _selectedDrink.toString(), // Convert enum to string
        });
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if(mounted) {
      Navigator.of(context).pop();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/auth');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameInitialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account & Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.user != null)
                      _buildProfileView()
                    else
                      _buildLoginView(),

                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 32),

                    _buildResetCountersButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileView() {
    return Column(
      children: [
        Text('Logged in as:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(widget.user!.email ?? 'No email', style: Theme.of(context).textTheme.bodyLarge),
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
            setState(() {
              _selectedDrink = newValue;
            });
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
      ],
    );
  }

  Widget _buildLoginView() {
    return ElevatedButton.icon(
      onPressed: _navigateToLogin,
      icon: const Icon(Icons.login),
      label: const Text('Login or Register'),
    );
  }

  Widget _buildResetCountersButton() {
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
          await widget.onResetCounters();
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Counters have been reset.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        }
      },
      child: const Text('Reset All Beer Counters'),
    );
  }
}
