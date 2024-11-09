import 'package:flutter/material.dart';
import 'package:unihack24_vanjo/models/user.dart';
import 'package:unihack24_vanjo/models/cycle.dart';
import 'package:unihack24_vanjo/theme/app_theme.dart';
import 'package:unihack24_vanjo/widgets/user_card_widget.dart'; // Assuming this is where you'll put the UserCard

class FoundCycleScreen extends StatefulWidget {
  final List<SkillCycleUser> users;
  final Cycle cycle;
  final String currentUserEmail;
  final VoidCallback onAccept;
  final VoidCallback onFindOther;

  const FoundCycleScreen({
    super.key,
    required this.users,
    required this.cycle,
    required this.currentUserEmail,
    required this.onAccept,
    required this.onFindOther,
  });

  @override
  State<FoundCycleScreen> createState() => _FoundCycleScreenState();
}

class _FoundCycleScreenState extends State<FoundCycleScreen> {
  @override
  Widget build(BuildContext context) {
    int currentUserIndex =
        widget.cycle.userIds.indexOf(widget.currentUserEmail);

    return Scaffold(
      appBar: AppBar(
        title: Text('Found Skill Cycle',
            style: TextStyle(color: AppTheme.textColor)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Text(
              'SkillCycle connects learners and teachers in a seamless cycle of knowledge exchange. Find the perfect match to enhance your skills or share your expertise.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black87,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Image.asset(
                'assets/icons/Android/ic_launcher_google_play.png',
                height: 100,
                width: 100,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.users.length,
              itemBuilder: (context, index) {
                final user = widget.users[index];

                // Determine user role
                UserRole role;
                if (user.email == widget.currentUserEmail) {
                  role = UserRole.current;
                } else if (index ==
                    (currentUserIndex - 1 + widget.users.length) %
                        widget.users.length) {
                  role = UserRole.teacher;
                } else if (index ==
                    (currentUserIndex + 1) % widget.users.length) {
                  role = UserRole.learner;
                } else {
                  role = UserRole.network;
                }

                return UserCard(user: user, role: role);
              },
            ),
          ),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onFindOther,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                      side: BorderSide(
                          color: Theme.of(context).primaryColor, width: 2),
                    ),
                    child: const Text(
                      'Find Other',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
