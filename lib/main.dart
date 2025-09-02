import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_itinerary/firebase_options.dart';
import 'package:my_itinerary/screens/auth_screen.dart';
import 'package:my_itinerary/screens/home_page.dart';
import 'package:my_itinerary/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool firebaseInitialized = false;

  try {
    await dotenv.load(fileName: '.env');

    // More robust Firebase initialization check
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform
        );
      } else {
        // Firebase is already initialized, use the existing app
        Firebase.app();
      }
      firebaseInitialized = true;
    } on FirebaseException catch (e) {
      if (e.code == 'duplicate-app') {
        // App already exists, that's fine
        firebaseInitialized = true;
      } else {
        rethrow;
      }
    }
  } catch (e) {
    // Continue with app initialization even if Firebase fails
  }
  
  runApp(MyItinerary(firebaseInitialized: firebaseInitialized));
}


class MyItinerary extends StatelessWidget {
  final bool firebaseInitialized;

  const MyItinerary({super.key, this.firebaseInitialized = false});

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
    if (!firebaseInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'No internet connection',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Please check your internet connection and try again',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (AuthService.currentUser != null) {
      return const HomePage();
    } else {
      return const AuthScreen();
    }
  }
}