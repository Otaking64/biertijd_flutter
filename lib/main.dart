import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wie_moet_er_bier_gaan_halen/authentication_screen.dart';
import 'package:wie_moet_er_bier_gaan_halen/groups_screen.dart';
import 'package:wie_moet_er_bier_gaan_halen/registration_screen.dart';
import 'gen/l10n/app_localizations.dart';
import 'name_list_screen.dart';
import 'firebase_options.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
AppLocalizations get translations => AppLocalizations.of(navigatorKey.currentContext!)!;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
      navigatorKey: navigatorKey,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
        '/home': (context) => const NameListScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/groups': (context) => const GroupsScreen(),
      },
    );
  }
}
