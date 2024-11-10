// cycle.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Cycle {
  final List<String> userIds;
  final DateTime createdAt;
  final String status; // e.g., 'pending', 'accepted'

  Cycle({
    required this.userIds,
    required this.createdAt,
    this.status = 'pending',
  });

  /// Creates a Cycle object from a Firestore document.
  factory Cycle.fromMap(Map<String, dynamic> map) {
    return Cycle(
      userIds: List<String>.from(map['user_ids'] ?? []),
      createdAt: (map['created_at'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
    );
  }

  /// Creates a Cycle object from a list of user IDs.
  factory Cycle.fromList(List<String> userIds) {
    return Cycle(
      userIds: userIds,
      createdAt: DateTime.now(),
      status: 'pending',
    );
  }

  /// Converts a Cycle object to a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'user_ids': userIds,
      'created_at': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }
}
