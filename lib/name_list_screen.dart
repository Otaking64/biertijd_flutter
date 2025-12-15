
import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Account_Screen.dart';

enum Drink { beer, whiskey, wine, cola }

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
  int numberOfRounds;
  Drink preferredDrink;
  String? uid;

  Person({
    required this.name,
    this.numberOfRounds = 0,
    this.preferredDrink = Drink.beer,
    this.uid,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      name: json['name'],
      numberOfRounds: json['numberOfRounds'] ?? 0,
      preferredDrink: Drink.values.firstWhere(
            (e) => e.toString() == json['preferredDrink'],
        orElse: () => Drink.beer,
      ),
      uid: json['uid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'numberOfRounds': numberOfRounds,
      'preferredDrink': preferredDrink.toString(),
      'uid': uid,
    };
  }
}

class NameListScreen extends StatefulWidget {
  const NameListScreen({Key? key}) : super(key: key);

  @override
  State<NameListScreen> createState() => _NameListScreenState();
}

class _NameListScreenState extends State<NameListScreen> {
  final List<Person> _localGroupMembers = [];
  String? _activeGroupId;
  String _activeGroupName = 'Local Group (On this device)';

  bool _isShowingResult = false;
  Person? _selectedPerson;
  String? _selectedOnlineUserName;

  late ConfettiController _confettiController;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _loadLocalGroup();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalGroup() async {
    final prefs = await SharedPreferences.getInstance();
    final peopleJson = prefs.getStringList('people') ?? [];
    setState(() {
      _localGroupMembers.clear();
      _localGroupMembers.addAll(peopleJson.map((p) => Person.fromJson(jsonDecode(p))));
    });
  }

  Future<void> _saveLocalGroup() async {
    final prefs = await SharedPreferences.getInstance();
    final peopleJson = _localGroupMembers.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList('people', peopleJson);
  }

  Future<void> _setActiveGroup(String groupId) async {
    final groupNameRef = FirebaseDatabase.instance.ref('groups/$groupId/name');
    final snapshot = await groupNameRef.get();
    setState(() {
      _activeGroupId = groupId;
      _activeGroupName = (snapshot.value as String?) ?? 'Unnamed Group';
    });
  }

  void _clearActiveGroup() {
    setState(() {
      _activeGroupId = null;
      _activeGroupName = 'Local Group (On this device)';
    });
    _loadLocalGroup();
  }

  void _pickRandomName() {
    if (_activeGroupId == null) {
      // Local group logic
      if (_localGroupMembers.isEmpty) {
        _showErrorSnackbar('Voeg eerst wat namen toe.');
        return;
      }
      final random = Random();
      final index = random.nextInt(_localGroupMembers.length);
      final selectedPerson = _localGroupMembers[index];

      setState(() {
        selectedPerson.numberOfRounds++;
        _selectedPerson = selectedPerson;
        _selectedOnlineUserName = null;
        _isShowingResult = true;
      });
      _saveLocalGroup();
      _confettiController.play();
    } else {
      // Online group logic
      final membersRef = FirebaseDatabase.instance.ref('groups/$_activeGroupId/members');
      membersRef.once().then((snapshot) {
        if (!snapshot.snapshot.exists || snapshot.snapshot.value == null) {
          _showErrorSnackbar('This group has no members.');
          return;
        }
        final members = (snapshot.snapshot.value as Map<dynamic, dynamic>).keys.toList();
        final random = Random();
        final selectedUid = members[random.nextInt(members.length)];

        final userRef = FirebaseDatabase.instance.ref('users/$selectedUid');
        userRef.once().then((userSnapshot) {
          String displayName = 'Unknown User';
          if (userSnapshot.snapshot.exists && userSnapshot.snapshot.value != null) {
            final userData = userSnapshot.snapshot.value as Map<dynamic, dynamic>;
            final firstName = userData['firstName'] ?? 'Unknown';
            final lastNameInitial = userData['lastNameInitial'] ?? '';
            displayName = '$firstName ${lastNameInitial.isNotEmpty ? lastNameInitial + "." : ""}'.trim();

            // Increment the round count
            final currentRounds = userData['numberOfRounds'] as int? ?? 0;
            userRef.update({'numberOfRounds': currentRounds + 1});
          }

          setState(() {
            _selectedPerson = null;
            _selectedOnlineUserName = displayName;
            _isShowingResult = true;
          });
          _confettiController.play();
        });
      });
    }
  }

