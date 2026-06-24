import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'user_profile_screen.dart';
import 'provider_profile_screen.dart';
import 'admin_profile_screen.dart';

class ProfileRouter extends StatelessWidget {
  const ProfileRouter({super.key});

  /// 🔍 SAFE ROLE RESOLUTION
  Future<String> getRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return 'user';

    final uid = user.uid;

    try {
      /// 🔎 1. USERS COLLECTION (PRIMARY SOURCE)
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        final role = (data?['role'] ?? '')
            .toString()
            .trim()
            .toLowerCase();

        if (role.isNotEmpty) return role;
      }

      /// 🔎 2. PROVIDERS COLLECTION
      final providerDoc = await FirebaseFirestore.instance
          .collection('providers')
          .doc(uid)
          .get();

      if (providerDoc.exists) {
        return 'provider';
      }

      /// 🔎 3. ADMINS COLLECTION
      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(uid)
          .get();

      if (adminDoc.exists) {
        return 'admin';
      }

      /// 🔁 DEFAULT FALLBACK
      return 'user';
    } catch (e) {
      debugPrint("Role fetch error: $e");
      return 'user';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Error loading profile")),
          );
        }

        final role = snapshot.data ?? 'user';

        switch (role) {
          case 'provider':
            return const ProviderProfileScreen();

          case 'admin':
            return const AdminProfileScreen();

          default:
            return const UserProfileScreen();
        }
      },
    );
  }
}
