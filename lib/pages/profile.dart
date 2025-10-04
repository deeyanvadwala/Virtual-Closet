// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';

// class ProfileEditPage extends StatefulWidget {
//   @override
//   _ProfileEditPageState createState() => _ProfileEditPageState();
// }

// class _ProfileEditPageState extends State<ProfileEditPage> {
//   TextEditingController _nameController = TextEditingController();
//   String profileImagePath = "";

//   @override
//   void initState() {
//     super.initState();
//     _loadProfileInfo();
//   }

//   Future<void> _loadProfileInfo() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _nameController.text = prefs.getString('userName') ?? "John Doe";
//       profileImagePath = prefs.getString('profileImage') ?? "";
//     });
//   }

//   Future<void> _saveProfileInfo() async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setString('userName', _nameController.text);
//     if (profileImagePath.isNotEmpty) {
//       prefs.setString('profileImage', profileImagePath);
//     }
//     Navigator.pop(context);
//   }

//   Future<void> _pickImage() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         profileImagePath = pickedFile.path;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Edit Profile")),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             GestureDetector(
//               onTap: _pickImage,
//               child: CircleAvatar(
//                 radius: 50,
//                 backgroundImage: profileImagePath.isNotEmpty
//                     ? FileImage(File(profileImagePath))
//                     : AssetImage('assets/icons/Logo.jpg') as ImageProvider,
//               ),
//             ),
//             SizedBox(height: 10),
//             TextField(
//               controller: _nameController,
//               decoration: InputDecoration(labelText: "Name"),
//             ),
//              SizedBox(height: 10),
           
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _saveProfileInfo,
//               child: Text("Save"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:vc/Authentication/constants.dart';

class ProfileEditPage extends StatefulWidget {
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  TextEditingController _nameController = TextEditingController();
  String profileImagePath = "";
  String userEmail = "";

  @override
  void initState() {
    super.initState();
    _loadProfileInfo();
  }

  Future<void> _loadProfileInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? "John Doe";
      profileImagePath = prefs.getString('profileImage') ?? "";
      userEmail = prefs.getString('user_email') ?? ""; // Retrieve email from SharedPreferences
    });
  }

  Future<void> _saveProfileInfo() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Name cannot be empty!")),
      );
      return;
    }

    await _updateUsernameInDatabase(_nameController.text);
  }

  Future<void> _updateUsernameInDatabase(String newUsername) async {
    if (userEmail.isEmpty) {
      print("Email not found in SharedPreferences");
      return;
    }

    final url = Uri.parse('${AppConstants.baseUrl}/edit-username');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": userEmail,
        "new_username": newUsername,
      }),
    );

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', newUsername); // Save new username in SharedPreferences

      setState(() {
        _nameController.text = newUsername; // Update UI
      });

      print("Username updated successfully!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Username updated successfully!")),
      );
      Navigator.pop(context);
    } else {
      print("Failed to update username. Response: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update username. Try again.")),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: profileImagePath.isNotEmpty
                    ? FileImage(File(profileImagePath))
                    : AssetImage('assets/icons/Logo.jpg') as ImageProvider,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfileInfo,
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
