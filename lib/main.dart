import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

import 'BaseList.dart';
import 'StartScreen.dart';


// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: AgentListPage(),
//     );
//   }
// }
late final FirebaseApp app;
late final FirebaseAuth auth;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // We're using the manual installation on non-web platforms since Google sign in plugin doesn't yet support Dart initialization.
  // See related issue: https://github.com/flutter/flutter/issues/96391

  // We store the app and auth to make testing with a named instance easier.
  app = await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: "AIzaSyBJT3KoUTmY_Q3HBVmurfdk0ccgpLBAkxs",
          appId: "1:440494913690:web:17bca36fbc3a469b500723",
          messagingSenderId: "440494913690",
          projectId: "crdb-base",
          authDomain: "crdb-base.firebaseapp.com"
      )
  );
  auth = FirebaseAuth.instanceFor(app: app);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Sign-In Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AuthCheck(),
    );
  }
}

class AuthCheck extends StatefulWidget {
  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSignIn();
  }

  Future<void> _checkSignIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool savedLoginState = prefs.getBool('isLoggedIn') ?? false;

    if (savedLoginState && _auth.currentUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // builder: (context) => AgentListPage(user: _auth.currentUser!),
          builder: (context) => StartScreen(user: _auth.currentUser!),

        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading ? CircularProgressIndicator() : Container(),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // final GoogleSignIn _googleSignIn = GoogleSignIn(
  //     clientId: UniversalPlatform.isWeb
  //         ? '440494913690-jes3l4tglp8l8a5k3212qasicdv0q97r.apps.googleusercontent.com'
  //         : null);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _handleSignIn() async {
    try {
      if (UniversalPlatform.isWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final UserCredential userCredential =
            await _auth.signInWithPopup(googleProvider);
        if (userCredential.user != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => StartScreen(user: _auth.currentUser!),
            ),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        final GoogleSignInAuthentication googleAuth =
            await googleUser!.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        if (userCredential.user != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => StartScreen(user: _auth.currentUser!),
            ),
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _handleSignIn,
              child: Text('Sign in with Google'),
            ),
          ],
        ),
      ),
    );
  }
}




