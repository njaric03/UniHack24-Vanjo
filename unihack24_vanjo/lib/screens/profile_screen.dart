import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: AppTheme.headline1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Skills', style: AppTheme.headline1),
            TextField(
              decoration: InputDecoration(labelText: 'Skill 1'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Skill 2'),
            ),
            SizedBox(height: 24),
            Text('Your Needs', style: AppTheme.headline1),
            TextField(
              decoration: InputDecoration(labelText: 'Need 1'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Need 2'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Save profile logic goes here
              },
              child: Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
