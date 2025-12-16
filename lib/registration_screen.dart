import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wie_moet_er_bier_gaan_halen/main.dart';
import 'name_list_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameInitialController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  Drink? _selectedDrink = Drink.beer;
  String _errorMessage = '';

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = '';
      });
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        DatabaseReference userRef = FirebaseDatabase.instance.ref('users/${userCredential.user!.uid}');
        await userRef.set({
          'firstName': _firstNameController.text.trim(),
          'lastNameInitial': _lastNameInitialController.text.trim(),
          'email': _emailController.text.trim(),
          'preferredDrink': _selectedDrink.toString(),
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasSeenAuthScreen', true);

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.message ?? translations.unknownError;
        });
      } catch (e) {
        setState(() {
          _errorMessage = translations.unexpectedError;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translations.createAccountTitle),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: translations.firstNameLabel),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return translations.firstNameEmptyError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameInitialController,
                  decoration: InputDecoration(labelText: translations.lastNameInitialLabel),
                  maxLength: 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return translations.lastNameInitialEmptyError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: translations.emailLabel),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return translations.emailInvalidError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: translations.passwordLabel),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return translations.passwordLengthError;
                    }
                    return null;
                  },
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
                    setState(() {
                      _selectedDrink = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return translations.preferredDrinkEmptyError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ElevatedButton(
                  onPressed: _register,
                  child: Text(translations.registerButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
