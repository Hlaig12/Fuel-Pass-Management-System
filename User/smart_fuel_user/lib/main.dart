import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/login/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartFuelUserApp());
}

class SmartFuelUserApp extends StatelessWidget {
  const SmartFuelUserApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Smart Fuel Pass',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const LoginScreen(),
      );
}
