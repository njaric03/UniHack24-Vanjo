// find_screen.dart

// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unihack24_vanjo/models/cycle.dart';
import 'package:unihack24_vanjo/services/firebase_services.dart';
import 'package:intl/intl.dart';
import 'package:unihack24_vanjo/theme/app_theme.dart';
import 'found_cycle_screen.dart';

class FindScreen extends StatefulWidget {
  const FindScreen({super.key});

  @override
  _FindScreenState createState() => _FindScreenState();
}

class _FindScreenState extends State<FindScreen> {
  final FirebaseService _firebaseService = FirebaseService();
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
    if (_currentUserId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate a network call to find matches
      await Future.delayed(Duration(seconds: 2));

      // For demonstration, let's assume we have fetched matched user IDs
      // In a real scenario, implement your matching logic here
      List<String> matchedUserIds = ['user_2', 'user_3', 'user_4'];

      // Include the current user in the cycle
      List<String> cycleUserIds = List.from(matchedUserIds);
      cycleUserIds.add(_currentUserId!);

      // Create a new Cycle
      Cycle cycle = Cycle.fromList(cycleUserIds);

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
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to find matches: $e')),
      );
    }
  }

  Widget _buildCycleList() {
    if (_currentUserId == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Expanded(
      child: StreamBuilder<List<Cycle>>(
        stream: _firebaseService.getUserCycles(_currentUserId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading cycles: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No cycles found for now.',
                textAlign: TextAlign.center,
              ),
            );
          }

          List<Cycle> cycles = snapshot.data!;

          return ListView.builder(
            itemCount: cycles.length,
            itemBuilder: (context, index) {
              Cycle cycle = cycles[index];
              String formattedDate =
                  DateFormat('yyyy-MM-dd – kk:mm').format(cycle.createdAt);
              return Card(
                child: ListTile(
                  title: Text('Cycle ${index + 1}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Created at: $formattedDate',
                        style: TextStyle(color: AppTheme.primaryColor),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Status: pending',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            _buildCycleList(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  _isLoading || _currentUserId == null ? null : _findMatches,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 12.0),
              ),
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
