import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/messaging_service.dart';
import 'chat_screen.dart';

class AllChatsScreen extends StatelessWidget {
  final String userId;
  final MessagingService messagingService = MessagingService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AllChatsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chats')
            .where('participants', arrayContains: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No chats available."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final chatDoc = snapshot.data!.docs[index];
              final chatData = chatDoc.data() as Map<String, dynamic>;

              // Get the other participant's ID
              final otherParticipantId =
                  (chatData['participants'] as List<dynamic>)
                      .firstWhere((id) => id != userId);

              return StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chats')
                    .doc(chatDoc.id)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .limit(1)
                    .snapshots(),
                builder: (context, messageSnapshot) {
                  String lastMessage = "No messages yet";
                  String timestamp = "";

                  if (messageSnapshot.hasData &&
                      messageSnapshot.data!.docs.isNotEmpty) {
                    final lastMessageData = messageSnapshot.data!.docs.first
                        .data() as Map<String, dynamic>;
                    lastMessage = lastMessageData['text'] as String;
                    final Timestamp ts =
                        lastMessageData['timestamp'] as Timestamp;
                    timestamp = _formatTimestamp(ts);
                  }

                  return FutureBuilder<String>(
                    future: _getParticipantName(otherParticipantId),
                    builder: (context, namesSnapshot) {
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(namesSnapshot.data ?? 'Loading...'),
                        subtitle: Row(
                          children: [
                            Expanded(
                              child: Text(
                                lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (timestamp.isNotEmpty)
                              Text(
                                timestamp,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                chatId: chatDoc.id,
                                currentUserId: userId,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<String> _getParticipantName(String participantId) async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(participantId).get();
      final userData = userDoc.data();
      if (userData != null && userData.containsKey('displayName')) {
        return userData['displayName'];
      }
      return participantId; // Fallback to ID if no display name
    } catch (e) {
      return participantId; // Fallback to ID on error
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final messageTime = timestamp.toDate();

    if (now.difference(messageTime).inDays == 0) {
      // Today - show time
      return '${messageTime.hour}:${messageTime.minute.toString().padLeft(2, '0')}';
    } else if (now.difference(messageTime).inDays == 1) {
      return 'Yesterday';
    } else {
      // Show date
      return '${messageTime.day}/${messageTime.month}/${messageTime.year}';
    }
  }
}
