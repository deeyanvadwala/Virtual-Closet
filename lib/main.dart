import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Authentication/loginpg.dart';
import 'Authentication/signuppg.dart';
import 'pages/Closet.dart';
import 'pages/OutfitCreationPage.dart';
import 'pages/calender.dart';
import 'pages/chatbot.dart';
import 'pages/drawer.dart';
import 'pages/home2.dart';
import 'pages/savedoutfits.dart';
import 'pages/rejectedoutfits.dart';

import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( );
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _isUserLoggedIn;

  @override
  void initState() {
    super.initState();
    _isUserLoggedIn = _checkLoginStatus();
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('user_email');
    return email != null;  // Returns true if email is stored (user is logged in)
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isUserLoggedIn,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()), // Show loader while checking login
            ),
          );
        }

        bool isLoggedIn = snapshot.data ?? false;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'SourceSans'),
          home: AnimatedSplashScreen(
            splash: "assets/icons/Logo.jpg",
            splashIconSize: 2000.0,
            centered: true,
            nextScreen: isLoggedIn ? Homepg2() : const Login(), // If logged in, go to Closet
            backgroundColor: const Color.fromRGBO(221, 240, 254, 1),
            duration: 3100,
          ),
          routes: {
            '/Home': (context) => Homepg2(),
            '/Home2': (context) => Homepg2(),
            '/Closet': (context) => MyClosetPage(),
            '/Outfit': (context) => OutfitCreationPage(),
            '/drawer': (context) => MyDrawer(),
            '/register': (context) => SignUp(),
            '/login': (context) => Login(),
            '/cal': (context) => CalendarPage(),
            '/chatbot': (context) => ChatScreen(),
            "/saved-outfits":(context) => SavedOutfitsScreen(),
            "/rejected-outfits":(context) => RejectedOutfitsScreen(),
          },
        );
      },
    );
  }
}
