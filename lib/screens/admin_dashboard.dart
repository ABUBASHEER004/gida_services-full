import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart';
import 'admin_chat_viewer_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int currentTab = 0;

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

Future<void> activateUser(String id) async {
  await _firestore.collection('users').doc(id).set({
    'status': 'active',
    'blocked': false,
  }, SetOptions(merge: true));
}

Future<void> deactivateUser(String id) async {
  await _firestore.collection('users').doc(id).set({
    'status': 'inactive',
  }, SetOptions(merge: true));
}

Future<void> blockUser(String id) async {
  await _firestore.collection('users').doc(id).set({
    'status': 'blocked',
    'blocked': true,
  }, SetOptions(merge: true));
}

Future<void> deleteUser(String id) async {
  await _firestore.collection('users').doc(id).delete();
}

Future<void> activateProvider(String id) async {
  await _firestore.collection('providers').doc(id).set({
    'status': 'active',
    'isSuspended': false,
  }, SetOptions(merge: true));
}

Future<void> deactivateProvider(String id) async {
  await _firestore.collection('providers').doc(id).set({
    'status': 'inactive',
  }, SetOptions(merge: true));
}

Future<void> blockProvider(String id) async {
  await _firestore.collection('providers').doc(id).set({
    'status': 'blocked',
    'isSuspended': true,
  }, SetOptions(merge: true));
}

