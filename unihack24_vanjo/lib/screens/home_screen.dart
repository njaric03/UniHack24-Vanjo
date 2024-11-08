// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unihack24_vanjo/models/user.dart';
import 'package:unihack24_vanjo/screens/cycle_overview_screen.dart';
import 'package:unihack24_vanjo/screens/profile_screen.dart';
import 'package:unihack24_vanjo/widgets/side_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
      CycleOverviewScreen(),
      if (currentUser != null)
        ProfileScreen(user: currentUser!)
      else
        Container(),
    ];

    void onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: SideDrawer(drawerWidth: 0.67 * MediaQuery.of(context).size.width),
      body: currentUser == null
          ? Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: pages,
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }
}
