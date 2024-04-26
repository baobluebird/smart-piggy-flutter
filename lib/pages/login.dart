import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import '../components/my_button.dart';
import '../screens/sign_in.dart';
import '../screens/sign_up.dart';
import '../services/login.dart';
import 'home.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  int backButtonPressCounter = 0;
  DateTime? currentBackPressTime;

  final myBox = Hive.box('myBox');
  late String storedToken;
  String serverMessage = '';

  Future<void> clearHiveBox(String boxName) async {
    var box = await Hive.openBox(boxName);
    await box.clear();
  }

  Future<void> _decodeToken(String token) async {
    try {
      final Map<String, dynamic> response =
      await DecodeTokenService.decodeToken(token);
      print('Response status: ${response['status']}');
      print('Response body: ${response['message']}');
      if (response['status'] == "OK") {
        setState(() {
          serverMessage = response['message'];
        });
        print('Login successful');
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => Home()));
        print(serverMessage);
      } else {
        setState(() {
          serverMessage = response['message'];
        });
        print('Login failed: ${response['message']}');
        print(serverMessage);
      }
    } catch (error) {
      setState(() {
        serverMessage = 'Error: $error';
      });
      print('Error: $error');
      print(serverMessage);
    }
  }
  @override
  void initState() {
    super.initState();

    //clearHiveBox('myBox');

    print("Amount of data is ${myBox.length}");
    storedToken = myBox.get('token', defaultValue: '');
    print('Stored Token: $storedToken');
    if(storedToken != ''){
      _decodeToken(storedToken);
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (backButtonPressCounter < 1) {
          setState(() {
            backButtonPressCounter++;
            currentBackPressTime = DateTime.now();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Press back again to exit."),
            ),
          );
          return false;
        } else {
          if (currentBackPressTime == null ||
              DateTime.now().difference(currentBackPressTime!) >
                  const Duration(seconds: 2)) {
            setState(() {
              backButtonPressCounter = 0;
            });
            return false;
          }
          return true;
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 140),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: Image.asset(
                          "assets/images/logo.png",
                          width: 250,
                        ),
                      ),
                      Text(
                        'Smart Piggy',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansKawi(
                          textStyle: const TextStyle(color: Color(0xFF009DA8)),
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 40),
                      MyButton(
                        customColor: Colors.blue.withOpacity(0.8),
                        text: "Sign In",
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignInScreen()));
                        },
                      ),
                      const SizedBox(height: 20),
                      MyButton(
                        customColor:  Colors.blue.withOpacity(0.6),
                        text: "Create an account",
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUpScreen()));
                        },
                      ),
                      const Spacer(),
                      Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Terms of use",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 20),
                            Text(
                              "Privacy Policy",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
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