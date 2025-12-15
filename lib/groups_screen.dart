import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:wie_moet_er_bier_gaan_halen/qr_scanner_screen.dart';

// A simple data model for a group
class Group {
  final String id;
  final String name;
  final int lastUpdated;

  Group({required this.id, required this.name, required this.lastUpdated});
}

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Group'),
          content: TextField(
            controller: _groupNameController,
            decoration: const InputDecoration(hintText: "Group Name"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                _groupNameController.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                _createGroup();
                _groupNameController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _createGroup() async {
    final user = _currentUser;
    if (user == null || _groupNameController.text.trim().isEmpty) {
      return;
    }

    final DatabaseReference groupsRef = FirebaseDatabase.instance.ref('groups');
    final newGroupRef = groupsRef.push();
    final groupId = newGroupRef.key;

    if (groupId == null) return; // Could not generate key

    await newGroupRef.set({
      'name': _groupNameController.text.trim(),
      'createdBy': user.uid,
      'members': {
        user.uid: true,
      },
      'lastUpdated': ServerValue.timestamp, // Add timestamp on creation
    });

    // Also add the group to the user's list of groups
    final DatabaseReference userGroupsRef =
        FirebaseDatabase.instance.ref('users/${user.uid}/groups');
    await userGroupsRef.update({
      groupId: true,
    });
  }

  Stream<DatabaseEvent> _getGroupsStream() {
    if (_currentUser == null) {
      return const Stream.empty();
    }
    return FirebaseDatabase.instance
        .ref('users/${_currentUser!.uid}/groups')
        .onValue;
  }

  // New method to fetch all group details and sort them
  Future<List<Group>> _fetchAndSortGroups(List<dynamic> groupIds) async {
    List<Future<Group?>> futures = groupIds.map((groupId) async {
      final groupSnapshot = await FirebaseDatabase.instance.ref('groups/$groupId').get();
      if (groupSnapshot.exists) {
        final groupData = groupSnapshot.value as Map<dynamic, dynamic>;
        return Group(
          id: groupId,
          name: groupData['name'] ?? 'Unnamed Group',
          lastUpdated: groupData['lastUpdated'] as int? ?? 0,
        );
      }
      return null;
    }).toList();

    final results = await Future.wait(futures);
    final groups = results.where((g) => g != null).cast<Group>().toList();

    // Sort the groups by lastUpdated, descending (most recent first)
    groups.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

    return groups;
  }

  void _navigateToScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const QrScannerScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _navigateToScanner,
            tooltip: 'Join Group via QR',
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _getGroupsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            // Show only the local group if there are no online groups
            return _buildGroupList(const []);
          }

          final groupsData =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final groupIds = groupsData.keys.toList();

          // Use a FutureBuilder to fetch, sort, and then build the list
          return FutureBuilder<List<Group>>(
            future: _fetchAndSortGroups(groupIds),
            builder: (context, groupSnapshot) {
              if (groupSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!groupSnapshot.hasData || groupSnapshot.data!.isEmpty) {
                return _buildGroupList(const []);
              }
              return _buildGroupList(groupSnapshot.data!);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateGroupDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGroupList(List<Group> sortedGroups) {
    return ListView.builder(
      itemCount: sortedGroups.length + 1, // +1 for the local group
      itemBuilder: (context, index) {
        if (index == 0) {
          // The first item is always the local group
          return Card(
            child: ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('Local Group (On this device)'),
              onTap: () {
                Navigator.of(context).pop(null);
              },
            ),
          );
        }
        final group = sortedGroups[index - 1];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.group),
            title: Text(group.name),
            onTap: () {
              Navigator.of(context).pop(group.id);
            },
          ),
        );
      },
    );
  }
}
