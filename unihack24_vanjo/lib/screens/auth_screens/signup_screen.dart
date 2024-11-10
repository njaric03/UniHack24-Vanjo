// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unihack24_vanjo/models/user.dart';
import 'package:unihack24_vanjo/screens/utility_screens/home_screen.dart';
import '../../services/auth_service.dart';
import 'signin_screen.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  List<String> _selectedLearningSubjects = [];
  List<String> _selectedTeachingSubjects = [];
  List<String> _subjectOptions = [];
  int? _selectedAvatarId;
  final List<int> _avatarIds = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    List<String> classes = await _authService.fetchClasses();
    setState(() {
      _subjectOptions = classes;
    });
  }

  Future<bool> _sendUserDataToApi(String userId) async {
    final url = Uri.parse('http://192.168.30.218:5000/add_user');

    try {
      final payload = {
        "doc_id": userId, // Using Firebase UID as doc_id
        "attributes": {
          "first_name": _firstNameController.text.trim(),
          "last_name": _lastNameController.text.trim(),
          "teaching_subject": _selectedTeachingSubjects.isNotEmpty
              ? _selectedTeachingSubjects.first
              : "",
          "learning_subject": _selectedLearningSubjects.isNotEmpty
              ? _selectedLearningSubjects.first
              : "",
          "rating_avg_teacher": 0.0, // Initial rating for new user
          "avatar_id": _selectedAvatarId ?? 1,
        }
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print("API Success: ${response.body}");
        return true;
      } else {
        print("API Error: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("API Exception: $e");
      return false;
    }
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final user = await _authService.registerWithEmail(
        email,
        password,
        SkillCycleUser(
          id: '',
          email: email,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          username: _usernameController.text.trim(),
          credits: 0,
          hoursTeaching: 0,
          ratingAvg: 0.0,
          learningSubjects: _selectedLearningSubjects,
          teachingSubjects: _selectedTeachingSubjects,
          avatarId: _selectedAvatarId ?? 1,
        ),
      );

      if (user != null) {
        final skillCycleUser = SkillCycleUser(
          id: user.uid,
          email: email,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          username: _usernameController.text.trim(),
          credits: 0,
          hoursTeaching: 0,
          ratingAvg: 0.0,
          learningSubjects: _selectedLearningSubjects,
          teachingSubjects: _selectedTeachingSubjects,
          avatarId: _selectedAvatarId ?? 1,
        );

        // Save to Firestore
        await _authService.updateUserProfile(skillCycleUser);

        // Send data to API
        final apiSuccess = await _sendUserDataToApi(user.uid);

        if (apiSuccess) {
          await _handleSuccessfulSignUp(user.uid);
        } else {
          setState(() {
            _errorMessage =
                "Failed to register with the service. Please try again.";
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error signing up. Please try again.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSuccessfulSignUp(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userID', uid);

    Fluttertoast.showToast(
      msg: "Sign up successful!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreen(pageName: ''),
      ),
    );
  }

  Widget _buildSubjectSelector({
    required String title,
    required List<String> selectedSubjects,
    required Function(List<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            spacing: 8.0,
            children: _subjectOptions.map((subject) {
              final isSelected = selectedSubjects.contains(subject);
              return FilterChip(
                label: Text(subject),
                selected: isSelected,
                selectedColor: Theme.of(context).primaryColor,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      // Override with only the newly selected subject
                      onChanged([subject]);
                    } else {
                      // Clear the selection if the subject is deselected
                      onChanged([]);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Avatar'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            spacing: 8.0,
            children: _avatarIds.map((avatarId) {
              final isSelected = _selectedAvatarId == avatarId;
              return ChoiceChip(
                label: CircleAvatar(
                  backgroundImage: AssetImage(
                      'assets/avatars/avatari/HEIF Image $avatarId.jpeg'),
                  radius: 20,
                ),
                selected: isSelected,
                selectedColor: Theme.of(context).primaryColor,
                onSelected: (selected) {
                  setState(() {
                    _selectedAvatarId = selected ? avatarId : null;
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign up'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            _buildSubjectSelector(
              title: 'Subjects you want to learn:',
              selectedSubjects: _selectedLearningSubjects,
              onChanged: (subjects) =>
                  setState(() => _selectedLearningSubjects = subjects),
            ),
            SizedBox(height: 16),
            _buildSubjectSelector(
              title: 'Subjects you can teach:',
              selectedSubjects: _selectedTeachingSubjects,
              onChanged: (subjects) =>
                  setState(() => _selectedTeachingSubjects = subjects),
            ),
            SizedBox(height: 24),
            _buildAvatarSelector(),
            SizedBox(height: 24),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signUp,
                    child: Text('Sign Up with Email'),
                  ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SignInScreen()),
                );
              },
              child: Text('Already have an account? Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
