// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unihack24_vanjo/models/user.dart';
import 'package:unihack24_vanjo/screens/utility_screens/home_screen.dart';
import '../../services/auth_service.dart';
import 'signin_screen.dart';

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
  bool _isGoogleLoading = false;
  String? _errorMessage;

  List<String> _selectedLearningSubjects = [];
  List<String> _selectedTeachingSubjects = [];
  List<String> _subjectOptions = [];

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

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final skillCycleUser = SkillCycleUser(
        email: email,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
        credits: 0,
        hoursTeaching: 0,
        ratingAvg: 0.0,
        learningSubjects: _selectedLearningSubjects,
        teachingSubjects: _selectedTeachingSubjects,
      );

      final user = await _authService.registerWithEmail(
        email,
        password,
        skillCycleUser,
      );

      if (user != null) {
        await _handleSuccessfulSignUp(user.uid);
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

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        await _handleSuccessfulSignUp(user.uid);
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error signing in with Google. Please try again.";
      });
    } finally {
      setState(() {
        _isGoogleLoading = false;
      });
    }
  }

  Future<void> _handleSuccessfulSignUp(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userID', uid);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreen(pageName: 'Sign up'),
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
                selectedColor:
                    Theme.of(context).primaryColor, // Set selected color
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      onChanged([...selectedSubjects, subject]);
                    } else {
                      onChanged(
                          selectedSubjects.where((s) => s != subject).toList());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50), // Add some space at the top
            Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
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
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signUp,
                    child: Text('Sign Up with Email'),
                  ),
            SizedBox(height: 16),
            _isGoogleLoading
                ? CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: Image.network(
                      'https://www.google.com/favicon.ico',
                      height: 24.0,
                    ),
                    label: Text('Sign up with Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
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
