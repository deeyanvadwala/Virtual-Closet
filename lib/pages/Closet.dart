//============================================================
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import 'package:vc/Authentication/constants.dart';

import 'ImagePreviewPage.dart';
import 'drawer.dart';

class MyClosetPage extends StatefulWidget {
  final bool showAppBar;
  MyClosetPage({this.showAppBar = true});

  @override
  _MyClosetPageState createState() => _MyClosetPageState();
}

class _MyClosetPageState extends State<MyClosetPage> {
  final ImagePicker _picker = ImagePicker();
  List<String> _categories = [
    "All", "Shirt", "T-Shirt", "Top", "Jeans", "Skirt", "Dress", "Accessories", "Bottoms"
  ];
  String _selectedCategory = "All";
  List<Map<String, dynamic>> _closetItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClosetItems();
  }

  // Show upload options modal
  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text("Upload from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("Take a Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        );
      },
    );
  }

// Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);

    if (image != null) {
      File imageFile = File(image.path);

      if (!mounted) return;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => ImagePreviewPage(imageFile: imageFile),
        ),
      );

      if (result != null && result is Map<String, dynamic>) {
        File finalImage = result['image'];
        String brand = result['brand'];
        String size = result['size'];

        _uploadImage(finalImage, brand, size);
      }
    }
  }

  // Fetch closet items from backend
  Future<void> _fetchClosetItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('user_email');

    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User email not found")));
      return;
    }

    String baseUrl = "${AppConstants.baseUrl}/get-closet-items";
    String url = "$baseUrl?email=$email&category=${_selectedCategory == 'All' ? 'all' : _selectedCategory}";

    setState(() => _isLoading = true);

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _closetItems = List<Map<String, dynamic>>.from(data);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to fetch items")));
      }
    } catch (e) {
      print("Error fetching closet items: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching items")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Upload image to backend
  Future<void> _uploadImage(File imageFile, String brand, String size) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('user_email');

    if (email == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User email not found")));
      return;
    }

    String url = "${AppConstants.baseUrl}/add-item";

    var request = http.MultipartRequest("POST", Uri.parse(url));
    request.fields["email"] = email;
    request.fields["brand"] = brand;
    request.fields["size"] = size;

    String fileName = p.basename(imageFile.path);
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      filename: fileName,
      contentType: MediaType.parse(lookupMimeType(imageFile.path) ?? "image/jpeg"),
    ));

    var response = await request.send();

    if (!mounted) return;
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item added successfully")));
      _fetchClosetItems();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add item")));
    }
  }

  // Delete closet item
  Future<void> _deleteClosetItem(String imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('user_email');

    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User email not found")));
      return;
    }

    String url = "${AppConstants.baseUrl}/delete-closet-item?email=$email&image_path=$imagePath";

    try {
      var response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item deleted successfully")));
        _fetchClosetItems();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete item")));
      }
    } catch (e) {
      print("Error deleting item: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error deleting item")));
    }
  }

  // Show delete confirmation dialog
  void _showDeleteDialog(String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Item"),
          content: Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteClosetItem(imagePath);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: widget.showAppBar ? MyDrawer() : null,
      appBar: widget.showAppBar
          ? AppBar(
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
        title: Text("My Closet"),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      )
          : null,
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        backgroundColor: Colors.black,
        onPressed: () => _showUploadOptions(),
        child: Icon(Icons.add, color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Category Filters
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((category) {
                  bool isSelected = _selectedCategory == category;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                      _fetchClosetItems();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Closet Items Grid
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _closetItems.isEmpty
                ? Center(child: Text("No items found."))
                : GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 9,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: _closetItems.length,
              itemBuilder: (context, index) {
                String imagePath = _closetItems[index]['image_path'];
                return GestureDetector(
                  onLongPress: () => _showDeleteDialog(imagePath),
                  child: Image.network("${AppConstants.baseUrl}/" + imagePath.replaceAll("\\", "/")),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

