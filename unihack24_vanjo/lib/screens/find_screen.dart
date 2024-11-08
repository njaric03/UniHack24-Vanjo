// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class FindScreen extends StatefulWidget {
  const FindScreen({super.key});

  @override
  _FindScreenState createState() => _FindScreenState();
}

class _FindScreenState extends State<FindScreen> {
  List<String> _matches = [];
  bool _isLoading = false;

  void _findMatches() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate a network call to find matches
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _matches = ['Match 1', 'Match 2', 'Match 3']; // Example matches
      _isLoading = false;
    });
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