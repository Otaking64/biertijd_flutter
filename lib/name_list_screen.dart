
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
  Map<Drink, int> _drinkSummary = {};

  Person? _lastSelectedLocalPerson;
  String? _lastSelectedOnlineUid;

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

  Future<List<Person>> _fetchOnlineMemberDetails(Map<dynamic, dynamic> membersData) async {
    List<Person> onlineMembers = [];
    for (var entry in membersData.entries) {
      final uid = entry.key;
      final memberInfo = entry.value;

      int numberOfRounds = 0;
      // Backwards compatibility: memberInfo could be `true` or a map `{ 'numberOfRounds': x }`
      if (memberInfo is Map && memberInfo.containsKey('numberOfRounds')) {
        numberOfRounds = memberInfo['numberOfRounds'] as int;
      }

      final userSnapshot = await FirebaseDatabase.instance.ref('users/$uid').get();
      if (userSnapshot.exists && userSnapshot.value != null) {
        final userData = userSnapshot.value as Map<dynamic, dynamic>;
        final firstName = userData['firstName'] ?? 'Unknown';
        final lastNameInitial = userData['lastNameInitial'] ?? '';

        final preferredDrink = Drink.values.firstWhere(
              (e) => e.toString() == userData['preferredDrink'],
          orElse: () => Drink.beer,
        );

        onlineMembers.add(Person(
          uid: uid,
          name: '$firstName ${lastNameInitial.isNotEmpty ? '$lastNameInitial.' : ''}'.trim(),
          numberOfRounds: numberOfRounds, // Group-specific rounds
          preferredDrink: preferredDrink,
        ));
      }
    }
    return onlineMembers;
  }

  void _pickRandomName() async {
    if (_activeGroupId == null) {
      // --- Local Group: Fair Selection Logic ---
      if (_localGroupMembers.isEmpty) {
        _showErrorSnackbar('Voeg eerst wat namen toe.');
        return;
      }

      final summary = <Drink, int>{};
      for (final person in _localGroupMembers) {
        summary[person.preferredDrink] = (summary[person.preferredDrink] ?? 0) + 1;
      }

      final minRounds = _localGroupMembers.map((p) => p.numberOfRounds).reduce(min);
      var eligiblePeople = _localGroupMembers.where((p) => p.numberOfRounds == minRounds).toList();
      if (eligiblePeople.length > 1 && _lastSelectedLocalPerson != null) {
        eligiblePeople.removeWhere((p) => p.name == _lastSelectedLocalPerson!.name);
      }

      final random = Random();
      final selectedPerson = eligiblePeople[random.nextInt(eligiblePeople.length)];

      setState(() {
        selectedPerson.numberOfRounds++;
        _selectedPerson = selectedPerson;
        _lastSelectedLocalPerson = selectedPerson;
        _selectedOnlineUserName = null;
        _isShowingResult = true;
        _drinkSummary = summary;
      });
      _saveLocalGroup();
      _confettiController.play();

    } else {
      // --- Online Group: Group-Specific Fair Selection Logic ---
      final membersRef = FirebaseDatabase.instance.ref('groups/$_activeGroupId/members');
      final snapshot = await membersRef.get();

      if (!snapshot.exists || snapshot.value == null) {
        _showErrorSnackbar('This group has no members.');
        return;
      }

      final membersData = snapshot.value as Map<dynamic, dynamic>;
      List<Person> onlineMembers = await _fetchOnlineMemberDetails(membersData);

      if (onlineMembers.isEmpty) {
        _showErrorSnackbar('Could not load any member data.');
        return;
      }

      final summary = <Drink, int>{};
      for (final person in onlineMembers) {
        summary[person.preferredDrink] = (summary[person.preferredDrink] ?? 0) + 1;
      }

      final minRounds = onlineMembers.map((p) => p.numberOfRounds).reduce(min);
      var eligibleMembers = onlineMembers.where((p) => p.numberOfRounds == minRounds).toList();
      if (eligibleMembers.length > 1 && _lastSelectedOnlineUid != null) {
        eligibleMembers.removeWhere((p) => p.uid == _lastSelectedOnlineUid);
      }

      final random = Random();
      final winner = eligibleMembers[random.nextInt(eligibleMembers.length)];

      final memberRef = FirebaseDatabase.instance.ref('groups/$_activeGroupId/members/${winner.uid}');
      await memberRef.update({'numberOfRounds': winner.numberOfRounds + 1});
      final groupRef = FirebaseDatabase.instance.ref('groups/$_activeGroupId');
      await groupRef.update({'lastUpdated': ServerValue.timestamp});

      setState(() {
        _selectedPerson = null;
        _selectedOnlineUserName = winner.name;
        _lastSelectedOnlineUid = winner.uid;
        _isShowingResult = true;
        _drinkSummary = summary;
      });
      _confettiController.play();
    }
  }


  void _hideResult() {
    setState(() {
      _isShowingResult = false;
      _drinkSummary = {};
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _resetAllCounters() async {
    if (_activeGroupId == null) {
      // Reset local group
      setState(() {
        for (var person in _localGroupMembers) {
          person.numberOfRounds = 0;
        }
      });
      await _saveLocalGroup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Local counters have been reset.')),
        );
      }
    } else {
      // Reset online group
      final membersRef = FirebaseDatabase.instance.ref('groups/$_activeGroupId/members');
      final snapshot = await membersRef.get();
      if (snapshot.exists) {
        final updates = <String, dynamic>{};
        final members = snapshot.value as Map<dynamic, dynamic>;
        for (final uid in members.keys) {
          updates['$uid/numberOfRounds'] = 0;
        }
        await membersRef.update(updates);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Group counters have been reset.')),
          );
        }
      }
    }
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
          onResetCounters: _resetAllCounters,
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

        final membersData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

        return FutureBuilder<List<Person>>(
          future: _fetchOnlineMemberDetails(membersData),
          builder: (context, membersSnapshot) {
            if (membersSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (membersSnapshot.hasError || !membersSnapshot.hasData || membersSnapshot.data == null) {
              return const Center(child: Text('Could not load member details.'));
            }

            final onlineMembers = membersSnapshot.data!;

            return ListView.builder(
              itemCount: onlineMembers.length,
              itemBuilder: (context, index) {
                final member = onlineMembers[index];
                return ListTile(
                  title: Text(member.name),
                  subtitle: Text('Prefers: ${member.preferredDrink.displayName}'),
                  trailing: Text(member.numberOfRounds.toString(), style: const TextStyle(fontSize: 18)),
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatDrinkSummary() {
    if (_drinkSummary.isEmpty) {
      return '';
    }
    return _drinkSummary.entries
        .map((entry) => '${entry.value}x ${entry.key.displayName}')
        .join('  •  ');
  }

  Widget _buildResultOverlay() {
    final displayName = _selectedOnlineUserName ?? _selectedPerson?.name ?? "";
    final summaryText = _formatDrinkSummary();

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
              const SizedBox(height: 48),
              if (summaryText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    summaryText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.normal, color: Colors.white, decoration: TextDecoration.none),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddNameDialog() async {
    final nameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Naam toevoegen'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Naam'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuleren'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    _localGroupMembers.add(Person(name: name));
                  });
                  _saveLocalGroup();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Toevoegen'),
            ),
          ],
        );
      },
    );
  }

  void _showQrCodeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            width: 250,
            height: 250,
            child: Center(
              child: QrImageView(
                data: _activeGroupId!,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
          ),
        );
      },
    );
  }
}
