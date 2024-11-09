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
              final otherParticipantId =
                  messagingService.getOtherParticipantId(chatData, userId);

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
                      final username = namesSnapshot.data ?? 'Loading...';

                      return Dismissible(
                        key: Key(chatDoc.id),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm"),
                                content: Text(
                                    "Are you sure you want to delete chat with $username?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text("CANCEL"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text("DELETE"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) {
                          messagingService.deleteChat(chatDoc.id);
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              username.isNotEmpty
                                  ? username[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(username),
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
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to new chat screen or show user selection dialog
          _showNewChatDialog(context);
        },
        child: const Icon(Icons.chat),
      ),
    );
  }

  Future<String> _getParticipantName(String participantId) async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(participantId).get();
      final userData = userDoc.data();
      if (userData != null && userData.containsKey('username')) {
        return userData['username'];
      }
      return participantId;
    } catch (e) {
      print('Error getting participant name: $e');
      return participantId;
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
                  title: Text(userData['username'] ?? 'Unknown User'),
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
