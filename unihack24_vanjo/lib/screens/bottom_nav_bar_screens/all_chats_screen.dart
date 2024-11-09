// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_avatar.dart';
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

                  return FutureBuilder<Map<String, dynamic>>(
                    future: _getParticipantInfo(otherParticipantId),
                    builder: (context, namesSnapshot) {
                      if (namesSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return ListTile(
                          title: Text('Loading...'),
                        );
                      }
                      if (namesSnapshot.hasError) {
                        return ListTile(
                          title: Text('Error loading participant info'),
                        );
                      }

                      final participantData = namesSnapshot.data;
                      final firstName =
                          participantData?['first_name'] ?? 'Loading';
                      final lastName = participantData?['last_name'] ?? '...';
                      final avatarId =
                          participantData?['avatar_id']?.toString() ?? '0';

                      return ListTile(
                        leading: UserAvatar(
                          avatarId: avatarId,
                          firstName: firstName,
                          lastName: lastName,
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
      ),
    );
  }

  Future<Map<String, dynamic>> _getParticipantInfo(String participantId) async {
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
          'avatar_id': userData['avatar_id'],
        };
      }
      return {
        'first_name': 'Unknown',
        'last_name': 'User',
        'avatar_id': 0,
      };
    } catch (e) {
      print('Error getting participant info: $e');
      return {
        'first_name': 'Unknown',
        'last_name': 'User',
        'avatar_id': 0,
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

  void _showNewChatDialog(BuildContext context) async {
    // Get all users except current user
    final usersSnapshot = await _firestore
        .collection('users')
        .where(FieldPath.documentId, isNotEqualTo: userId)
        .get();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Start New Chat'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: usersSnapshot.docs.length,
              itemBuilder: (context, index) {
                final userData = usersSnapshot.docs[index].data();
                final otherUserId = usersSnapshot.docs[index].id;
                return ListTile(
                  title: Text(
                      '${userData['first_name']} ${userData['last_name']}'),
                  onTap: () async {
                    final chatId =
                        await messagingService.createChat(userId, otherUserId);
                    if (chatId != null && context.mounted) {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatId: chatId,
                            currentUserId: userId,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
