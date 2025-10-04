import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vc/Authentication/constants.dart';

class SuggestOutfitPage extends StatefulWidget {
  @override
  _SuggestOutfitPageState createState() => _SuggestOutfitPageState();
}

class _SuggestOutfitPageState extends State<SuggestOutfitPage> {
  List<dynamic> outfitSuggestions = [];
  bool isLoading = true;
  String errorMessage = "";
  String? userEmail;

  final String baseUrl = "${AppConstants.baseUrl}/";

  @override
  void initState() {
    super.initState();
    _getUserEmailAndFetchOutfits();
  }

  Future<void> _getUserEmailAndFetchOutfits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('user_email');

    if (email == null || email.isEmpty) {
      setState(() {
        errorMessage = "No user email found. Please log in again.";
        isLoading = false;
      });
      return;
    }

    setState(() {
      userEmail = email;
    });

    _fetchOutfitSuggestions(email);
  }

  Future<void> _fetchOutfitSuggestions(String email) async {
    final String apiUrl = "$baseUrl/generate-outfit?email=$email";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List && data.isNotEmpty) {
          setState(() {
            outfitSuggestions = data;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "No outfit suggestions available.";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Failed to fetch outfits. Please try again.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: Unable to connect to server.";
        isLoading = false;
      });
    }
  }

  Future<void> _saveOutfit(int index) async {
    TextEditingController nameController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Save Outfit"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Outfit Name"),
              ),
              SizedBox(height: 10),
              ListTile(
                title: Text("Select Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) return;
                Navigator.pop(context);
                await _sendOutfitToBackend(nameController.text, selectedDate, index);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendOutfitToBackend(String outfitName, DateTime date, int index) async {
    final String apiUrl = "$baseUrl/save-outfit";
    final outfit = outfitSuggestions[index];

    final Map<String, dynamic> outfitData = {
      "email": userEmail,
      "outfit_name": outfitName,
      "saved_date": DateFormat('yyyy-MM-dd').format(date),
      "top_id": outfit["top"]?["id"],
      "bottom_id": outfit["bottom"]?["id"],
      "accessory_id": outfit["accessory"]?["id"],
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(outfitData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Outfit saved successfully!")));
        setState(() {
          outfitSuggestions.removeAt(index);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save outfit.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: Could not save outfit.")));
    }
  }

  Future<void> _rejectOutfit(int index) async {
    final outfit = outfitSuggestions[index];
    final String apiUrl = "$baseUrl/reject-outfit";

    final Map<String, dynamic> rejectData = {
      "email": userEmail,
      "top_id": outfit["top"]?["id"],
      "bottom_id": outfit["bottom"]?["id"],
      "accessory_id": outfit["accessory"]?["id"],
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(rejectData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Outfit rejected.")));
        setState(() {
          outfitSuggestions.removeAt(index);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to reject outfit.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: Could not reject outfit.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Suggested Outfits")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
          : _buildOutfitList(),
    );
  }

  Widget _buildOutfitList() {
    return ListView.builder(
      itemCount: outfitSuggestions.length,
      itemBuilder: (context, index) {
        return _buildOutfitCard(outfitSuggestions[index], index);
      },
    );
  }

  Widget _buildOutfitCard(Map<String, dynamic> outfit, int index) {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildOutfitItem("Top", outfit["top"]),
            _buildOutfitItem("Bottom", outfit["bottom"]),

            if (outfit["accessory"] != null)  // Only show if accessory exists
              _buildOutfitItem("Accessory", outfit["accessory"]),

            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _rejectOutfit(index),
                  icon: Icon(Icons.close, color: Colors.white),
                  label: Text("Reject"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: () => _saveOutfit(index),
                  icon: Icon(Icons.save, color: Colors.white),
                  label: Text("Save"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitItem(String category, dynamic itemData) {
    return ListTile(
      title: Text(category, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(itemData != null ? "${itemData["color"]}, ${itemData["style"]}" : "Not Available"),
      leading: itemData != null
          ? Image.network(baseUrl + itemData["image_path"], width: 50, height: 50, fit: BoxFit.cover)
          : Icon(Icons.image_not_supported, size: 50),
    );
  }
}