Future<void> deleteProvider(String id) async {
  await _firestore.collection('providers').doc(id).delete();
}

  // =========================
  // SAFE DOUBLE PARSER
  // =========================
  double toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v.toDouble();
    if (v is double) return v;
    return double.tryParse(v.toString()) ?? 0;
  }

  // =========================
  // CONFIRM PAYMENT
  // =========================
  Future<void> confirmPayment(String id) async {
    await _firestore.collection('requests').doc(id).update({
      'commissionPaid': true,
      'commissionPaidAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('requests').doc(id).collection('history').add({
      'action': 'Admin confirmed payment',
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Confirmed")),
    );
  }



  // =========================
  // STAT WIDGET
  // =========================
  Widget stat(String title, num value, Color color) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color),
        title: Text(title),
        trailing: Text(value.toString()),
      ),
    );
  }

  // =========================
  // SUPPORT CHATS TAB (FIXED)
  // =========================
  Widget supportChatsTab() {
  return StreamBuilder<QuerySnapshot>(
    stream: _firestore.collection('chats').snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final supportChats = snapshot.data!.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final participants = List<String>.from(data['participants'] ?? []);

        // ONLY admin chats
        return participants.contains('ADMIN_SUPPORT');
      }).toList();

      if (supportChats.isEmpty) {
        return const Center(child: Text("No support chats yet"));
      }

      return ListView.builder(
        itemCount: supportChats.length,
        itemBuilder: (context, index) {
          final doc = supportChats[index];
          final data = doc.data() as Map<String, dynamic>;

          final participants =
              List<String>.from(data['participants'] ?? []);
final chatType = data['type'] ?? '';

final otherParticipant = participants.firstWhere(
  (id) => id != 'ADMIN_SUPPORT',
  orElse: () => 'Unknown',
);

return ListTile(
  leading: const Icon(Icons.support_agent),
  title: Text(
    chatType == 'provider_admin'
        ? 'Provider Support'
        : 'User Support',
  ),
  subtitle: Text(
    data['lastMessage'] ?? 'No messages',
  ),
  trailing: const Icon(Icons.arrow_forward_ios),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminChatViewerScreen(
          requestId: '',
          userId: otherParticipant,
          providerId: '',
        ),
      ),
    );
  },
);
 },
      );
    },
  );
}
  // =========================
  // STATS (MERGED OLD + NEW)
  // =========================
  Widget buildStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('requests').snapshots(),
      builder: (context, reqSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('users').snapshots(),
          builder: (context, userSnap) {
            return StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('providers').snapshots(),
              builder: (context, proSnap) {
                if (!reqSnap.hasData || !userSnap.hasData || !proSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = userSnap.data!.docs.length;
                final providers = proSnap.data!.docs.length;
                final requests = reqSnap.data!.docs.length;

                int onlineProviders = 0;
                for (var p in proSnap.data!.docs) {
                  final data = p.data() as Map<String, dynamic>;
                  if (data['isOnline'] == true) onlineProviders++;
                }

                double revenue = 0;
                for (var d in reqSnap.data!.docs) {
                  final data = d.data() as Map<String, dynamic>;
                  revenue += toDouble(data['commission']);
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    stat("Users", users, Colors.blue),
                    stat("Providers", providers, Colors.green),
                    stat("Online Providers", onlineProviders, Colors.teal),
                    stat("Requests", requests, Colors.orange),
                    stat("Revenue", revenue.toInt(), Colors.purple),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // =========================
  // USERS (OLD)
  // =========================
  Widget usersTab() {
  return StreamBuilder<QuerySnapshot>(
    stream: _firestore.collection('users').snapshots(),
    builder: (context, snap) {
      if (!snap.hasData) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return ListView.builder(
        itemCount: snap.data!.docs.length,
        itemBuilder: (context, index) {
          final doc = snap.data!.docs[index];
          final data = doc.data() as Map<String, dynamic>;

          final status =
              data['status']?.toString() ?? 'active';

          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] ?? 'No Name',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    data['email'] ?? 'No Email',
                  ),

                  const SizedBox(height: 6),

                  Text("Status: $status"),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            activateUser(doc.id),
                        child: const Text("Activate"),
                      ),

                      ElevatedButton(
                        onPressed: () =>
                            deactivateUser(doc.id),
                        child: const Text("Deactivate"),
                      ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.orange,
                        ),
                        onPressed: () =>
                            blockUser(doc.id),
                        child: const Text("Block"),
                      ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red,
                        ),
                        onPressed: () =>
                            deleteUser(doc.id),
                        child: const Text("Delete"),
                      ),
                    ],
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
  // =========================
  // PROVIDERS (OLD)
  // =========================
  Widget providersTab() {
  return StreamBuilder<QuerySnapshot>(
    stream: _firestore.collection('providers').snapshots(),
    builder: (context, snap) {
      if (!snap.hasData) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return ListView.builder(
        itemCount: snap.data!.docs.length,
        itemBuilder: (context, index) {
          final doc = snap.data!.docs[index];
          final data = doc.data() as Map<String, dynamic>;

          final isOnline =
              data['isOnline'] == true;

          final status =
              data['status']?.toString() ?? 'active';

          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          isOnline
                              ? Colors.green
                              : Colors.red,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      data['name'] ?? 'No Name',
                    ),
                    subtitle: Text(
                      data['service'] ??
                          'No Service',
                    ),
                  ),

                  Text("Status: $status"),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            activateProvider(
                                doc.id),
                        child: const Text(
                          "Activate",
                        ),
                      ),

                      ElevatedButton(
                        onPressed: () =>
                            deactivateProvider(
                                doc.id),
                        child: const Text(
                          "Deactivate",
                        ),
                      ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.orange,
                        ),
                        onPressed: () =>
                            blockProvider(
                                doc.id),
                        child: const Text(
                          "Block",
                        ),
                      ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red,
                        ),
                        onPressed: () =>
                            deleteProvider(
                                doc.id),
                        child: const Text(
                          "Delete",
                        ),
                      ),
                    ],
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
  // =========================
  // REQUESTS (FULL OLD FEATURED)
  // =========================
  Widget requestsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('requests')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snap.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final id = doc.id;

            final amount = toDouble(data['amount']);
            final commission = toDouble(data['commission']);
            final earning = toDouble(data['providerEarning']);
            final paid = data['commissionPaid'] == true;

            final userId = data['userId'] ?? '';
            final providerId = data['providerId'] ?? '';

            return Card(
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['category'] ?? 'No Category',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("Amount: ₦$amount"),
                    Text("Commission: ₦$commission"),
                    Text("Provider Earns: ₦$earning"),

                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: paid ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        paid ? "PAID" : "NOT PAID",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: paid ? null : () => confirmPayment(id),
                      child: const Text("Confirm Payment"),
                    ),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.chat),
                      label: const Text("View Chat"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminChatViewerScreen(
                              requestId: id,
                              userId: userId,
                              providerId: providerId,
                            ),
                          ),
                        );
                      },
                    ),

                 
                

                    const SizedBox(height: 10),

                    const Text(
                      "History",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('requests')
                          .doc(id)
                          .collection('history')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, hSnap) {
                        if (!hSnap.hasData || hSnap.data!.docs.isEmpty) {
                          return const Text("No history yet");
                        }

                        return Column(
                          children: hSnap.data!.docs.map((h) {
                            final d = h.data() as Map<String, dynamic>;
                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.history),
                              title: Text(d['action'] ?? ''),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final pages = [
      buildStats(),
      usersTab(),
      providersTab(),
      requestsTab(),
      supportChatsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: IndexedStack(
        index: currentTab,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        onTap: (i) => setState(() => currentTab = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Stats"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: "Providers"),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Requests"),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: "Support"),
        ],
      ),
    );
  }
}


