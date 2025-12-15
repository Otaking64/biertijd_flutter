
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

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
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groups'),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _getGroupsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return _buildGroupList(const []);
          }

          final groupsData =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final groupIds = groupsData.keys.toList();

          return _buildGroupList(groupIds);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateGroupDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGroupList(List<dynamic> groupIds) {
    return ListView.builder(
      itemCount: groupIds.length + 1, // +1 for the local group
      itemBuilder: (context, index) {
        if (index == 0) {
          // The first item is always the local group
          return Card(
            child: ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('Local Group (On this device)'),
              onTap: () {
                // Pop with null to signify local group
                Navigator.of(context).pop(null);
              },
            ),
          );
        }
        final groupId = groupIds[index - 1];
        return GroupListTile(groupId: groupId);
      },
    );
  }
}

// Helper widget to fetch and display details for a single group
class GroupListTile extends StatelessWidget {
  final String groupId;

  const GroupListTile({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final groupRef = FirebaseDatabase.instance.ref('groups/$groupId');

    return StreamBuilder<DatabaseEvent>(
      stream: groupRef.onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const SizedBox.shrink(); // Don't show if group data is missing
        }

        final groupData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        final groupName = groupData['name'] ?? 'Unnamed Group';

        return Card(
          child: ListTile(
            leading: const Icon(Icons.group),
            title: Text(groupName),
            onTap: () {
              // Pop with the groupId to signify which group was selected
              Navigator.of(context).pop(groupId);
            },
          ),
        );
      },
    );
  }
}
