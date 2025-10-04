import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:vc/Authentication/constants.dart';
import 'package:vc/pages/suggest_outfit_page.dart';
import 'dart:convert';
import 'AboutPage.dart';
import 'Closet.dart';
import 'OutfitCreationPage.dart';
import 'profile.dart';
import 'savedoutfits.dart';
import 'rejectedoutfits.dart';

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  bool isDarkMode = false;
  String profileImagePath = "";
  String userName = "John Doe";
  String userEmail = "email@example.com";
  List<String> selectedClothes = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

Future<void> _loadSettings() async {
  final prefs = await SharedPreferences.getInstance();

  // Fetch and print all stored key-value pairs
  Set<String> keys = prefs.getKeys();
  for (String key in keys) {
    print("$key: ${prefs.get(key)}");
  }

  // Load specific settings
  String? email = prefs.getString('user_email');
  setState(() {
    isDarkMode = prefs.getBool('darkMode') ?? false;
    profileImagePath = prefs.getString('profileImage') ?? "";
    userEmail = email ?? "email@example.com";
  });

  if (email != null) {
    _fetchUserData(email);
  }
}


  Future<void> _fetchUserData(String email) async {
    try {
      print(" Fetching user data for: $email"); // Debugging

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/get-user?email=$email'),
      );

      print(" API Response Status: ${response.statusCode}");
      print(" API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('username') && data.containsKey('email')) {
          setState(() {
            userName = data['username'];
            userEmail = data['email'];
          });

          // Save username in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', userName);
        print(" Saved username in SharedPreferences: $userName"); // Debugging
        
          print(" Updated UI with username: $userName, email: $userEmail"); // Debugging
        } else {
          print(" API response does not contain expected keys: ${response.body}");
        }
      } else {
        print(" API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print(" Error fetching user data: $e");
      if (e is SocketException) {
        print(" Network error: Could not connect to the server.");
      } else if (e is FormatException) {
        print(" Data format error: Response is not valid JSON.");
      } else {
        print(" Unknown error occurred.");
      }
    }
  }

  void _navigateToProfileEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileEditPage()),
    ).then((_) => _loadSettings()); // Reload settings after editing
  }

 void _navigateToSuggestOutfit() async {
    final List<String>? suggestedOutfit = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SuggestOutfitPage()),
    );

    if (suggestedOutfit != null) {
      setState(() {
        selectedClothes = suggestedOutfit; // Update UI with suggested clothes
      });
    }
  }
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears stored login data
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(userName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            accountEmail: Text(userEmail),
            currentAccountPicture: GestureDetector(
              onTap: () {
                if (profileImagePath.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(child: Image.file(File(profileImagePath))),
                  );
                }
              },
              child: CircleAvatar(
                backgroundImage: profileImagePath.isNotEmpty
                    ? FileImage(File(profileImagePath))
                    : AssetImage('assets/icons/Logo.jpg') as ImageProvider,
              ),
            ),
            decoration: BoxDecoration(color: Colors.black),
            otherAccountsPictures: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.white),
                onPressed: () => _navigateToProfileEdit(context),
              ),
            ],
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.black),
            title: Text("Home", style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.pushNamed(context, '/Home2');
            },
          ),
          ListTile(
            leading: Image.asset("assets/icons/Closet (2).png", width: 20, height: 20),
            title: Text("Closet", style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyClosetPage(showAppBar: true)));
            },
          ),
          ListTile(
            leading: Icon(Icons.checkroom, color: Colors.black),
            title: Text("Outfits", style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => OutfitCreationPage(showAppBar: true)));
            },
          ),
          ListTile(
            leading: Icon(Icons.bookmark, color: Colors.black),
            title: Text("Saved Outfits", style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SavedOutfitsScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.block, color: Colors.black),
            title: Text("Rejected Outfits", style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => RejectedOutfitsScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.smart_toy, color: Colors.black),
            title: Text("AI Recommender", style: TextStyle(color: Colors.black)),
            onTap: _navigateToSuggestOutfit,
          ),
          ListTile(
            leading: Icon(Icons.chat, color: Colors.black),
            title: Text("Style Bot", style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.pushNamed(context, '/chatbot');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info, color: Colors.black),
            title: Text("About", style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AboutPage()));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
