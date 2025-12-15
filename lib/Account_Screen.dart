import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  final Future<void> Function() onResetCounters;

  const AccountScreen({Key? key, required this.onResetCounters}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final bool? shouldReset = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Reset Counters'),
                  content: const Text('Are you sure you want to reset all beer counters?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    ElevatedButton(
                      child: const Text('Reset'),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                );
              },
            );

            if (shouldReset == true) {
              await onResetCounters();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Counters have been reset.'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Reset All Beer Counters'),
        ),
      ),
    );
  }
}
