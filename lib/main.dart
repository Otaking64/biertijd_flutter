import 'package:flutter/material.dart';

import 'name_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

final Color mainYellow = Color(0xFFFBC02D);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,

  colorScheme: ColorScheme.fromSeed(
    seedColor: mainYellow,
    primary: mainYellow,
    brightness: Brightness.light,
  ),

  appBarTheme: const AppBarTheme(foregroundColor: Colors.black),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: mainYellow,

    brightness: Brightness.dark,
  ),
  appBarTheme: const AppBarTheme(foregroundColor: Colors.white),
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Name App',
      // Using the themes we defined earlier
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFBC02D),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFBC02D),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const NameListPage(),
    );
  }
}
