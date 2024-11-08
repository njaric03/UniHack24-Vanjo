// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:unihack24_vanjo/theme/strings.dart';
import 'cycle_overview_screen.dart';
import 'profile_screen.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    CycleOverviewScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double drawerWidth =
        MediaQuery.of(context).size.width * 0.66; // 2/3 of the screen width

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appName,
          style: AppTheme.headline1,
        ),
      ),
      drawer: Drawer(
        width: drawerWidth,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Menu',
                style: AppTheme.headline1,
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings', style: AppTheme.bodyText1),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help', style: AppTheme.bodyText1),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About', style: AppTheme.bodyText1),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            // Add more items as needed
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