  void _hideResult() {
    setState(() {
      _isShowingResult = false;
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // --- Navigation ---

  void _navigateToGroups() async {
    final result = await Navigator.of(context).pushNamed('/groups');
    if (result is String) {
      _setActiveGroup(result);
    } else if (result == null) {
      _clearActiveGroup();
    }
  }

  void _navigateToAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountScreen(
          onResetCounters: () async {
            setState(() {
              for (var person in _localGroupMembers) {
                person.numberOfRounds = 0;
              }
            });
            await _saveLocalGroup();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(_activeGroupName),
            actions: [
              if (_currentUser != null)
                IconButton(
                  icon: const Icon(Icons.group),
                  tooltip: 'Groups',
                  onPressed: _navigateToGroups,
                ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'account') {
                    _navigateToAccount();
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'account',
                    child: Text('Account & Settings'),
                  ),
                ],
              ),
            ],
          ),
          body: _buildBody(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (_activeGroupId == null) {
                _showAddNameDialog();
              } else {
                _showQrCodeDialog();
              }
            },
            tooltip: _activeGroupId == null ? 'Naam toevoegen' : 'Show Group QR',
            child: Icon(_activeGroupId == null ? Icons.add : Icons.qr_code),
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
        if (_isShowingResult)
          _buildResultOverlay(),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          numberOfParticles: 50,
          gravity: 0.3,
          emissionFrequency: 0.1,
          colors: const [
            Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple
          ],
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_activeGroupId == null) {
      return _buildLocalGroupList();
    } else {
      return _buildOnlineGroupList();
    }
  }

  Widget _buildLocalGroupList() {
    return ListView.builder(
      itemCount: _localGroupMembers.length,
      itemBuilder: (context, index) {
        final person = _localGroupMembers[index];
        final isCurrentUser = _currentUser?.uid == person.uid;
        return ListTile(
          title: Text(person.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<Drink>(
                value: person.preferredDrink,
                onChanged: (Drink? newValue) {
                  if (newValue != null) {
                    setState(() {
                      person.preferredDrink = newValue;
                    });
                    _saveLocalGroup();
                  }
                },
                items: Drink.values.map((Drink value) {
                  return DropdownMenuItem<Drink>(
                    value: value,
                    child: Text(value.displayName),
                  );
                }).toList(),
              ),
              const SizedBox(width: 16),
              Text(person.numberOfRounds.toString(), style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: isCurrentUser ? null : () {
                  setState(() {
                    _localGroupMembers.removeAt(index);
                  });
                  _saveLocalGroup();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOnlineGroupList() {
    final membersRef = FirebaseDatabase.instance.ref('groups/$_activeGroupId/members');
    return StreamBuilder<DatabaseEvent>(
      stream: membersRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Center(child: Text('This group has no members yet.'));
        }

        final members = (snapshot.data!.snapshot.value as Map<dynamic, dynamic>).keys.toList();

        return ListView.builder(
          itemCount: members.length,
          itemBuilder: (context, index) {
            final uid = members[index];
            return OnlineMemberTile(uid: uid);
          },
        );
      },
    );
  }

  Widget _buildResultOverlay() {
    final displayName = _selectedOnlineUserName ?? _selectedPerson?.name ?? "";

    return GestureDetector(
      onTap: _hideResult,
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.white, decoration: TextDecoration.none),
              ),
              const SizedBox(height: 16),
              const Text(
                'moet bier gaan halen',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.normal, color: Colors.white, decoration: TextDecoration.none),
              ),
            ],
          ),
        ),
      ),
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
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () => Navigator.of(context).pop(nameController.text),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      setState(() {
        _localGroupMembers.add(Person(name: newName));
      });
      await _saveLocalGroup();
    }
  }

  Future<void> _showQrCodeDialog() async {
    if (_activeGroupId == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_activeGroupName),
          content: SizedBox(
            width: 250,
            height: 250,
            child: Center(
              child: QrImageView(
                data: _activeGroupId!,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}

class OnlineMemberTile extends StatelessWidget {
  final String uid;
  const OnlineMemberTile({Key? key, required this.uid}) : super(key: key);

  // Helper to get an icon for a drink
  IconData _getDrinkIcon(Drink drink) {
    switch (drink) {
      case Drink.beer:
        return Icons.sports_bar;
      case Drink.whiskey:
        return Icons.local_bar;
      case Drink.wine:
        return Icons.wine_bar;
      case Drink.cola:
        return Icons.local_cafe;
      default:
        return Icons.emoji_food_beverage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRef = FirebaseDatabase.instance.ref('users/$uid');
    return StreamBuilder<DatabaseEvent>(
      stream: userRef.onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const ListTile(title: Text('Loading user...'));
        }
        final userData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        final firstName = userData['firstName'] ?? 'Unknown';
        final lastNameInitial = userData['lastNameInitial'] ?? '';

        final displayName = '$firstName ${lastNameInitial.isNotEmpty ? lastNameInitial + "." : ""}'.trim();

        final preferredDrinkString = userData['preferredDrink'] as String? ?? 'Drink.beer';
        final preferredDrink = Drink.values.firstWhere(
              (e) => e.toString() == preferredDrinkString,
          orElse: () => Drink.beer,
        );

        final numberOfRounds = userData['numberOfRounds'] as int? ?? 0;

        return ListTile(
          leading: Icon(_getDrinkIcon(preferredDrink), color: Theme.of(context).colorScheme.primary),
          title: Text(displayName),
          subtitle: Text(preferredDrink.displayName),
          trailing: Text(
            numberOfRounds.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}
