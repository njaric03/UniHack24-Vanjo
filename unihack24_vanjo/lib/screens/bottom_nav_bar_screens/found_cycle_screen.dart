// found_cycle_screen.dart

// ignore_for_file: unused_element, unused_local_variable

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:unihack24_vanjo/services/api_service.dart';
import '../../models/cycle.dart';
import '../../models/user.dart';
import '../../widgets/user_card_widget.dart';
import 'package:unihack24_vanjo/services/firebase_services.dart';

class FoundCycleScreen extends StatefulWidget {
  final Cycle cycle;
  final String currentUserId;
  final VoidCallback onAccept;
  final VoidCallback onFindOther;

  const FoundCycleScreen({
    super.key,
    required this.cycle,
    required this.currentUserId,
    required this.onAccept,
    required this.onFindOther,
  });

  @override
  State<FoundCycleScreen> createState() => _FoundCycleScreenState();
}

class _FoundCycleScreenState extends State<FoundCycleScreen> {
  final ApiService _apiService = ApiService();
  final FirebaseService _firebaseService = FirebaseService();
  Future<void>? _initializationFuture;
  Uint8List? _imageBytes;
  List<SkillCycleUser>? _users;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _apiService.fetchCycleData(widget.currentUserId);
      _imageBytes = await _apiService.loadImage();
      _users = await _apiService.getCachedUsers();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize data: $e';
      });
    }
  }

  List<UserCard> _buildUserCards() {
    if (_users == null) return [];
    List<UserCard> userCards = [];
    final currentUserIndex =
        _users!.indexWhere((u) => u.id == widget.currentUserId);

    if (_users!.length == 2) {
      // 2 Users: [Teacher & Learner, User]
      userCards
          .add(UserCard(user: _users![0], role: UserRole.teacherAndLearner));
      userCards.add(UserCard(user: _users![1], role: UserRole.user));
    } else if (_users!.length == 3) {
      // 3 Users: [Teacher, User, Learner]
      final teacherIndex =
          (currentUserIndex - 1 + _users!.length) % _users!.length;
      final learnerIndex = (currentUserIndex + 1) % _users!.length;

      userCards
          .add(UserCard(user: _users![teacherIndex], role: UserRole.teacher));
      userCards
          .add(UserCard(user: _users![currentUserIndex], role: UserRole.user));
      userCards
          .add(UserCard(user: _users![learnerIndex], role: UserRole.learner));
    } else if (_users!.length > 3) {
      // More than 3 Users: Trim list to show Teacher, User, and Learner
      final teacherIndex =
          (currentUserIndex - 1 + _users!.length) % _users!.length;
      final learnerIndex = (currentUserIndex + 1) % _users!.length;

      userCards
          .add(UserCard(user: _users![teacherIndex], role: UserRole.teacher));
      userCards
          .add(UserCard(user: _users![currentUserIndex], role: UserRole.user));
      userCards
          .add(UserCard(user: _users![learnerIndex], role: UserRole.learner));
    }

    return userCards;
  }

  /// Handles the 'Accept' action by sending cycle data to Firebase.
  void _handleAccept() async {
    // Create a new Cycle object with the required data
    Cycle newCycle = Cycle(
      userIds: widget.cycle.userIds,
      createdAt: DateTime.now(),
      status: 'pending',
    );

    try {
      // Add the cycle to Firebase
      await _firebaseService.addCycle(newCycle);
      widget.onAccept();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cycle accepted and saved to Firebase')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept cycle: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Found Skill Cycle', style: TextStyle(color: Colors.black)),
      ),
      body: FutureBuilder<void>(
        future: _initializationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || _errorMessage != null) {
            return Center(
              child: Text(
                'Error: ${snapshot.error ?? _errorMessage}',
                style: TextStyle(color: Colors.red),
              ),
            );
          } else {
            final currentUserIndex =
                _users!.indexWhere((u) => u.id == widget.currentUserId);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: _imageBytes != null
                        ? Image.memory(
                            _imageBytes!,
                            height: 300,
                            width: 300,
                          )
                        : const Text('No image available'),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _users != null
                      ? ListView(
                          children: _buildUserCards(),
                        )
                      : const Text('No users available'),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 12.0),
                          ),
                          child: const Text('Accept',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
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
                                color: Theme.of(context).primaryColor,
                                width: 2),
                          ),
                          child: const Text('Find Other',
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
