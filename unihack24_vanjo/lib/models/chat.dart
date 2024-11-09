// models/chat.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'message.dart';

class Chat {
  final String chatId;
  final List<Message> messages;
  final List<String> participants;
  final Timestamp lastUpdated;

  Chat({
    required this.chatId,
    required this.messages,
    required this.participants,
    required this.lastUpdated,
  });

  // Creates a Chat object from a Map
  factory Chat.fromMap(String id, Map<String, dynamic> map) {
    return Chat(
      chatId: id,
      messages: [], // Messages are fetched separately
      participants: List<String>.from(map['participants'] ?? []),
      lastUpdated: map['lastUpdated'] ?? Timestamp.now(),
    );
  }

  // Converts Chat object to a Map
  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastUpdated': lastUpdated,
    };
  }
}
