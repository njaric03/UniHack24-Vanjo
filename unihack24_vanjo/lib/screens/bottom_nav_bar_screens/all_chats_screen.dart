// ignore_for_file: avoid_print

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
        body: StreamBuilder<QuerySnapshot>(
      stream: messagingService.getUserChatsStream(userId),
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
            final otherParticipantId = messagingService.getOtherParticipantId(
                List<String>.from(chatData['participants'] ?? []), userId);

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

                return FutureBuilder<Map<String, String>>(
                  future: _getParticipantName(otherParticipantId),
                  builder: (context, namesSnapshot) {
                    final firstName =
                        namesSnapshot.data?['first_name'] ?? 'Loading';
                    final lastName = namesSnapshot.data?['last_name'] ?? '...';
                    final initials =
                        '${firstName[0].toUpperCase()}${lastName[0].toUpperCase()}';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          initials,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$firstName $lastName',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
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
                      subtitle: Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
    ));
  }

  Future<Map<String, String>> _getParticipantName(String participantId) async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(participantId).get();
      final userData = userDoc.data();
      if (userData != null &&
          userData.containsKey('first_name') &&
          userData.containsKey('last_name')) {
        return {
          'first_name': userData['first_name'],
          'last_name': userData['last_name'],
        };
      }
      return {
        'first_name': 'Unknown',
        'last_name': 'User',
      };
    } catch (e) {
      print('Error getting participant name: $e');
      return {
        'first_name': 'Unknown',
        'last_name': 'User',
      };
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final messageTime = timestamp.toDate();
    final difference = now.difference(messageTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${messageTime.day}/${messageTime.month}/${messageTime.year}';
    }
  }
}
