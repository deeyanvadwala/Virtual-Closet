// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:vc/Authentication/constants.dart';

// class Login extends StatefulWidget {
//   const Login({super.key});

//   @override
//   State<Login> createState() => _LoginState();
// }

// class _LoginState extends State<Login> {
//   final TextEditingController identifierController = TextEditingController(); // Username or Email
//   final TextEditingController passwordController = TextEditingController();
//   bool isVisible = false;
//   String errorMessage = '';

//   Future<void> login() async {
//     const String apiUrl = '${AppConstants.baseUrl}/login';

//     final response = await http.post(
//       Uri.parse(apiUrl),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "identifier": identifierController.text, // Supports username or email
//         "password": passwordController.text,
//       }),
//     );

//     if (response.statusCode == 200) {
//       final responseData = jsonDecode(response.body);

//       // Store email in SharedPreferences
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString('user_email', responseData['email'] ?? identifierController.text);

//       Navigator.pushNamed(context, '/Home2'); // Navigate to home on success
//     } else {
//       setState(() {
//         errorMessage = jsonDecode(response.body)['error']; // Show server error message
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 80),
//                   child: Text(
//                     "Welcome to Virtual Closet",
//                     style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 if (errorMessage.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 10),
//                     child: Text(
//                       errorMessage,
//                       style: TextStyle(color: Colors.red, fontSize: 16),
//                     ),
//                   ),
//                 // Username or Email Input
//                 Container(
//                   margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.black12, width: 1),
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(19),
//                   ),
//                   child: TextFormField(
//                     controller: identifierController,
//                     decoration: const InputDecoration(
//                       hintText: "Enter Your Email", // Updated hint
//                       border: InputBorder.none,
//                     ),
//                   ),
//                 ),
//                 // Password Input
//                 Container(
//                   margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.black12, width: 1),
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(19),
//                   ),
//                   child: TextFormField(
//                     controller: passwordController,
//                     obscureText: !isVisible,
//                     decoration: InputDecoration(
//                       hintText: "Password",
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           isVisible ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
//                           size: 16,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             isVisible = !isVisible;
//                           });
//                         },
//                       ),
//                       border: InputBorder.none,
//                     ),
//                   ),
//                 ),
//                 // Padding(
//                 //   padding: const EdgeInsets.only(right: 50),
//                 //   child: Align(
//                 //     alignment: Alignment.centerRight,
//                 //     child: TextButton(
//                 //       onPressed: () {
//                 //         Navigator.pushNamed(context, "/forgot-password");
//                 //       },
//                 //       child: Text(
//                 //         "Forgot Password?",
//                 //         style: TextStyle(color: Colors.grey.shade600),
//                 //       ),
//                 //     ),
//                 //   ),
//                 // ),
//                 Padding(
//                   padding: const EdgeInsets.all(50),
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(19),
//                       ),
//                       minimumSize: const Size(double.infinity, 50),
//                     ),
//                     onPressed: login, // Call API on login button press
//                     child: const Text("Login"),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Not a member?"),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pushNamed(context, "/register");
//                       },
//                       child: const Text("Create account"),
//                     )
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:vc/Authentication/constants.dart';

// class Login extends StatefulWidget {
//   const Login({super.key});

//   @override
//   State<Login> createState() => _LoginState();
// }

// class _LoginState extends State<Login> {
//   final TextEditingController identifierController = TextEditingController(); // Username or Email
//   final TextEditingController passwordController = TextEditingController();
//   bool isVisible = false;
//   String errorMessage = '';

//   Future<void> login() async {
//     const String apiUrl = '${AppConstants.baseUrl}/login';

//     final response = await http.post(
//       Uri.parse(apiUrl),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "identifier": identifierController.text, // Supports username or email
//         "password": passwordController.text,
//       }),
//     );

//     if (response.statusCode == 200) {
//       final responseData = jsonDecode(response.body);

//       // Store email in SharedPreferences
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString('user_email', responseData['email'] ?? identifierController.text);

//       Navigator.pushNamed(context, '/Home2'); // Navigate to home on success
//     } else {
//       setState(() {
//         errorMessage = jsonDecode(response.body)['error']; // Show server error message
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 80),
//                   child: Text(
//                     "Welcome to Virtual Closet",
//                     style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
                
//                 ElevatedButton.icon(
//   icon: Image.asset(
//     'assets/icons/google.png',
//     height: 30,
//     width: 30,
//   ),
//   label: const Text(
//     "Sign in with Google",
//     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//   ),
//   style: ElevatedButton.styleFrom(
//     backgroundColor: Colors.white,
//     foregroundColor: Colors.black,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//     minimumSize: const Size(350, 50),
//     side: const BorderSide(color: Colors.black, width: 1),
//   ),
//   onPressed: () {
//     // Google sign-in logic
//   },
// ),

//                 SizedBox(height: 20),

//                  ElevatedButton.icon(
//   icon: Image.asset(
//     'assets/icons/Apple.png',
//     height: 40,
//     width: 40,
//   ),
//   label: const Text(
//     "Sign in with Apple",
//     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//   ),
//   style: ElevatedButton.styleFrom(
//     backgroundColor: Colors.white,
//     foregroundColor: Colors.black,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
//     minimumSize: const Size(350, 50),
//     side: const BorderSide(color: Colors.black, width: 1),
//   ),
//   onPressed: () {
//     // Google sign-in logic
//   },
// ),
//                 ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vc/Authentication/constants.dart';

// Firebase & Google Sign-In
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController identifierController = TextEditingController(); // Username or Email
  final TextEditingController passwordController = TextEditingController();
  bool isVisible = false;
  String errorMessage = '';

  Future<void> login() async {
    const String apiUrl = '${AppConstants.baseUrl}/login';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "identifier": identifierController.text,
        "password": passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', responseData['email'] ?? identifierController.text);
      Navigator.pushNamed(context, '/Home2');
    } else {
      setState(() {
        errorMessage = jsonDecode(response.body)['error'];
      });
    }
  }

  Future<void> onGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', user?.email ?? '');

      Navigator.pushNamed(context, '/Home2');
    } catch (e) {
      setState(() {
        errorMessage = "Google Sign-In failed: $e";
      });
    }
  }

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
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Text(
                    "Welcome to Virtual Closet",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),

                ElevatedButton.icon(
                  icon: Image.asset(
                    'assets/icons/google.png',
                    height: 30,
                    width: 30,
                  ),
                  label: const Text(
                    "Sign in with Google",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    minimumSize: const Size(350, 50),
                    side: const BorderSide(color: Colors.black, width: 1),
                  ),
                  onPressed: onGoogleSignIn,
                ),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  icon: Image.asset(
                    'assets/icons/Apple.png',
                    height: 40,
                    width: 40,
                  ),
                  label: const Text(
                    "Sign in with Apple",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                    minimumSize: const Size(350, 50),
                    side: const BorderSide(color: Colors.black, width: 1),
                  ),
                  onPressed: () {
                    // Apple sign-in logic (to be implemented)
                  },
                ),

                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
