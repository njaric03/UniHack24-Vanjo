import 'package:flutter/material.dart';
import 'package:unihack24_vanjo/theme/app_theme.dart';
import 'package:unihack24_vanjo/models/user.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({
    super.key,
    required this.drawerWidth,
    required this.user,
  });

  final double drawerWidth;
  final SkillCycleUser user;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: drawerWidth,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${user.firstName} ${user.lastName}', // Display user's full name
                  style: AppTheme.headline1.copyWith(color: Colors.white),
                ),
                SizedBox(height: 8),
              ],
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
    );
  }
}
