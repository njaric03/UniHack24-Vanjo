// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final List<Map<String, String>> _conversations = [
    {
      'name': 'Alice',
      'message': 'Hey, how are you?',
    },
    {
      'name': 'Bob',
      'message': 'Are we still on for tomorrow?',
    },
    {
      'name': 'Charlie',
      'message': 'Don\'t forget the meeting at 3 PM.',
    },
  ];

  void _onConversationTap(String name) {
    // Handle conversation tap
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return ListTile(
            title: Text(conversation['name']!),
            subtitle: Text(conversation['message']!),
            onTap: () => _onConversationTap(conversation['name']!),
          );
        },
        separatorBuilder: (context, index) => Divider(),
      ),
    );
  }
}
