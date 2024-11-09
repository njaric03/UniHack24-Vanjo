// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import '../models/chat.dart';

class MessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to send a new message
  Future<void> sendMessage(String chatId, Message message) async {
    try {
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

  Stream<QuerySnapshot> getUserChatsStream(String userId) {
    return _firestore
        .collection('chats')
        .where('participant1', isEqualTo: userId)
        .where('participant2', isEqualTo: userId)
        .snapshots();
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
            .limit(50)
            .get();

        List<Message> messages = messagesSnapshot.docs
            .map((doc) => Message.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        Map<String, dynamic> data = chatDoc.data() as Map<String, dynamic>;
        return Chat(
          chatId: chatId,
          messages: messages,
          participant1: data['participant1'],
          participant2: data['participant2'],
        );
      }
      return null;
    } catch (e) {
      print('Error getting chat: $e');
      return null;
    }
  }

  Future<String?> createChat(String participant1, String participant2) async {
    try {
      // Check if chat already exists
      QuerySnapshot existingChats = await _firestore
          .collection('chats')
          .where('participant1', isEqualTo: participant1)
          .where('participant2', isEqualTo: participant2)
          .limit(1)
          .get();

      if (existingChats.docs.isNotEmpty) {
        return existingChats.docs.first.id;
      }

      // Create new chat if none exists
      DocumentReference chatRef = await _firestore.collection('chats').add({
        'participant1': participant1,
        'participant2': participant2,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return chatRef.id;
    } catch (e) {
      print('Error creating chat: $e');
      return null;
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

  // Helper method to get the other participant's ID
  String getOtherParticipantId(
      Map<String, dynamic> chatData, String currentUserId) {
    if (chatData['participant1'] == currentUserId) {
      return chatData['participant2'];
    }
    return chatData['participant1'];
  }

  // Method to delete a chat
  Future<void> deleteChat(String chatId) async {
    try {
      // Delete all messages in the chat
      QuerySnapshot messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      for (var message in messages.docs) {
        await message.reference.delete();
      }

      // Delete the chat document
      await _firestore.collection('chats').doc(chatId).delete();
    } catch (e) {
      print('Error deleting chat: $e');
    }
  }
}
