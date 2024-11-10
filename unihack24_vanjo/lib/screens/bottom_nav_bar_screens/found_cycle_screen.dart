import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:unihack24_vanjo/services/api_service.dart';
import '../../models/cycle.dart';
import '../../models/user.dart';
import '../../widgets/user_card_widget.dart';

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
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: _errorMessage != null
                        ? Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red),
                          )
                        : _imageBytes != null
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
                      ? ListView.builder(
                          itemCount: _users!.length,
                          itemBuilder: (context, index) {
                            final user = _users![index];
                            final currentUserIndex = _users!.indexWhere(
                                (u) => u.id == widget.currentUserId);

                            // Determine user role
                            UserRole role;
                            if (_users!.length == 2) {
                              if (index == 0) {
                                role = UserRole.teacherAndLearner;
                              } else {
                                role = UserRole.user;
                              }
                            } else if (_users!.length == 3) {
                              if (index == currentUserIndex) {
                                role = UserRole.user;
                              } else if (index ==
                                  (currentUserIndex - 1 + _users!.length) %
                                      _users!.length) {
                                role = UserRole.teacher;
                              } else if (index ==
                                  (currentUserIndex + 1) % _users!.length) {
                                role = UserRole.learner;
                              } else {
                                role = UserRole.user;
                              }
                            } else {
                              if (user.id == widget.currentUserId) {
                                role = UserRole.user;
                              } else if (index ==
                                  (currentUserIndex - 1 + _users!.length) %
                                      _users!.length) {
                                role = UserRole.teacher;
                              } else if (index ==
                                  (currentUserIndex + 1) % _users!.length) {
                                role = UserRole.learner;
                              } else {
                                role = UserRole.user;
                              }
                            }

                            return UserCard(user: user, role: role);
                          },
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
                          onPressed: widget.onAccept,
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
