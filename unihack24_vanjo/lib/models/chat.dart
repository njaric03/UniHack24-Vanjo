// models/chat.dart

// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'message.dart';

class Chat {
  final String chatId;
  final List<Message> messages;
  final List<String> participants;

  Chat({
    required this.chatId,
    required this.messages,
    required this.participants,
  });

  // Creates a Chat object from a Map
  factory Chat.fromMap(String id, Map<String, dynamic> map) {
    return Chat(
      chatId: id,
      messages: [], // Messages are fetched separately
      participants: List<String>.from(map['participants'] ?? []),
    );
  }

  // Converts Chat object to a Map
  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
    };
  }
}
