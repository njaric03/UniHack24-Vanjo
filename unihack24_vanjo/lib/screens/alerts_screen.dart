// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final List<String> _notifications = [
    'Your cycle was completed',
    'Review someone',
    'Someone reviewed you',
  ];

  void _onNotificationTap(String notification) {
    // Handle notification tap
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return ListTile(
            title: Text(notification),
            onTap: () => _onNotificationTap(notification),
          );
        },
        separatorBuilder: (context, index) => Divider(),
      ),
    );
  }
}
