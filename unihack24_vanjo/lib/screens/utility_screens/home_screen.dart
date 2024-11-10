// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unihack24_vanjo/models/user.dart';
import 'package:unihack24_vanjo/screens/side_drawer_screens/profile_screen.dart';
import 'package:unihack24_vanjo/theme/app_theme.dart';
import 'package:unihack24_vanjo/widgets/side_drawer.dart';
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
  String? userID;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadThemePreference();
  }

  Future<void> _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loadedUserID = prefs.getString('userID');

    if (loadedUserID != null) {
      print('Loaded user ID: $loadedUserID');
      SkillCycleUser? user = await SkillCycleUser.getUserById(loadedUserID);
      print('Fetched User: $user');
      setState(() {
        currentUser = user;
        userID = loadedUserID;
      });
    } else {
      print('No user ID found in SharedPreferences');
    }
  }

  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _handleThemeChanged() async {
    await _loadThemePreference();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      FindScreen(),
      if (userID != null) AllChatsScreen(userId: userID!) else Container(),
      if (currentUser != null)
        ProfileScreen(user: currentUser!)
      else
        Container(),
    ];

    final List<String> titles = [
      'Find Matches',
      'Profile',
      'Messages',
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? AppTheme.darkThemeData : AppTheme.themeData,
      home: Scaffold(
        appBar: AppBar(
          title: Text(titles[_selectedIndex]),
          centerTitle: true,
        ),
        drawer: currentUser == null
            ? null
            : SideDrawer(
                drawerWidth: 0.67 * MediaQuery.of(context).size.width,
                user: currentUser!,
                onThemeChanged: _handleThemeChanged,
              ),
        body: currentUser == null
            ? Center(child: CircularProgressIndicator())
            : IndexedStack(
                index: _selectedIndex,
                children: pages,
              ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
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
                icon: Icon(Icons.message),
                label: 'Messages',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              )
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}