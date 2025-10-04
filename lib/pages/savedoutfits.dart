import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:vc/Authentication/constants.dart'; // Import for date formatting

class SavedOutfitsScreen extends StatefulWidget {
  const SavedOutfitsScreen({Key? key}) : super(key: key);

  @override
  _SavedOutfitsScreenState createState() => _SavedOutfitsScreenState();
}

class _SavedOutfitsScreenState extends State<SavedOutfitsScreen> {
  List<Map<String, dynamic>> savedOutfits = [];
  bool isLoading = true;
  bool hasError = false;
  String? userEmail;
  final String baseUrl = "${AppConstants.baseUrl}/"; // Base API URL

  @override
  void initState() {
    super.initState();
    getUserEmail();
  }

  Future<void> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString("user_email");

    if (email != null) {
      setState(() {
        userEmail = email;
      });

      print("Retrieved Email: $userEmail");
      await fetchSavedOutfits(); // Fetch outfits after getting email
    } else {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> fetchSavedOutfits() async {
    if (userEmail == null) {
      print(" Error: userEmail is null");
      setState(() {
        hasError = true;
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse('$baseUrl/saved-outfits?email=$userEmail');
    print("📡 Fetching data from: $url");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print(" Response received: ${response.body}");

        setState(() {
          savedOutfits = List<Map<String, dynamic>>.from(json.decode(response.body));
          isLoading = false;
        });
      } else {
        print(" Error: Server responded with status ${response.statusCode}");
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Exception: $e");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  /// Fixes Date Parsing Issue
  String formatDate(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return "Unknown Date";

    try {
      // Convert HTTP Date format (e.g., "Sun, 16 Mar 2025 00:00:00 GMT") to DateTime
      DateTime date = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUtc(dateTimeString);
      return DateFormat("dd-MM-yyyy").format(date); // Convert to "DD-MM-YYYY"
    } catch (e) {
      print("Date parsing error: $e");
      return "Invalid Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: const Text('Saved Outfits', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 2,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : hasError
          ? const Center(child: Text("Error fetching outfits", style: TextStyle(color: Colors.black)))
          : savedOutfits.isEmpty
          ? const Center(child: Text("No saved outfits", style: TextStyle(color: Colors.black)))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: savedOutfits.length,
        itemBuilder: (context, index) {
          final outfit = savedOutfits[index];
          return OutfitTile(outfit: outfit, baseUrl: baseUrl);
        },
      ),
    );
  }
}

class OutfitTile extends StatelessWidget {
  final Map<String, dynamic> outfit;
  final String baseUrl;

  const OutfitTile({Key? key, required this.outfit, required this.baseUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String date = formatDate(outfit['saved_date']); // Fix date parsing
    String outfitName = outfit['outfit_name'] ?? "Unnamed Outfit";

    //  Correct Image URL Paths
    String? topImage = outfit['top_image'] != null ? baseUrl + outfit['top_image'].replaceAll("\\", "/") : null;
    String? bottomImage = outfit['bottom_image'] != null ? baseUrl + outfit['bottom_image'].replaceAll("\\", "/") : null;
    String? accessoryImage = outfit['accessory_image'] != null ? baseUrl + outfit['accessory_image'].replaceAll("\\", "/") : null;

    return Card(
      color: Colors.grey[100],
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Outfit Name (Added)
            Text(
              outfitName,
              style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Date Below Outfit Name
            Text(
              "Saved on: $date",
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),

            const SizedBox(height: 12),

            // Outfit Images Row
            Row(
              children: [
                if (topImage != null) OutfitImage(imageUrl: topImage),
                if (bottomImage != null) OutfitImage(imageUrl: bottomImage),
                if (accessoryImage != null) OutfitImage(imageUrl: accessoryImage),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Fixes Date Parsing
  String formatDate(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return "Unknown Date";
    try {
      DateTime date = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUtc(dateTimeString);
      return DateFormat("dd-MM-yyyy").format(date);
    } catch (e) {
      return "Invalid Date";
    }
  }
}

class OutfitImage extends StatelessWidget {
  final String imageUrl;

  const OutfitImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
      ),
    );
  }
}
