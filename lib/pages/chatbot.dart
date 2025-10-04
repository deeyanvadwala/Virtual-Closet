import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vc/Authentication/constants.dart';
import 'dart:convert';

import 'package:vc/pages/drawer.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false; // To track bot response loading

  final String apiUrl = "${AppConstants.baseUrl}/get_chat";

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add({"sender": "bot", "text": "Hello! How can I assist you with your styling today?"});
    });
  }

  void _sendMessage() async {
    String message = _controller.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": message});
      _isLoading = true; // Start loading
    });

    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"question": message}),
      );

      if (response.statusCode == 200) {
        String botResponse = jsonDecode(response.body)["answer"];

        setState(() {
          _messages.add({"sender": "bot", "text": botResponse});
        });
      } else {
        setState(() {
          _messages.add({"sender": "bot", "text": "Error: Could not get response."});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({"sender": "bot", "text": "Error: No connection to server."});
      });
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text("Style Bot"),
        centerTitle: true,
        backgroundColor: Colors.white,
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
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: _messages.length + (_isLoading ? 1 : 0), // Add loading indicator as extra item
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(), // Loading animation
                    ),
                  );
                }

                bool isUser = _messages[index]["sender"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.black : Colors.grey[300],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      _messages[index]["text"]!,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.black),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}