import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class NameListPage extends StatefulWidget {
  const NameListPage({Key? key}) : super(key: key);

  @override
  State<NameListPage> createState() => _NameListPageState();
}

class _NameListPageState extends State<NameListPage> {
  final List<String> _names = [];

  bool _isShowingResult = false;
  String _selectedName = '';

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _pickRandomName() {
    if (_names.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voeg eerst wat namen toe.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final random = Random();
    final index = random.nextInt(_names.length);
    final selectedName = _names[index];

    setState(() {
      _selectedName = selectedName;
      _isShowingResult = true;
    });
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
          appBar: AppBar(title: const Text('Bier halers')),
          body: ListView.builder(
            itemCount: _names.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_names[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    setState(() {
                      _names.removeAt(index);
                    });
                  },
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

        if (_isShowingResult)
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
                        _selectedName,
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
        _names.add(newName);
      });
    }
  }
}
