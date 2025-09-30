import 'package:flutter/material.dart';
import 'config/routes.dart';
import 'config/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Condominio App',
      theme: AppTheme.lightTheme,
      routes: appRoutes,
      initialRoute: '/', // arranca en SplashView
      debugShowCheckedModeBanner: false,
    );
  }
}
