import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_ewallet/models/user_model.dart';
import 'package:flutter_ewallet/utils/theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_button/sign_button.dart';

class SharedUser {
  static final SharedUser _singleton = SharedUser._internal();
  static const String _loggedInKey = 'loggedIn';
  Image _profileImage = Image.asset("assets/placeholder_image.jpg");
  static const String _securityPinKey = 'securityPin';

  bool _isLoggedIn = false;

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
      aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
    // keyCipherAlgorithm:
    //     KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
    // storageCipherAlgorithm: StorageCipherAlgorithm.AES_CBC_PKCS7Padding
  ));

  UserModel? _cachedUser;

  factory SharedUser() {
    return _singleton;
  }

  SharedUser._internal();

  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkLoggedInState() async {
    final loggedInValue = await _storage.read(key: _loggedInKey);
    _isLoggedIn = loggedInValue == 'true';

    // Load profile image and security pin
    // _profileImage = await _storage.read(key: _profileImageKey);
    // _securityPin = await _storage.read(key: _securityPinKey);
  }

  Future<void> updateLoggedInState(bool value) async {
    _isLoggedIn = value;
    await _storage.write(key: _loggedInKey, value: value.toString());
  }

  Future<bool> setSecurityPin(String pin) async {
    // You can use more secure encryption algorithms for the pin
    try {
      // Store the hashed PIN
      await _storage.write(key: _securityPinKey, value: pin);

      // Operation was successful
      return true;
    } catch (e) {
      // Handle any errors
      print('Error setting security PIN: $e');
      return false;
    }
  }

  Future<String?> getSecurityPin() async {
    String? pin = await _storage.read(key: _securityPinKey);
    return pin;
  }

  Image getProfileImage() {
    return _profileImage;
  }

  void setProfileImage(Image img) {
    _profileImage = img;
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  static Future<String?> getUser() async {
    return await _storage.read(key: 'user');
  }

  Future<void> writeToStorage(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      print('Values stored successfully');
    } catch (e) {
      print('Error storing values: $e');
    }
  }

  Future<void> updateAccessToken(String value) async {
    try {
      await _storage.write(key: 'token', value: value);
      print('Access Token updated successfully');
    } catch (e) {
      print('Error updating access token: $e');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    if (_cachedUser != null) {
      return _cachedUser;
    } else {
      final theUser = await getUser();
      if (theUser != null) {
        // print('user is not null');
        final Map<String, dynamic> responseData = jsonDecode(theUser);

        final userId = responseData['id'];
        final username = responseData['username'];
        final email = responseData['email'];
        final firstname = responseData['firstName']; // Retrieve firstname
        final lastname = responseData['lastName']; // Retrieve lastname

        final user = UserModel(
          id: userId,
          username: username,
          email: email,
          firstname: firstname, // Pass firstname to UserModel constructor
          lastname: lastname, // Pass lastname to UserModel constructor
        );

        _cachedUser = user;
        print(_cachedUser);

        return user;
      } else {
        print('Token Null, User Not Found');
        logout();
        return null;
      }
    }
  }

  void clearCachedUser() {
    _cachedUser = null;
  }

  UserModel? get cachedUser => _cachedUser;

  // int? getUserId() {
  //   if (_isLoggedIn && _cachedUser != null) {
  //     return _cachedUser!.id;
  //   } else {
  //     return null;
  //   }
  // }

  String? getUsername() {
    return _cachedUser?.username;
  }

  String? getFirstname() {
    return _cachedUser?.firstname;
  }

  String? getLastname() {
    return _cachedUser?.lastname;
  }

  Future<String?> getEmail() async {
    return await _storage.read(key: 'email');
  }

  Future<String?> getWalletID() async {
    return await _storage.read(key: 'Wallet_ID');
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refreshToken');
  }

  Future<String?> getWalletUserID() async {
    return await _storage.read(key: 'Wallet_User_ID');
  }

  Future<String?> getWalletIBAN() async {
    return await _storage.read(key: 'Wallet_IBAN');
  }

  Future<String?> getWalletAmount() async {
    return await _storage.read(key: 'Amount');
  }

  String hashData(String data) {
    final hash = sha256.convert(utf8.encode(data));
    return hash.toString();
  }

  static Future<void> logout() async {
    try {
      // await storage.delete(key: 'token');
      // await storage.delete(key: 'user');
      _GoogleSignInButtonState().handleSignOut();
      await _storage.deleteAll();
      _singleton.clearCachedUser();
      // Update logged-in state
      _singleton._isLoggedIn = false;
      await _storage.write(key: _loggedInKey, value: 'false');
      print('Logged out successfully');
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  Future<List<String>> retrieveBankAccountIds() async {
    List<String> accountIds = [];
    try {
      // Get all keys
      final allKeys = await _storage.readAll();
      // Filter keys for bank account IDs
      final bankAccountKeys =
          allKeys.keys.where((key) => key.startsWith('bank_account_'));
      // Retrieve and add the IDs to the list
      for (var key in bankAccountKeys) {
        final accountId = await _storage.read(key: key);
        accountIds.add(accountId!);
      }
    } catch (e) {
      print('Error retrieving bank account IDs: $e');
    }
    return accountIds;
  }
}

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({Key? key}) : super(key: key);

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      // 'openid'
      // 'https://www.googleapis.com/auth/contacts.readonly'
      // Add any other scopes your application requires
    ],
    // clientId: "551536244051-0vfk355lgs5oub30a5b7q4jcregvp394.apps.googleusercontent.com",
    clientId:
        "551536244051-1jldt8r1f1iov8aoagt1jsc1090mmuha.apps.googleusercontent.com",
    serverClientId:
        "551536244051-0vfk355lgs5oub30a5b7q4jcregvp394.apps.googleusercontent.com",
  );
  bool _isSigningIn = false;

  Future<void> _handleSignIn() async {
    setState(() => _isSigningIn = true);

    try {
      final GoogleSignInAccount? account = _googleSignIn.currentUser;
      if (account == null) {
        // If user is not signed in, initiate the sign-in process
        final GoogleSignInAccount? newAccount = await _googleSignIn.signIn();
        if (newAccount == null) {
          // User cancelled the sign-in process
          print("User cancelled sign-in.");
          setState(() => _isSigningIn = false);
          return;
        }
      }

      final GoogleSignInAccount? currentUser = _googleSignIn.currentUser;
      if (currentUser != null) {
        final GoogleSignInAuthentication authentication =
            await currentUser.authentication;
        final String? idToken = authentication.idToken;
        final String? accessToken = authentication.accessToken;

        // Send ID token to backend
        try {
          final response = await http.post(
            Uri.parse(
                'http://10.0.2.2:8080/oauth/google'), // Replace with your endpoint
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'idToken': idToken}),
          );

          print(response.body);

          if (response.statusCode == 200) {
            SharedUser().updateLoggedInState(true);
            print("response body is ");
            print(response.statusCode);
            print(response.body);
            final responseData = jsonDecode(response.body);
            print(responseData);
            final data = responseData['data'];
            final token = data['token'];
            final Refreshtoken = data['refreshToken'];

            print(token);

            if (token != null && token.isNotEmpty) {
              SharedUser().writeToStorage('token', token);
              SharedUser().writeToStorage('user', jsonEncode(data));
              SharedUser().writeToStorage('refreshToken', Refreshtoken);

              print('Token Stored');
            } else {
              print('Token is null');
            }

            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false);
            // Handle successful authentication response
            // (e.g., navigate to a different screen, store tokens)
          } else if (response.statusCode == 409) {
            Fluttertoast.showToast(msg: "USER ALREADY REGISTERED");
            SharedUser.logout();
            // Handle authentication error
          }
        } catch (e) {
          print("HTTP request error: $e");
          // Handle network errors or backend errors
        }
      } else {
        print("Current user is null.");
      }
    } catch (e) {
      print("Sign-in error: $e");
      // Handle sign-in errors
    }

    setState(() => _isSigningIn = false);
  }

  Future<void> handleSignOut() async {
    try {
      await _googleSignIn.signOut();

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Sign out successful")));
    } catch (e) {
      print("Sign-out error: $e");
      // Handle sign-out errors
    }
  }

  // void handleSignOut() {
  //   _handleSignOut;
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // SignInButton(buttonType: ButtonType.google,  onPressed: () {
        //   _handleSignIn();
        // }),

        ElevatedButton(
          onPressed: () async {
            _handleSignIn();
          },
          style: ElevatedButton.styleFrom(
            elevation: 5,
            backgroundColor: whiteColor,
            minimumSize: Size(double.infinity, 45),
            // backgroundColor: Colors.blue,
            primary: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(56.0),
            ),
            // side: BorderSide(color: Colors.blue),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(
                  'assets/google_logo.png',
                  height: 25.0,
                  width: 25.0,
                ),
                const SizedBox(width: 10.0),
                Text('Sign in with Google',
                    style: blackTextStyle.copyWith(fontSize: 15)),
                SizedBox(
                  width: 8,
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
