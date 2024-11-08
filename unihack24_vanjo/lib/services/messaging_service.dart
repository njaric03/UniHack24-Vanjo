import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import '../models/chat.dart';

class MessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to send a new message
  Future<void> sendMessage(String chatId, Message message) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'messages': FieldValue.arrayUnion([message.toMap()]),
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // Method to receive messages as a stream
  Stream<List<Message>> getMessagesStream(String chatId) {
    return _firestore.collection('chats').doc(chatId).snapshots().map((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final messages = data['messages'] as List<dynamic>;
        return messages
            .map((message) => Message.fromMap(message as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    });
  }

  // Method to get chat details
  Future<Chat?> getChat(String chatId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('chats').doc(chatId).get();
      if (doc.exists) {
        return Chat.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting chat: $e');
      return null;
    }
  }
}
