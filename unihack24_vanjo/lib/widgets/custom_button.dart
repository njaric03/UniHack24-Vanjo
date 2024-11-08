import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
//ne koristi se za sad

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppTheme.primaryColor,
      ),
      child: Text(label, style: AppTheme.bodyText1),
    );
  }
}
