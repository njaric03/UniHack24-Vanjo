// firebase_service.dart

// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unihack24_vanjo/models/cycle.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String cyclesCollection = 'cycles';

  /// Adds a new cycle to Firestore.
  Future<void> addCycle(Cycle cycle) async {
    try {
      await _firestore.collection(cyclesCollection).add(cycle.toMap());
      print('Cycle added successfully');
    } catch (e) {
      print('Failed to add cycle: $e');
      rethrow;
    }
  }

  /// Retrieves all cycles where the user ID is present and status is 'pending'.
  Stream<List<Cycle>> getUserCycles(String userId) {
    return _firestore
        .collection(cyclesCollection)
        .where('user_ids', arrayContains: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            // ignore: unnecessary_cast
            .map((doc) => Cycle.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Updates the status of a cycle to 'accepted'.
  Future<void> acceptCycle(String cycleId) async {
    try {
      await _firestore.collection(cyclesCollection).doc(cycleId).update({
        'status': 'accepted',
      });
      print('Cycle status updated to accepted');
    } catch (e) {
      print('Failed to update cycle status: $e');
      rethrow;
    }
  }

  /// Updates the status of a cycle to 'rejected'.
  Future<void> rejectCycle(String cycleId) async {
    try {
      await _firestore.collection(cyclesCollection).doc(cycleId).update({
        'status': 'rejected',
      });
      print('Cycle status updated to rejected');
    } catch (e) {
      print('Failed to update cycle status: $e');
      rethrow;
    }
  }
}
