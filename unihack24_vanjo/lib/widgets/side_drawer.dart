// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:unihack24_vanjo/theme/app_theme.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({
    super.key,
    required this.drawerWidth,
  });

  final double drawerWidth;

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
    );
  }
}
