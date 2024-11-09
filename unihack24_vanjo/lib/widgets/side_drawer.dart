// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unihack24_vanjo/theme/app_theme.dart';
import 'package:unihack24_vanjo/models/user.dart';
import 'package:unihack24_vanjo/screens/auth_screens/signin_screen.dart';
import 'package:unihack24_vanjo/models/user_avatar.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({
    super.key,
    required this.drawerWidth,
    required this.user,
    // required this.onThemeChanged,
  });

  final double drawerWidth;
  final SkillCycleUser user;
  // final ValueChanged<bool> onThemeChanged;

  @override
  // ignore: library_private_types_in_public_api
  _SideDrawerState createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = value;
      prefs.setBool('isDarkMode', value);
    });
    // widget.onThemeChanged(value);
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: widget.drawerWidth,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UserAvatar(
                      avatarId: widget.user.avatarId?.toString() ?? '0',
                      firstName: widget.user.firstName,
                      lastName: widget.user.lastName,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${widget.user.firstName} ${widget.user.lastName}',
                      style: AppTheme.headline1.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
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
                  SwitchListTile(
                    title: Text('Dark Mode', style: AppTheme.bodyText1),
                    value: _isDarkMode,
                    onChanged: _toggleDarkMode,
                    secondary: Icon(Icons.brightness_6),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout', style: AppTheme.bodyText1),
                      onTap: () => _logout(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
