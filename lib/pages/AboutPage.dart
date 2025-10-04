import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Virtual Closet App", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Version: 1.0.0", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text(
              "This app helps you organize your wardrobe, plan outfits, and get AI-powered outfit recommendations.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text("Developed by: Deeyan Vadwala", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
