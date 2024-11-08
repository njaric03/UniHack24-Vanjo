// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unihack24_vanjo/models/user.dart';
import 'package:unihack24_vanjo/screens/side_drawer_screens/profile_screen.dart';
import 'package:unihack24_vanjo/theme/app_theme.dart';
import 'package:unihack24_vanjo/widgets/side_drawer.dart';

import '/screens/bottom_nav_bar_screens/alerts_screen.dart';
import '/screens/bottom_nav_bar_screens/find_screen.dart';
import '/screens/bottom_nav_bar_screens/all_chats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.pageName});

  final String pageName;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  SkillCycleUser? currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userID = prefs.getString('userID');

    if (userID != null) {
      SkillCycleUser? user = await SkillCycleUser.getUserById(userID);
      setState(() {
        currentUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      FindScreen(),
      if (currentUser != null)
        ProfileScreen(user: currentUser!)
      else
        Container(),
      MessagesScreen(),
      AlertsScreen()
    ];

    final List<String> titles = [
      'Find Matches',
      'Profile',
      'Messages',
      'Alerts'
    ];

    void onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        centerTitle: true,
      ),
      drawer: currentUser == null
          ? null
          : SideDrawer(
              drawerWidth: 0.67 * MediaQuery.of(context).size.width,
              user: currentUser!,
            ),
      body: currentUser == null
          ? Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: pages,
            ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          // Customize the text style for selected and unselected items
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
              selectedItemColor: AppTheme.primaryColor,
              unselectedItemColor: Colors.grey,
              selectedLabelStyle: TextStyle(color: AppTheme.primaryColor),
              unselectedLabelStyle: TextStyle(color: Colors.grey),
              showUnselectedLabels: true),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Find',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Alerts',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: onItemTapped,
        ),
      ),
    );
  }
}
