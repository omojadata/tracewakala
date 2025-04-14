import 'package:crdb/TargetScreen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'BaseList.dart';
import 'NewList.dart';
import 'main.dart';
import 'TargetScreen.dart';

class StartScreen extends StatefulWidget {
  // const StartScreen(
  //     this.switchProfileScreen, this.switchAjiraScreen, this.switchQuizScreen,
  //     {super.key});
  final User user;

  StartScreen({
    required this.user,
  });

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Sign-in failed: ${e.message}';
      if (e.code == 'user-disabled') {
        errorMessage = 'This user account has been disabled.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      }
      print(errorMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-out failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade800, Colors.purple.shade800],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _handleSignOut(context);
                        // Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //       builder: (context) => const LoginScreen()),
                        // );
                      },
                      icon: const Icon(Icons.logout, color: Colors.blue),
                      label: Text(
                        'Logout',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hero(
                        //   tag: 'quiz_logo',
                        //   child: Container(
                        //     width: 200,
                        //     height: 200,
                        //     decoration: BoxDecoration(
                        //       shape: BoxShape.circle,
                        //       color: Colors.white.withOpacity(0.2),
                        //       boxShadow: [
                        //         BoxShadow(
                        //           color: Colors.white.withOpacity(0.1),
                        //           blurRadius: 20,
                        //           spreadRadius: 5,
                        //         ),
                        //       ],
                        //     ),
                        //     child: Padding(
                        //       padding: const EdgeInsets.all(20),
                        //       child: Image.asset(
                        //         'assets/quiz.png',
                        //         fit: BoxFit.contain,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(height: 40),
                        Text(
                          "${widget.user.email}",
                          style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "CRDB PERFROMANCE",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TargetScreen(user: widget.user),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.blue.shade800,
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'T A R G E T S\nC O M M I S S I O N',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AgentListPage(user: widget.user),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.blue.shade800,
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'T O T A L\nB A S E',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // builder: (context) => AgentListPage(user: widget.user),
                                builder: (context) =>
                                    AccountListPage(user: widget.user),

                                // builder: (context) => StartScreen(user: _auth.currentUser!),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.blue.shade800,
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'T O T A L\nR E C R U I T M E N T S',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // const SizedBox(height: 20),
                        // ElevatedButton(
                        //   onPressed: () {},
                        //   style: ElevatedButton.styleFrom(
                        //     foregroundColor: Colors.blue.shade800,
                        //     backgroundColor: Colors.white,
                        //     padding: const EdgeInsets.symmetric(
                        //         horizontal: 40, vertical: 15),
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(30),
                        //     ),
                        //     elevation: 5,
                        //   ),
                        //   child: Text(
                        //     'R E C R U I T M E N T S\nS U G G E S T I O N S',
                        //     style: GoogleFonts.poppins(
                        //       fontSize: 22,
                        //       fontWeight: FontWeight.w600,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
