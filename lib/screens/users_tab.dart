import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersTab extends StatelessWidget {
  const UsersTab({super.key});

  /// 🔁 Toggle block/unblock user
  Future<void> toggleBlock(String uid, bool current) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'blocked': !current,
    });
  }

  /// 🗑 Delete user
  Future<void> deleteUser(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;

        if (users.isEmpty) {
          return const Center(
            child: Text("No users found"),
          );
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final doc = users[index];
            final data = doc.data() as Map<String, dynamic>;

            final uid = doc.id;
            final name = data['name'] ?? 'No Name';
            final email = data['email'] ?? '';
            final blocked = data['blocked'] ?? false;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: blocked ? Colors.red : Colors.green,
                  child: const Icon(Icons.person, color: Colors.white),
                ),

                title: Text(name),
                subtitle: Text(email),

                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'block') {
                      toggleBlock(uid, blocked);
                    } else if (value == 'delete') {
                      deleteUser(uid);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'block',
                      child: Text(blocked ? "Unblock User" : "Block User"),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text("Delete User"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}


