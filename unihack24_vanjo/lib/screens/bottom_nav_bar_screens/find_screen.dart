// find_screen.dart
// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unihack24_vanjo/models/cycle.dart';
import 'found_cycle_screen.dart';

class FindScreen extends StatefulWidget {
  const FindScreen({super.key});

  @override
  _FindScreenState createState() => _FindScreenState();
}

class _FindScreenState extends State<FindScreen> {
  final List<String> _matches = [];
  bool _isLoading = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('userID');
    });
  }

  void _findMatches() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate a network call to find matches
    await Future.delayed(Duration(seconds: 2));

    Cycle cycle = Cycle.fromList([
      '1',
      '2',
      '3',
    ]);

    setState(() {
      _isLoading = false;
    });

    // Navigate to FoundCycleScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoundCycleScreen(
          cycle: cycle,
          currentUserId: _currentUserId!,
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
              onPressed:
                  _isLoading || _currentUserId == null ? null : _findMatches,
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
