import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:vc/Authentication/constants.dart';

class RejectedOutfitsScreen extends StatefulWidget {
  const RejectedOutfitsScreen({Key? key}) : super(key: key);

  @override
  _RejectedOutfitsScreenState createState() => _RejectedOutfitsScreenState();
}

class _RejectedOutfitsScreenState extends State<RejectedOutfitsScreen> {
  List<Map<String, dynamic>> rejectedOutfits = [];
  bool isLoading = true;
  bool hasError = false;
  String? userEmail;
  final String baseUrl = "${AppConstants.baseUrl}/"; //  API URL

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
      await fetchRejectedOutfits(); // Fetch outfits after getting email
    } else {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> fetchRejectedOutfits() async {
    if (userEmail == null) {
      print(" Error: userEmail is null");
      setState(() {
        hasError = true;
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse('$baseUrl/rejected-outfits?email=$userEmail');
    print(" Fetching data from: $url");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print(" Response received: ${response.body}");

        setState(() {
          rejectedOutfits = List<Map<String, dynamic>>.from(json.decode(response.body));
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
      print(" Exception: $e");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  /// Fixed Date Parsing
  String formatDate(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return "Unknown Date";

    try {
      DateTime date = HttpDate.parse(dateTimeString); // Correct parsing
      return DateFormat("dd-MM-yyyy").format(date); // Convert to "16-03-2025"
    } catch (e) {
      print(" Date parsing error: $e");
      return "Invalid Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: const Text('Rejected Outfits', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 2,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : hasError
          ? const Center(child: Text("Error fetching outfits", style: TextStyle(color: Colors.black)))
          : rejectedOutfits.isEmpty
          ? const Center(child: Text("No rejected outfits", style: TextStyle(color: Colors.black)))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: rejectedOutfits.length,
        itemBuilder: (context, index) {
          final outfit = rejectedOutfits[index];
          return RejectedOutfitTile(
            outfit: outfit,
            baseUrl: baseUrl,
            formatDate: formatDate, //  Pass function to child widget
          );
        },
      ),
    );
  }
}

class RejectedOutfitTile extends StatelessWidget {
  final Map<String, dynamic> outfit;
  final String baseUrl;
  final String Function(String?) formatDate; // Accept function as a parameter

  const RejectedOutfitTile({
    Key? key,
    required this.outfit,
    required this.baseUrl,
    required this.formatDate, // Required parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String date = formatDate(outfit['saved_date']); //  Use function passed from parent

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
            // Date Display
            Text(
              "Rejected on: $date",
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),

            const SizedBox(height: 12),

            //Outfit Images Row
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
