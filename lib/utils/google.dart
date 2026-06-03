// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_ewallet/utils/shared_user.dart';
// import 'package:flutter_signin_button/flutter_signin_button.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:http/http.dart' as http;

// class GoogleSignInButton extends StatefulWidget {
//   const GoogleSignInButton({Key? key}) : super(key: key);

//   @override
//   State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
// }

// class _GoogleSignInButtonState extends State<GoogleSignInButton> {
//   final GoogleSignIn _googleSignIn = GoogleSignIn(
//     scopes: [
//       'email',
//       'profile',
//       // 'https://www.googleapis.com/auth/contacts.readonly'
//       // Add any other scopes your application requires
//     ],
//     // clientId: ,
//     serverClientId:
//         "551536244051-0vfk355lgs5oub30a5b7q4jcregvp394.apps.googleusercontent.com",
//   );
//   bool _isSigningIn = false;

//   Future<void> _handleSignIn() async {
//     setState(() => _isSigningIn = true);

//     try {
//       final GoogleSignInAccount? account = _googleSignIn.currentUser;
//       if (account == null) {
//         // If user is not signed in, initiate the sign-in process
//         final GoogleSignInAccount? newAccount = await _googleSignIn.signIn();
//         if (newAccount == null) {
//           // User cancelled the sign-in process
//           print("User cancelled sign-in.");
//           setState(() => _isSigningIn = false);
//           return;
//         }
//       }

//       final GoogleSignInAccount? currentUser = _googleSignIn.currentUser;
//       if (currentUser != null) {
//         final GoogleSignInAuthentication authentication =
//             await currentUser.authentication;
//         final String? idToken = authentication.idToken;
//         final String? accessToken = authentication.accessToken;

//         // Send ID token to backend
//         try {
//           final response = await http.post(
//             Uri.parse(
//                 'http://10.0.2.2:8080/oauth/google'), // Replace with your endpoint
//             headers: {'Content-Type': 'application/json'},
//             body: jsonEncode({'idToken': idToken}),
//           );

//           print(response.body);

//           if (response.statusCode == 200) {
//             SharedUser().updateLoggedInState(true);
//             print("response body is ");
//             print(response.statusCode);
//             print(response.body);
//             final responseData = jsonDecode(response.body);
//             print(responseData);
//             final data = responseData['data'];
//             final token = data['token'];
//             print(token);

//             if (token != null && token.isNotEmpty) {
//               SharedUser().writeToStorage('token', token);
//               SharedUser().writeToStorage('user', jsonEncode(data));

//               print('Token Stored');
//             } else {
//               print('Token is null');
//             }

//             Navigator.pushNamedAndRemoveUntil(
//                 context, '/home', (route) => false);
//             // Handle successful authentication response
//             // (e.g., navigate to a different screen, store tokens)
//           } else if (response.statusCode == 409) {
//             // Fluttertoast.showToast(msg: "USER ALREADY REGISTERED");
//             handleSignOut;
//             // Handle authentication error
//           }
//         } catch (e) {
//           print("HTTP request error: $e");
//           // Handle network errors or backend errors
//         }
//       } else {
//         print("Current user is null.");
//       }
//     } catch (e) {
//       print("Sign-in error: $e");
//       // Handle sign-in errors
//     }

//     setState(() => _isSigningIn = false);
//   }

//   Future<void> handleSignOut() async {
//     try {
//       await _googleSignIn.signOut();

//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Sign out successful")));
//     } catch (e) {
//       print("Sign-out error: $e");
//       // Handle sign-out errors
//     }
//   }

//   // void handleSignOut() {
//   //   _handleSignOut;
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         SignInButton(Buttons.Google,mini: false, onPressed: () {
//           _handleSignIn();
//         }),
//         // ElevatedButton(
//         //   onPressed: _handleSignIn,
//         //   style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//         //   child: _isSigningIn
//         //       ? const CircularProgressIndicator()
//         //       : const Text('Sign in with Google'),
//         // ),
//         // const SizedBox(height: 20),
//         ElevatedButton(
//           onPressed: () {
//             handleSignOut();

//           },
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//           child: const Text('Sign out from Google'),
//         ),
//       ],
//     );
//   }
// }
