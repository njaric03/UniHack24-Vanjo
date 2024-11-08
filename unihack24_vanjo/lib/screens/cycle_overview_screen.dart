import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CycleOverviewScreen extends StatelessWidget {
  const CycleOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text('Cycle 1', style: AppTheme.bodyText1),
              subtitle: Text('5 Participants', style: AppTheme.bodyText1),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to cycle details
              },
            ),
            ListTile(
              title: Text('Cycle 2', style: AppTheme.bodyText1),
              subtitle: Text('4 Participants', style: AppTheme.bodyText1),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to cycle details
              },
            ),
            // Additional cycles can be added here
          ],
        ),
      ),
    );
  }
}
