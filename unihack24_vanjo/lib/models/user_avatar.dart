// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:unihack24_vanjo/theme/app_theme.dart';

class UserAvatar extends StatelessWidget {
  final String? avatarId;
  final String? firstName;
  final String? lastName;

  UserAvatar({
    required this.avatarId,
    required this.firstName,
    required this.lastName,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: AppTheme.primaryColor,
      backgroundImage: _shouldShowImage()
          ? AssetImage('assets/avatars/avatari/HEIF Image $avatarId.jpeg')
          : null,
      child: _shouldShowImage()
          ? null
          : Text(
              _getInitials(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
    );
  }

  bool _shouldShowImage() {
    return avatarId != null && avatarId != '0';
  }

  String _getInitials() {
    String initials = '';
    if (firstName != null && firstName!.isNotEmpty) initials += firstName![0];
    if (lastName != null && lastName!.isNotEmpty) initials += lastName![0];
    return initials.toUpperCase();
  }
}
