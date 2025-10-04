import 'package:flutter/material.dart';
import 'package:vc/pages/Closet.dart';
import 'package:vc/pages/OutfitCreationPage.dart';
import 'package:vc/pages/drawer.dart';


class Homepg2 extends StatefulWidget {
  const Homepg2({super.key});

  @override
  _Homepg2State createState() => _Homepg2State();
}

class _Homepg2State extends State<Homepg2> {
  int _selectedIndex = 0; // Track selected tab

  void _onItemTapped(int index) {
    if (index == 1) {
      // Navigate to Calendar page
     Navigator.pushNamed(context, '/cal');
      
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: MyDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
          title: Text("Virtual Closet"),
          centerTitle: true,
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
        ),
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TabBar(
               labelColor: Colors.black, // Selected tab color
            unselectedLabelColor: Colors.grey, // Unselected tab color
            indicatorColor: Colors.black, 
              tabs: [
                Tab(text: "My Closet"),
                Tab(text: "Outfit"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  MyClosetPage(showAppBar: false),
                  OutfitCreationPage(showAppBar: false),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          unselectedItemColor: Colors.white,
          selectedItemColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Calendar',
            ),
          ],
        ),
      ),
    );
  }
}
