import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vc/Authentication/constants.dart';
import 'drawer.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  int _selectedIndex = 1;
  final String baseUrl = "${AppConstants.baseUrl}";
  Map<DateTime, List<String>> outfitImages = {};

  @override
  void initState() {
    super.initState();
    _fetchUserEmailAndLoadData();
  }

  Future<void> _fetchUserEmailAndLoadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('user_email');

    if (userEmail != null) {
      fetchOutfitsForMonth(_focusedDay, userEmail);
    } else {
      print("Error: User email not found.");
    }
  }

  Future<void> fetchOutfitsForMonth(DateTime date, String email) async {
    final url = Uri.parse(
        '$baseUrl/get-outfits?month=${date.month}&year=${date.year}&email=$email');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        Map<DateTime, List<String>> fetchedOutfits = {};

        data.forEach((dateStr, images) {
          DateTime date = DateTime.parse(dateStr).toUtc();
          DateTime normalizedDate = DateTime.utc(date.year, date.month, date.day).add(Duration(days: 1)); // ✅ Shift by +1 day
          List<String> formattedImages = (images as List)
              .map((img) => "$baseUrl/${img.toString()}".replaceAll(r'\', '/'))
              .toList();

          fetchedOutfits[normalizedDate] = formattedImages;
        });


        setState(() {
          outfitImages = fetchedOutfits;
        });
      } else {
        print("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushNamed(context, '/Home2');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
        title: Text("Outfit Calendar"),
        elevation: 1,
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Shrink-wraps content
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Keep track of outfits in the calendar",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),

            /// Wrapped in a fixed-height `Container` instead of `Flexible`
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TableCalendar(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String? userEmail = prefs.getString('user_email');
                  if (userEmail != null) {
                    fetchOutfitsForMonth(focusedDay, userEmail);
                  }
                },
                eventLoader: (day) {
                  DateTime normalizedDay = DateTime.utc(day.year, day.month, day.day);
                  return outfitImages[normalizedDay] ?? [];
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    DateTime normalizedDay = DateTime.utc(date.year, date.month, date.day);
                    List<String>? images = outfitImages[normalizedDay];

                    if (images != null && images.isNotEmpty) {
                      return Positioned(
                        bottom: 4,
                        child: SizedBox(
                          height: 25,
                          width: 25,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(images[0], fit: BoxFit.cover),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),

            /// Outfit Images Section
            _selectedDay != null &&
                outfitImages.containsKey(DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day))
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                shrinkWrap: true, // Prevents overflow
                physics: NeverScrollableScrollPhysics(), // Fixes nested scrolling issue
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: outfitImages[DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)]!.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                        outfitImages[DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)]![index]),
                  );
                },
              ),
            )
                : Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("No outfit recorded for this day"),
            ),
          ],
        ),
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
    );
  }
}
