import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Account_Screen.dart';

// Define an enum for the drink choices
enum Drink { beer, whiskey, wine, cola }

// Extension to get a user-friendly string from the enum
extension DrinkExtension on Drink {
  String get displayName {
    switch (this) {
      case Drink.beer:
        return 'Beer';
      case Drink.whiskey:
        return 'Whiskey';
      case Drink.wine:
        return 'Wine';
      case Drink.cola:
        return 'Cola';
      default:
        return '';
    }
  }
}

class Person {
  String name;
  int beerCount;
  Drink preferredDrink; // Add preferredDrink field

  Person({
    required this.name,
    this.beerCount = 0,
    this.preferredDrink = Drink.beer, // Default drink is beer
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      name: json['name'],
      beerCount: json['beerCount'] ?? 0,
      // Handle deserialization of the preferredDrink
      preferredDrink: Drink.values.firstWhere(
            (e) => e.toString() == json['preferredDrink'],
        orElse: () => Drink.beer, // Default to beer if not found
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'beerCount': beerCount,
      'preferredDrink': preferredDrink.toString(), // Store enum as string
    };
  }
}

class NameListPage extends StatefulWidget {
  final User? user;
  const NameListPage({Key? key, this.user}) : super(key: key);

  @override
  State<NameListPage> createState() => _NameListPageState();
}

class _NameListPageState extends State<NameListPage> {
  final List<Person> _people = [];

  bool _isShowingResult = false;
  Person? _selectedPerson;

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _loadPeople();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadPeople() async {
    final prefs = await SharedPreferences.getInstance();
    final peopleJson = prefs.getStringList('people') ?? [];
    setState(() {
      _people.clear();
      _people.addAll(peopleJson.map((p) => Person.fromJson(jsonDecode(p))));
    });
  }

  Future<void> _savePeople() async {
    final prefs = await SharedPreferences.getInstance();
    final peopleJson = _people.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList('people', peopleJson);
  }

  Future<void> _resetCounters() async {
    setState(() {
      for (var person in _people) {
        person.beerCount = 0;
      }
    });
    await _savePeople();
  }

  void _pickRandomName() {
    if (_people.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voeg eerst wat namen toe.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final random = Random();
    final index = random.nextInt(_people.length);
    final selectedPerson = _people[index];

    setState(() {
      selectedPerson.beerCount++;
      _selectedPerson = selectedPerson;
      _isShowingResult = true;
    });
    _savePeople();
    _confettiController.play();
  }

  void _hideResult() {
    setState(() {
      _isShowingResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Bier halers'),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'account') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountScreen(
                          onResetCounters: _resetCounters,
                          user: widget.user,
                        ),
                      ),
                    );
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'account',
                      child: Text('Account'),
                    ),
                  ];
                },
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: _people.length,
            itemBuilder: (context, index) {
              final person = _people[index];
              return ListTile(
                title: Text(person.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Add dropdown for drink selection
                    DropdownButton<Drink>(
                      value: person.preferredDrink,
                      onChanged: (Drink? newValue) {
                        if (newValue != null) {
                          setState(() {
                            person.preferredDrink = newValue;
                          });
                          _savePeople();
                        }
                      },
                      items: Drink.values.map<DropdownMenuItem<Drink>>((Drink value) {
                        return DropdownMenuItem<Drink>(
                          value: value,
                          child: Text(value.displayName),
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      person.beerCount.toString(),
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() {
                          _people.removeAt(index);
                        });
                        _savePeople();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddNameDialog,
            tooltip: 'Naam toevoegen',
            child: const Icon(Icons.add),
          ),
          persistentFooterButtons: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: _pickRandomName,
                child: const Text(
                  'Wie moet er bier gaan halen?',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
        if (_isShowingResult && _selectedPerson != null)
          GestureDetector(
            onTap: _hideResult,
            child: Container(
              color: Colors.black.withOpacity(0.85),
              child: Center(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _selectedPerson!.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'moet bier gaan halen',
                        style: TextStyle(
                          fontSize: 28, // Smaller font size
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          numberOfParticles: 50,
          gravity: 0.3,
          emissionFrequency: 0.1, // How often particles are emitted
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple,
          ],
        ),
      ],
    );
  }

  Future<void> _showAddNameDialog() async {
    final TextEditingController nameController = TextEditingController();
    final String? newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a New Name'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Name'),
            onSubmitted: (name) => Navigator.of(context).pop(name),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('annuleren'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Toevoegen'),
              onPressed: () => Navigator.of(context).pop(nameController.text),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      setState(() {
        _people.add(Person(name: newName));
      });
      await _savePeople();
    }
  }
}
