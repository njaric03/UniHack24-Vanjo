import 'package:flutter/material.dart';
import 'package:unihack24_vanjo/theme/app_theme.dart';

import '../models/user.dart';

enum UserRole {
  user,
  teacher,
  learner,
  teacherAndLearner;

  Color get cardColor {
    switch (this) {
      case UserRole.teacher:
        return AppTheme.teacherColor.withOpacity(0.2);
      case UserRole.learner:
        return AppTheme.learnerColor.withOpacity(0.2);
      case UserRole.teacherAndLearner:
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
      case UserRole.teacherAndLearner:
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
      case UserRole.teacherAndLearner:
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
      case UserRole.teacherAndLearner:
        return 'Teaching and Learning';
      default:
        return 'You';
    }
  }

  Icon get roleIcon {
    switch (this) {
      case UserRole.teacher:
        return const Icon(Icons.school, color: AppTheme.teacherColor);
      case UserRole.learner:
        return const Icon(Icons.book, color: AppTheme.learnerColor);
      case UserRole.teacherAndLearner:
        return const Icon(Icons.swap_horiz, color: AppTheme.learnerColor);
      default:
        return Icon(Icons.person, color: AppTheme.networkColor);
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
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      child: Card(
        color: role.cardColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: role.borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(8),
          leading: CircleAvatar(
            radius: 20,
            backgroundImage: user.avatarId != null
                ? AssetImage(
                    'assets/avatars/avatari/HEIF Image ${user.avatarId}.jpeg')
                : const AssetImage('assets/avatars/avatari/HEIF Image 1.jpeg'),
          ),
          title: Text(
            '${user.firstName} ${user.lastName}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.username ?? '',
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                role.roleText,
                style: TextStyle(
                  color: role.textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
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
