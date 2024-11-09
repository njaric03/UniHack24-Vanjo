class Cycle {
  final List<String> userIds;

  Cycle({required this.userIds});

  // Create a Cycle object from a Firestore document
  factory Cycle.fromMap(Map<String, dynamic> map) {
    return Cycle(
      userIds: List<String>.from(map['user_ids'] ?? []),
    );
  }

  // Create a Cycle object from a list of user IDs
  factory Cycle.fromList(List<String> userIds) {
    return Cycle(userIds: userIds);
  }

  // Convert a Cycle object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'user_ids': userIds,
    };
  }
}
