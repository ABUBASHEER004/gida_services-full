import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> toggleProviderStatus(String id, bool value) async {
    await FirebaseFirestore.instance
        .collection('providers')
        .doc(id)
        .set({'isOnline': value}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Users"),
            Tab(text: "Providers"),
            Tab(text: "Requests"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [

          /// USERS
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final users = snapshot.data!.docs;

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final data = users[index].data() as Map<String, dynamic>;

                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(data['name'] ?? 'No Name'),
                    subtitle: Text(data['email'] ?? ''),
                  );
                },
              );
            },
          ),

          /// PROVIDERS
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('providers').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final providers = snapshot.data!.docs;

              return ListView.builder(
                itemCount: providers.length,
                itemBuilder: (context, index) {
                  final doc = providers[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final isOnline = data['isOnline'] ?? false;

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.build),
                      title: Text(data['name'] ?? 'No Name'),
                      subtitle: Text(data['service'] ?? ''),
                      trailing: Switch(
                        value: isOnline,
                        onChanged: (val) {
                          toggleProviderStatus(doc.id, val);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),

          /// REQUESTS
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('requests')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final requests = snapshot.data!.docs;

              return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final data = requests[index].data() as Map<String, dynamic>;

                  return ListTile(
                    leading: const Icon(Icons.work),
                    title: Text(data['category'] ?? 'No Category'),
                    subtitle: Text(data['description'] ?? ''),
                    trailing: Text(data['status'] ?? 'pending'),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
