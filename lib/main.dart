import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_itinerary/firebase_options.dart';
import 'package:my_itinerary/screens/auth_screen.dart';
import 'package:my_itinerary/screens/home_page.dart';
import 'package:my_itinerary/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
    );
  } catch (e) {
    return;
  }
  
  runApp(const MyItinerary());
}


class MyItinerary extends StatelessWidget {
  const MyItinerary({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Itinerary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          primary: Colors.white,
        ),
      ),
      home: _getInitialScreen(),
    );
  }

  Widget _getInitialScreen() {
    if (AuthService.currentUser != null) {
      return const HomePage();
    } else {
      return const AuthScreen();
    }
  }
}