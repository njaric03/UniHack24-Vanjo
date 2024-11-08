import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:unihack24_vanjo/theme/strings.dart';
import 'screens/utility_screens/splash_screen.dart';
import 'config/firebase_options.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: AppTheme.themeData,
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
