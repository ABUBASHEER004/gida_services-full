import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gida_services/screens/request_screen.dart';

class ServiceProvidersScreen extends StatelessWidget {
  final String category;

  const ServiceProvidersScreen({
    super.key,
    required this.category,
  });

  /// Normalize text for safe comparison
  String normalize(String value) {
    return value.trim().toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final selectedCategory = normalize(category);

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('providers')
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error loading providers"),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          /// ✅ STRICT FILTER
          final providers = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final service = normalize(data['service'] ?? '');
            return service == selectedCategory;
          }).toList();

          if (providers.isEmpty) {
            return const Center(
              child: Text("No providers available for this category"),
            );
          }

          return ListView.builder(
            itemCount: providers.length,
            itemBuilder: (context, index) {
              final doc = providers[index];
              final data = doc.data() as Map<String, dynamic>;

              final isOnline = data['isOnline'] == true;

              final String locationText =
                 (data['location'] ?? '').toString().trim().isNotEmpty
                   ? data['location']
                      : "Location not available";
                      
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: ListTile(
                  leading: Stack(
                    children: [
                      const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: isOnline ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),

                  title: Text(
                    data['name'] ?? 'No Name',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['service'] ?? ''),

                      Text(
                        isOnline ? "🟢 Available Now" : "⚪ Offline",
                        style: TextStyle(
                          color: isOnline ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      /// 📍 LOCATION ADDED HERE
                      Text(
                        "📍 $locationText",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),

                  trailing: const Icon(Icons.arrow_forward_ios),

                  onTap: () {
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please login to continue"),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RequestScreen(
                          userId: user.uid,
                          providerId: doc.id,
                          providerName: data['name'] ?? '',
                          category: data['service'] ?? category,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
