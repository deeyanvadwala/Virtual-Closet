import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vc/Authentication/constants.dart';

const String baseUrl = '${AppConstants.baseUrl}'; // Backend API URL

Future<void> signup(BuildContext context, String username, String email, String password) async {
  username = username.trim();
  email = email.trim();
  password = password.trim();

  if (username.isEmpty || email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("All fields are required")));
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'), // API endpoint
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "email": email, "password": password}),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 201) {
      // Store email in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup successful! Please log in.")),
      );
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushNamed(context, "/login");
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['error'] ?? "Signup failed")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error connecting to server. Check your internet.")),
    );
  }
}

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildTextField(usernameController, "Username"),
                _buildTextField(emailController, "Email"),
                _buildPasswordField(),
                Padding(
                  padding: const EdgeInsets.all(50),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      await signup(
                        context,
                        usernameController.text,
                        emailController.text,
                        passwordController.text,
                      );
                    },
                    child: const Text("Sign Up"),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/login");
                      },
                      child: const Text("Login"),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12, width: 1),
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12, width: 1),
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
      ),
      child: TextFormField(
        controller: passwordController,
        obscureText: !isVisible,
        decoration: InputDecoration(
          hintText: "Password",
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
              size: 16,
            ),
            onPressed: () {
              setState(() {
                isVisible = !isVisible;
              });
            },
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}