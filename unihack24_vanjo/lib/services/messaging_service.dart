// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import '../models/chat.dart';

class MessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to create a new chat
  Future<String?> createChat(String participant1, String participant2) async {
    try {
      // Check if chat exists with either participant
      QuerySnapshot existingChats = await _firestore
          .collection('chats')
          .where('participants', arrayContainsAny: [participant1]).get();

      // Find chat that contains both participants
      for (var doc in existingChats.docs) {
        List<String> participants = List<String>.from(doc['participants']);
        if (participants.contains(participant1) &&
            participants.contains(participant2)) {
          return doc.id;
        }
      }

      // If no chat exists, create a new one
      DocumentReference chatRef = await _firestore.collection('chats').add({
        'participants': [participant1, participant2],
        'createdAt': FieldValue.serverTimestamp(),
      });

      return chatRef.id;
    } catch (e) {
      print('Error creating chat: $e');
      return null;
    }
  }

  // Method to get user's chats stream
  Stream<QuerySnapshot> getUserChatsStream(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print('Found ${snapshot.docs.length} chats'); // Debug print
      for (var doc in snapshot.docs) {
        print(
            'Chat ${doc.id} participants: ${(doc.data())['participants']}'); // Debug data
      }
      return snapshot;
    });
  }

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

  // Helper method to get the other participant's ID
  String getOtherParticipantId(
      List<dynamic> participants, String currentUserId) {
    return participants
        .firstWhere(
          (id) => id.toString() != currentUserId,
          orElse: () => '',
        )
        .toString();
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
          participants: List<String>.from(data['participants']),
        );
      }
      return null;
    } catch (e) {
      print('Error getting chat: $e');
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
