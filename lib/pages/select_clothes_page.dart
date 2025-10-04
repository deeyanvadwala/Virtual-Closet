// import 'package:flutter/material.dart';

// class SelectClothesPage extends StatefulWidget {
//   @override
//   _SelectClothesPageState createState() => _SelectClothesPageState();
// }

// class _SelectClothesPageState extends State<SelectClothesPage> {
//   List<String> selectedClothes = [];

//   // Dummy closet items (Replace with real closet data)
//   final List<String> closetItems = [
//     '👕 Shirt',
//     '👖 Jeans',
//     '👗 Dress',
//     '🧥 Jacket',
//     '👟 Sneakers',
//     '🎩 Hat'
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Select Clothes"),
//         backgroundColor: Colors.white,
//         iconTheme: IconThemeData(color: Colors.black),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.check, color: Colors.black),
//             onPressed: () {
//               // Create an outfit collage or folder with selected items
//               if (selectedClothes.isNotEmpty) {
//                 Navigator.pop(context, selectedClothes);
//               }
//             },
//           ),
//         ],
//       ),
//       body: ListView.builder(
//         itemCount: closetItems.length,
//         itemBuilder: (context, index) {
//           final item = closetItems[index];
//           final isSelected = selectedClothes.contains(item);

//           return ListTile(
//             title: Text(item),
//             trailing: isSelected ? Icon(Icons.check_circle, color: Colors.green) : null,
//             onTap: () {
//               setState(() {
//                 isSelected ? selectedClothes.remove(item) : selectedClothes.add(item);
//               });
//             },
//           );
//         },
//       ),
//     );
//   }
// }
