import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create User
  Future<void> createUser(String uid, String name, String email, String phone) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get Providers
  Stream<QuerySnapshot> getProviders() {
    return _db.collection('providers').snapshots();
  }

  // Create Service Request
  Future<void> createRequest({
    required String userId,
    required String providerId,
    required String description,
  }) async {
    await _db.collection('requests').add({
      'userId': userId,
      'providerId': providerId,
      'description': description,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

