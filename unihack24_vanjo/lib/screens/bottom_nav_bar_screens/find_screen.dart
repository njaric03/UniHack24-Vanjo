// find_screen.dart
// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:unihack24_vanjo/models/user.dart';
import 'package:unihack24_vanjo/models/cycle.dart';
import '../../widgets/found_cycle_widget.dart';

class FindScreen extends StatefulWidget {
  const FindScreen({super.key});

  @override
  _FindScreenState createState() => _FindScreenState();
}

class _FindScreenState extends State<FindScreen> {
  final List<String> _matches = [];
  bool _isLoading = false;

  void _findMatches() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate a network call to find matches
    await Future.delayed(Duration(seconds: 2));

    // Example users and cycle
    List<SkillCycleUser> users = [
      SkillCycleUser(
        email: 'user1@example.com',
        firstName: 'John',
        lastName: 'Doe',
        username: 'johndoe',
        credits: 0,
        hoursTeaching: 0,
        ratingAvg: 0.0,
        avatarId: 1,
      ),
      SkillCycleUser(
        email: 'user2@example.com',
        firstName: 'Jane',
        lastName: 'Smith',
        username: 'janesmith',
        credits: 0,
        hoursTeaching: 0,
        ratingAvg: 0.0,
        avatarId: 2,
      ),
      SkillCycleUser(
        email: 'user3@example.com',
        firstName: 'Alice',
        lastName: 'Johnson',
        username: 'alicejohnson',
        credits: 0,
        hoursTeaching: 0,
        ratingAvg: 0.0,
        avatarId: 3,
      ),
    ];

    Cycle cycle = Cycle.fromList([
      'user1@example.com',
      'user2@example.com',
      'user3@example.com',
    ]);

    setState(() {
      _isLoading = false;
    });

    // Navigate to FoundCycleScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoundCycleScreen(
          users: users,
          cycle: cycle,
          currentUserEmail: 'user2@example.com',
          onAccept: () {
            // Handle accept action
            print('Cycle accepted');
            Navigator.pop(context); // Go back to find screen
          },
          onFindOther: () {
            // Handle find other action
            print('Finding other matches');
            Navigator.pop(context); // Go back to find screen
            // Optionally start a new search
            _findMatches();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _matches.isEmpty
                ? Text(
                    'No matches found. Click the button to find potential matches.',
                    textAlign: TextAlign.center,
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _matches.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_matches[index]),
                        );
                      },
                    ),
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _findMatches,
              child: _isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text('Find Potential Matches'),
            ),
          ],
        ),
      ),
    );
  }
}
