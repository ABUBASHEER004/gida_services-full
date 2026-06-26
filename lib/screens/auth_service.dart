import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ==========================
  /// LOGIN (FIXED ROLE SYSTEM)
  /// ==========================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    final userRef = _firestore.collection('users').doc(uid);
    final providerRef = _firestore.collection('providers').doc(uid);

    final userDoc = await userRef.get();
    final providerDoc = await providerRef.get();

    Map<String, dynamic> data = {};

    /// ==========================
    /// PRIORITY: USERS COLLECTION
    /// ==========================
    if (userDoc.exists) {
      data = userDoc.data()!;
    }

    /// ==========================
    /// PROVIDER FALLBACK
    /// ==========================
    else if (providerDoc.exists) {
      data = providerDoc.data()!;
      data['role'] = 'provider';
    }

    /// ==========================
    /// AUTO CREATE PROFILE IF MISSING
    /// ==========================
    else {
      final isAdmin = email.trim().toLowerCase() == "abubasheer004@gmail.com";

      data = {
        'uid': uid,
        'name': email.split('@')[0],
        'email': email,
        'role': isAdmin ? 'admin' : 'user',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await userRef.set(data);
    }

    /// ==========================
    /// NORMALIZE ROLE (VERY IMPORTANT)
    /// ==========================
    data['role'] = (data['role'] ?? 'user')
        .toString()
        .trim()
        .toLowerCase();

    return data;
  }

  /// ==========================
  /// USER REGISTER
  /// ==========================
  static Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.toLowerCase(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// ==========================
  /// PROVIDER REGISTER
  /// ==========================
  static Future<void> registerProvider({
    required String name,
    required String email,
    required String password,
    required String service,
    required String phone,
    required String area,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    await _firestore.collection('providers').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'service': service,
      'phone': phone,
      'area': area,
      'role': 'provider',
      'isOnline': false,
      'rating': 5.0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    /// ALSO ADD TO USERS (IMPORTANT FOR ADMIN SYSTEM)
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'role': 'provider',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// ==========================
  /// LOGOUT
  /// ==========================
  static Future<void> logout() async {
    await _auth.signOut();
  }

  /// ==========================
  /// CURRENT USER
  /// ==========================
  static User? get currentUser => _auth.currentUser;

  /// ==========================
  /// UPDATE PROVIDER STATUS
  /// ==========================
  static Future<void> updateProviderStatus(
    String providerId,
    bool isOnline,
  ) async {
    await _firestore.collection('providers').doc(providerId).set({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

