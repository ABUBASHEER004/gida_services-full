import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  static final _firestore = FirebaseFirestore.instance;

  /// 💳 CREATE PAYMENT RECORD
  static Future<void> createPayment({
    required String userId,
    required String providerId,
    required String requestId,
    required double amount,
  }) async {
    await _firestore.collection('payments').add({
      'userId': userId,
      'providerId': providerId,
      'requestId': requestId,
      'amount': amount,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// ✅ MARK PAYMENT SUCCESSFUL
  static Future<void> confirmPayment(String paymentId) async {
    final paymentDoc =
        await _firestore.collection('payments').doc(paymentId).get();

    final data = paymentDoc.data()!;
    final providerId = data['providerId'];
    final amount = data['amount'];

    // update payment
    await _firestore.collection('payments').doc(paymentId).update({
      'status': 'paid',
    });

    // update provider wallet
    await _firestore.collection('providers').doc(providerId).update({
      'wallet': FieldValue.increment(amount),
      'totalEarnings': FieldValue.increment(amount),
    });
  }
}
