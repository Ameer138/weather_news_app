//main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '/screens/login_screen.dart';
import '/screens/home_screen.dart';
import '/screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for web or other platforms
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyAaiXSYUI_v6ZI-6k2IV_SZ2UKPOhjsKBI",
          authDomain: "weathernewsapp-4b189.firebaseapp.com",
          projectId: "weathernewsapp-4b189",
          storageBucket: "weathernewsapp-4b189.firebasestorage.app",
          messagingSenderId: "891585186979",
          appId: "1:891585186979:web:836839a386f1e55767c316",
          measurementId: "G-5P060JWEWS"
      ),
    );
  } else {
    await Firebase.initializeApp(); // For mobile platforms
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
