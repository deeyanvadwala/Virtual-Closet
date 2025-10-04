// import 'package:flutter/material.dart';
// import 'dart:io';

// class ImagePreviewPage extends StatelessWidget {
//   final File imageFile;

//   ImagePreviewPage({required this.imageFile});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Add new item", style: TextStyle(color: Colors.black)),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.check, color: Colors.black),
//             onPressed: () {
//               // Save and go back
//               Navigator.pop(context, imageFile);
//             },
//           )
//         ],
//       ),
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           // Image Preview
//           Expanded(
//             child: Center(
//               child: Image.file(imageFile, fit: BoxFit.contain),
//             ),
//           ),

//           // Brand and Size Inputs
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             child: Column(
//               children: [
//                 _buildTextField("Brand", "Enter brand name"),
//                 SizedBox(height: 10),
//                 _buildTextField("Size", "Enter size"),
//                 SizedBox(height: 10),
//               ],
//             ),
//           ),

//           // Editing Options
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 _buildIconButton(Icons.brush, "BG Remove"),
//                 _buildIconButton(Icons.crop, "Crop"),
//                 _buildIconButton(Icons.rotate_right, "Rotate"),
//               ],
//             ),
//           ),

//           SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField(String label, String hint) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label.toUpperCase(),
//           style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
//         ),
//         SizedBox(height: 5),
//         TextField(
//           decoration: InputDecoration(
//             hintText: hint,
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//             contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildIconButton(IconData icon, String label) {
//     return Column(
//       children: [
//         IconButton(
//           icon: Icon(icon, color: Colors.black),
//           onPressed: () {}, // Add function
//         ),
//         Text(label, style: TextStyle(fontSize: 12)),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'dart:io';

class ImagePreviewPage extends StatefulWidget {
  final File imageFile;
  ImagePreviewPage({required this.imageFile});

  @override
  _ImagePreviewPageState createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();

  void _confirmUpload() {
    Navigator.pop(context, {
      "image": widget.imageFile,
      "brand": _brandController.text,
      "size": _sizeController.text
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new item", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.black),
            onPressed: _confirmUpload,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(child: Center(child: Image.file(widget.imageFile, fit: BoxFit.contain))),
          _buildTextField("Brand", _brandController),
          _buildTextField("Size", _sizeController),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextField(controller: controller, decoration: InputDecoration(labelText: label)),
    );
  }
}
