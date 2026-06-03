// lib/super_admin_main.dart
//
// Standalone entry point to run ONLY the Super Admin Dashboard.
// Run with:  flutter run -t lib/super_admin_main.dart
//
// This keeps the Super Admin UI completely isolated from the
// existing shop-owner app that uses the regular main.dart.

import 'package:flutter/material.dart';
import 'screens/super_admin/super_admin_shell.dart';

void main() {
  runApp(const SuperAdminApp());
}

class SuperAdminApp extends StatelessWidget {
  const SuperAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Shop — Super Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        fontFamily: 'Roboto',
        cardTheme: const CardThemeData(
          surfaceTintColor: Colors.white,
        ),
      ),
      home: const SuperAdminShell(),
    );
  }
}
