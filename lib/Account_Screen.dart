import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wie_moet_er_bier_gaan_halen/main.dart';
import 'package:wie_moet_er_bier_gaan_halen/name_list_screen.dart';

class AccountScreen extends StatelessWidget {
  final Future<void> Function() onResetCounters;

  const AccountScreen({Key? key, required this.onResetCounters}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translations.accountSettingsTitle),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;

          if (user != null) {
            return ProfileEditor(user: user, onResetCounters: onResetCounters);
          } else {
            return LoggedOutView(onResetCounters: onResetCounters);
          }
        },
      ),
    );
  }
}

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
            label: Text(translations.loginOrRegisterButton),
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
            orElse: () => Drink.beer,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(translations.loadUserDataError(e.toString())), backgroundColor: Colors.red),
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
            SnackBar(content: Text(translations.profileUpdatedSuccess), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(translations.profileUpdateError(e.toString())), backgroundColor: Colors.red),
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
            Text(translations.loggedInAsLabel, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SelectableText(
              widget.user.email ?? translations.noEmailProvidedLabel,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: translations.firstNameLabel, counterText: ""),
              maxLength: 15,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                _TitleCaseInputFormatter(),
              ],
              validator: (value) => value!.isEmpty ? translations.firstNameEmptyError : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameInitialController,
              decoration: InputDecoration(labelText: translations.lastNameInitialLabel, counterText: ""),
              maxLength: 1,
              textCapitalization: TextCapitalization.characters,
              validator: (value) => value!.isEmpty ? translations.lastNameInitialEmptyError : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Drink>(
              value: _selectedDrink,
              decoration: InputDecoration(labelText: translations.preferredDrinkLabel),
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
              validator: (value) => value == null ? translations.preferredDrinkEmptyError : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _updateUserData,
              child: Text(translations.updateProfileButton),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: Text(translations.logoutButton),
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

class _TitleCaseInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    return TextEditingValue(
      text: newValue.text.substring(0, 1).toUpperCase() + newValue.text.substring(1),
      selection: newValue.selection,
    );
  }
}

Widget _buildResetCountersButton(BuildContext context, Future<void> Function() onResetCounters) {
  return ElevatedButton(
    onPressed: () async {
      final bool? shouldReset = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(translations.resetCountersTitle),
            content: Text(translations.resetCountersConfirmation),
            actions: <Widget>[
              TextButton(
                child: Text(translations.cancel_button),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ElevatedButton(
                child: Text(translations.resetButton),
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
            SnackBar(
              content: Text(translations.countersResetSuccess),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    },
    child: Text(translations.resetAllCountersButton),
  );
}