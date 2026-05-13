import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_page.dart';
import 'screens/add_station_screen.dart';
import 'services/auth_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SMAT Ecosystem',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: FutureBuilder<String?>(
        future: AuthService().getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.data != null) {
            return HomePage();
          }
          return const LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => HomePage(),
        '/add': (context) => AddStationScreen(),
      },
    );
  }
}