import 'package:flutter/material.dart';
import 'package:unihack24_vanjo/models/user.dart';
import 'package:unihack24_vanjo/theme/app_theme.dart';

enum UserRole {
  current,
  teacher,
  learner,
  network;

  Color get cardColor {
    switch (this) {
      case UserRole.teacher:
        return AppTheme.teacherColor.withOpacity(0.2);
      case UserRole.learner:
        return AppTheme.learnerColor.withOpacity(0.2);
      default:
        return AppTheme.networkColor.withOpacity(0.2);
    }
  }

  Color get borderColor {
    switch (this) {
      case UserRole.teacher:
        return AppTheme.teacherColor;
      case UserRole.learner:
        return AppTheme.learnerColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  Color get textColor {
    switch (this) {
      case UserRole.teacher:
        return AppTheme.teacherColor;
      case UserRole.learner:
        return AppTheme.learnerColor;
      default:
        return AppTheme.textColor;
    }
  }

  String get roleText {
    switch (this) {
      case UserRole.teacher:
        return 'Teaching you';
      case UserRole.learner:
        return 'Learning from you';
      case UserRole.current:
        return 'You';
      default:
        return 'Network member';
    }
  }

  Icon get roleIcon {
    switch (this) {
      case UserRole.teacher:
        return const Icon(Icons.school, color: AppTheme.teacherColor);
      case UserRole.learner:
        return const Icon(Icons.book, color: AppTheme.learnerColor);
      case UserRole.current:
        return Icon(Icons.person, color: AppTheme.networkColor);
      default:
        return Icon(Icons.person_outline, color: AppTheme.networkColor);
    }
  }
}

class UserCard extends StatelessWidget {
  final SkillCycleUser user;
  final UserRole role;

  const UserCard({
    super.key,
    required this.user,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        color: role.cardColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: role.borderColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: user.avatarId != null
                ? AssetImage(
                    'assets/avatars/avatari/HEIF Image ${user.avatarId}.jpeg')
                : const AssetImage('assets/avatars/avatari/HEIF Image 1.jpeg'),
          ),
          title: Text(
            '${user.firstName} ${user.lastName}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.username ?? '',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Text(
                role.roleText,
                style: TextStyle(
                  color: role.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          trailing: role.roleIcon,
        ),
      ),
    );
  }
}
