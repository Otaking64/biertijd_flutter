import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wie_moet_er_bier_gaan_halen/authentication_screen.dart';
import 'package:wie_moet_er_bier_gaan_halen/registration_screen.dart';
import 'name_list_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform.copyWith(
      databaseURL: "https://biertijdapp.firebaseio.com",
    ),
  );
  runApp(const AppEntry());
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  late Future<String> _initialRouteFuture;

  @override
  void initState() {
    super.initState();
    _initialRouteFuture = _getInitialRoute();
  }

  Future<String> _getInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenAuthScreen = prefs.getBool('hasSeenAuthScreen') ?? false;
    return hasSeenAuthScreen ? '/home' : '/auth';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _initialRouteFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        if (snapshot.hasData) {
          return MyApp(initialRoute: snapshot.data!);
        } else {
          // Should not happen, but have a fallback
          return MyApp(initialRoute: '/auth');
        }
      },
    );
  }
}

final Color mainYellow = const Color(0xFFFBC02D);

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biertijd App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: mainYellow,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: mainYellow,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      initialRoute: initialRoute,
      routes: {
        '/auth': (context) => const AuthenticationScreen(),
        '/home': (context) => const AuthWrapper(),
        '/register': (context) => const RegistrationScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // The user object is passed to NameListPage, which can be null.
        return NameListPage(user: snapshot.data);
      },
    );
  }
}
