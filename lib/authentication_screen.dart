import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wie_moet_er_bier_gaan_halen/main.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _message;
  bool _isError = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _message = translations.enterEmailAndPasswordMessage;
        _isError = true;
      });
      return;
    }
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await _setHasSeenAuthScreen();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _message = e.message;
        _isError = true;
      });
    }
  }

  Future<void> _showPasswordResetDialog() async {
    final TextEditingController emailController =
        TextEditingController(text: _emailController.text);
    String? dialogMessage;
    bool isError = false;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(translations.resetPasswordTitle),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(translations.resetPasswordInstruction),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: translations.emailLabel),
                      keyboardType: TextInputType.emailAddress,
                      autofocus: true,
                    ),
                    if (dialogMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          dialogMessage!,
                          style: TextStyle(
                              color: isError ? Colors.red : Colors.green),
                        ),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(translations.cancel_button),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text(translations.sendResetEmailButton),
                  onPressed: () async {
                    if (emailController.text.isEmpty) {
                      setState(() {
                        dialogMessage =
                            translations.enterEmailToResetPasswordMessage;
                        isError = true;
                      });
                      return;
                    }
                    try {
                      await _auth.sendPasswordResetEmail(
                          email: emailController.text);
                      setState(() {
                        dialogMessage =
                            translations.passwordResetEmailSentMessage;
                        isError = false;
                      });
                    } on FirebaseAuthException catch (e) {
                      setState(() {
                        dialogMessage = e.message;
                        isError = true;
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _setHasSeenAuthScreen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenAuthScreen', true);
  }

  Future<void> _continueOffline() async {
    await _setHasSeenAuthScreen();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translations.authScreenTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: translations.emailLabel),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: translations.passwordLabel),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _message!,
                  style: TextStyle(color: _isError ? Colors.red : Colors.green),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _login,
                  child: Text(translations.loginButton),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/register');
                  },
                  child: Text(translations.registerButton),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _showPasswordResetDialog,
              child: Text(translations.forgotPasswordButton),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _continueOffline,
              child: Text(translations.continueOfflineButton),
            ),
          ],
        ),
      ),
    );
  }
}
