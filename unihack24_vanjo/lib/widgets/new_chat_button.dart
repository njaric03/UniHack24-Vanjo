import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/messaging_service.dart';
import '../screens/bottom_nav_bar_screens/chat_screen.dart';

class NewChatButton extends StatelessWidget {
  final String userId;
  final MessagingService messagingService = MessagingService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NewChatButton({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _showNewChatDialog(context);
      },
      child: const Icon(Icons.chat),
    );
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
