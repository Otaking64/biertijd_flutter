import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class GroupJoiner {
  static Future<String?> joinGroup(BuildContext context, String groupId) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(translations.mustBeLoggedInToJoinGroupError), backgroundColor: Colors.red),
        );
      }
      return null;
    }

    final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

    // Check if the group exists
    final groupSnapshot = await dbRef.child('groups/$groupId').get();
    if (!groupSnapshot.exists) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(translations.groupDoesNotExistError), backgroundColor: Colors.red),
        );
      }
      return null;
    }

    await dbRef.child('groups/$groupId/members/${currentUser.uid}').set(true);
    await dbRef.child('users/${currentUser.uid}/groups/$groupId').set(true);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translations.successfullyJoinedGroupMessage)),
      );
    }
    return groupId;
  }
}

