import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  /// Helper to count collection documents
  Stream<int> countStream(String collection) {
    return FirebaseFirestore.instance
        .collection(collection)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Count requests by status
  Stream<int> countRequestsByStatus(String status) {
    return FirebaseFirestore.instance
        .collection('requests')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Admin Dashboard Overview",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          /// USERS
          StreamBuilder<int>(
            stream: countStream('users'),
            builder: (context, snapshot) {
              return _buildCard(
                title: "Total Users",
                value: snapshot.data ?? 0,
                icon: Icons.people,
                color: Colors.blue,
              );
            },
          ),

          const SizedBox(height: 10),

          /// PROVIDERS
          StreamBuilder<int>(
            stream: countStream('providers'),
            builder: (context, snapshot) {
              return _buildCard(
                title: "Total Providers",
                value: snapshot.data ?? 0,
                icon: Icons.build,
                color: Colors.green,
              );
            },
          ),

          const SizedBox(height: 10),

          /// REQUESTS
          StreamBuilder<int>(
            stream: countStream('requests'),
            builder: (context, snapshot) {
              return _buildCard(
                title: "Total Requests",
                value: snapshot.data ?? 0,
                icon: Icons.work,
                color: Colors.orange,
              );
            },
          ),

          const SizedBox(height: 10),

          /// PENDING REQUESTS
          StreamBuilder<int>(
            stream: countRequestsByStatus("pending"),
            builder: (context, snapshot) {
              return _buildCard(
                title: "Pending Requests",
                value: snapshot.data ?? 0,
                icon: Icons.pending,
                color: Colors.red,
              );
            },
          ),

          const SizedBox(height: 10),

          /// COMPLETED REQUESTS
          StreamBuilder<int>(
            stream: countRequestsByStatus("completed"),
            builder: (context, snapshot) {
              return _buildCard(
                title: "Completed Requests",
                value: snapshot.data ?? 0,
                icon: Icons.check_circle,
                color: Colors.green,
              );
            },
          ),

          const SizedBox(height: 10),

          /// CANCELLED REQUESTS
          StreamBuilder<int>(
            stream: countRequestsByStatus("cancelled"),
            builder: (context, snapshot) {
              return _buildCard(
                title: "Cancelled Requests",
                value: snapshot.data ?? 0,
                icon: Icons.cancel,
                color: Colors.grey,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title),
        trailing: Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}


