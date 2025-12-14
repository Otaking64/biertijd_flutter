import 'package:flutter/material.dart';

import 'name_list_screen.dart';

void main() {
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

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});
  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  get _names => null;

  Future<String?> _addName(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a New Name'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter a new name',
              labelText: 'Name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                final String name = nameController.text;

                if (name.isNotEmpty) {
                  print('Name added: $name');
                  Navigator.of(context).pop(name);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(mainAxisAlignment: .center, children: []),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final String? newName = await _addName(context);
          if (newName != null && newName.isNotEmpty) {
            setState(() {
              _names.add(newName);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
