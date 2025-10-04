import 'package:flutter/material.dart';
import 'package:vc/pages/drawer.dart';
import 'package:vc/pages/savedoutfits.dart';
import 'package:vc/pages/suggest_outfit_page.dart';

class OutfitCreationPage extends StatefulWidget {
  final bool showAppBar;
  const OutfitCreationPage({super.key, this.showAppBar = true});

  @override
  _OutfitCreationPageState createState() => _OutfitCreationPageState();
}

class _OutfitCreationPageState extends State<OutfitCreationPage> {
  List<String> selectedClothes = [];

  void _navigateToSuggestOutfit() async {
    final List<String>? suggestedOutfit = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SuggestOutfitPage()),
    );

    if (suggestedOutfit != null) {
      setState(() {
        selectedClothes = suggestedOutfit;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: widget.showAppBar ? MyDrawer() : null,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: Colors.white,
              titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              title: Text("Outfits"),
              centerTitle: true,
              elevation: 1,
              leading: Builder(
                builder: (context) {
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Outfit Suggestion',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              SizedBox(height: 16),
              Center(
                child: _buildOptionButton(
                  icon: Icons.checkroom,
                  label: 'Suggest Outfit',
                  onTap: _navigateToSuggestOutfit,
                ),
              ),
              SizedBox(height: 40),
              Text(
                "Your Saved Outfits",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SavedOutfitsScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "View Saved Outfits",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: Colors.white),
            SizedBox(width: 10),
            Text(label, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:vc/pages/drawer.dart';
// //import 'package:vc/pages/select_clothes_page.dart';
// import 'package:vc/pages/suggest_outfit_page.dart'; // Import suggestion page

// class OutfitCreationPage extends StatefulWidget {
//   final bool showAppBar;
//   const OutfitCreationPage({super.key, this.showAppBar = true});

//   @override
//   _OutfitCreationPageState createState() => _OutfitCreationPageState();
// }

// class _OutfitCreationPageState extends State<OutfitCreationPage> {
//   List<String> selectedClothes = []; // Store selected items

//   void _navigateToSelectClothes() async {
//     final List<String>? result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => SelectClothesPage()),
//     );

//     if (result != null) {
//       setState(() {
//         selectedClothes = result; // Update UI with selected clothes
//       });
//     }
//   }

//   void _navigateToSuggestOutfit() async {
//     final List<String>? suggestedOutfit = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => SuggestOutfitPage()),
//     );

//     if (suggestedOutfit != null) {
//       setState(() {
//         selectedClothes = suggestedOutfit; // Update UI with suggested clothes
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: widget.showAppBar ? MyDrawer() : null,
//       appBar: widget.showAppBar
//           ? AppBar(
//               backgroundColor: Colors.white,
//               titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
//               title: Text("Outfits"),
//               centerTitle: true,
//               leading: Builder(
//                 builder: (context) {
//                   return IconButton(
//                     icon: const Icon(Icons.menu, color: Colors.black),
//                     onPressed: () {
//                       Scaffold.of(context).openDrawer();
//                     },
//                   );
//                 },
//               ),
//             )
//           : null,
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Choose an Option',
//               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
//             ),
//             SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildOptionButton(
//                   icon: Icons.brush,
//                   label: 'Create Outfit',
//                   onTap: _navigateToSelectClothes,
//                 ),
//                 _buildOptionButton(
//                   icon: Icons.lightbulb,
//                   label: 'Suggest Outfit',
//                   onTap: _navigateToSuggestOutfit,
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             Text(
//               "Selected Clothes:",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             selectedClothes.isEmpty
//                 ? Text("No clothes selected")
//                 : Wrap(
//                     spacing: 10,
//                     children: selectedClothes.map((item) {
//                       return Chip(
//                         label: Text(item),
//                         backgroundColor: Colors.grey[200],
//                       );
//                     }).toList(),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOptionButton({required IconData icon, required String label, required VoidCallback onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 30,
//             backgroundColor: Colors.black,
//             child: Icon(icon, size: 30, color: Colors.white),
//           ),
//           SizedBox(height: 8),
//           Text(label),
//         ],
//       ),
//     );
//   }
// }
