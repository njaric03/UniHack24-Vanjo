// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unihack24_vanjo/theme/app_theme.dart';
import '../../services/messaging_service.dart';
import '../../models/message.dart';
import '../../models/chat.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String currentUserId;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.currentUserId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final MessagingService _messagingService = MessagingService();

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    // Fetch chat details to find the other participant
    final Chat? chat = await _messagingService.getChat(widget.chatId);
    if (chat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat not found.')),
      );
      return;
    }

    final String receiverId = _messagingService.getOtherParticipantId(
        chat.participants, widget.currentUserId);

    if (receiverId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No receiver found.')),
      );
      return;
    }

    final message = Message(
      senderId: widget.currentUserId,
      receiverId: receiverId,
      text: _messageController.text.trim(),
      timestamp: Timestamp.now(),
    );

    await _messagingService.sendMessage(widget.chatId, message);
    _messageController.clear();
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime messageTime = timestamp.toDate();
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));

    if (messageTime.isAfter(today)) {
      // Today
      return DateFormat('HH:mm').format(messageTime);
    } else if (messageTime.isAfter(yesterday)) {
      // Yesterday
      return 'Yesterday ${DateFormat('HH:mm').format(messageTime)}';
    } else {
      // Before yesterday
      return DateFormat('dd/MM/yyyy HH:mm').format(messageTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messagingService.getMessagesStream(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  reverse: true, // To show the latest messages at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final Message message = messages[index];
                    final bool isMe = message.senderId == widget.currentUserId;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(message.senderId)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Loading...'),
                          );
                        }

                        final Map<String, dynamic>? senderData =
                            userSnapshot.data!.data() as Map<String, dynamic>?;
                        final String senderName = senderData != null
                            ? '${senderData['first_name']} ${senderData['last_name']}'
                            : 'Unknown';

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          child: Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.7,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 12.0),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? AppTheme.primaryColor
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(12.0),
                                    topRight: const Radius.circular(12.0),
                                    bottomLeft: isMe
                                        ? const Radius.circular(12.0)
                                        : Radius.zero,
                                    bottomRight: isMe
                                        ? Radius.zero
                                        : const Radius.circular(12.0),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          senderName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: isMe
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _formatTimestamp(message.timestamp),
                                          style: TextStyle(
                                            color: isMe
                                                ? Colors.white70
                                                : Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      message.text,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            isMe ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
