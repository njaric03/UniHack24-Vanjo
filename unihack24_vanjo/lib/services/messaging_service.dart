// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import '../models/chat.dart';

class MessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to send a new message
  Future<void> sendMessage(String chatId, Message message) async {
    try {
      // Create a new document in the messages subcollection
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toMap());
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // Method to receive messages as a stream
  Stream<List<Message>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
    });
  }

  // Method to get chat details
  Future<Chat?> getChat(String chatId) async {
    try {
      DocumentSnapshot chatDoc =
          await _firestore.collection('chats').doc(chatId).get();

      if (chatDoc.exists) {
        // Get the most recent messages
        QuerySnapshot messagesSnapshot = await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(50) // Adjust limit based on your needs
            .get();

        List<Message> messages = messagesSnapshot.docs
            .map((doc) => Message.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        return Chat(
          chatId: chatId,
          messages: messages,
          participant1: chatDoc.get('participant1'),
          participant2: chatDoc.get('participant2'),
        );
      }
      return null;
    } catch (e) {
      print('Error getting chat: $e');
      return null;
    }
  }

  // Method to fetch chats for a user
  Future<List<Chat>> getUserChats(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        List<dynamic> chatRefs = userDoc['chats'];
        List<Chat> chats = [];
        for (var chatRef in chatRefs) {
          DocumentSnapshot chatDoc = await (chatRef as DocumentReference).get();
          if (chatDoc.exists) {
            chats.add(Chat.fromMap(
                chatDoc.id, chatDoc.data() as Map<String, dynamic>));
          }
        }
        return chats;
      }
      return [];
    } catch (e) {
      print('Error fetching user chats: $e');
      return [];
    }
  }

  // Method to paginate messages
  Future<List<Message>> getPaginatedMessages(
      String chatId, DocumentSnapshot? lastMessageDoc, int limit) async {
    try {
      Query query = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (lastMessageDoc != null) {
        query = query.startAfterDocument(lastMessageDoc);
      }

      QuerySnapshot snapshot = await query.get();

      return snapshot.docs
          .map((doc) => Message.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting paginated messages: $e');
      return [];
    }
  }
}
