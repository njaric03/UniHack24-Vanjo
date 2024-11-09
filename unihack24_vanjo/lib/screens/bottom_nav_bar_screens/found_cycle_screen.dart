import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:unihack24_vanjo/services/api_service.dart';
import '../../models/cycle.dart';
import '../../models/user.dart';
import '../../widgets/user_card_widget.dart';

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
  Future<Uint8List?>? _imageBytes;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchAndDisplayImage();
  }

  Future<void> _fetchAndDisplayImage() async {
    await _apiService.fetchAndSaveImage(widget.currentUserEmail);
    setState(() {
      _imageBytes = _apiService.loadImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    int currentUserIndex =
        widget.cycle.userIds.indexOf(widget.currentUserEmail);

    return Scaffold(
      appBar: AppBar(
        title: Text('Found Skill Cycle', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              // Display the decoded image or a loading indicator
              child: FutureBuilder<Uint8List?>(
                future: _imageBytes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return Image.memory(
                      snapshot.data!,
                      height: 300, // Enlarged image height
                      width: 300, // Enlarged image width
                    );
                  } else {
                    return const Text('No image available');
                  }
                },
              ),
            ),
          ),
          const SizedBox(
              height: 16), // Increased padding between image and first UserCard
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
                    child: const Text('Accept',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
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
                    child: const Text('Find Other',
                        style: TextStyle(fontSize: 16)),
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
