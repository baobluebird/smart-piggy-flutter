
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:smart_piggy/screens/sign_up.dart';

import '../components/my_button.dart';
import '../components/my_text_field.dart';
import '../pages/home.dart';
import '../services/login.dart';
import 'forgot_password.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final myBox = Hive.box('myBox');

  bool _isLoading = false;
  bool isError = true;
  String serverMessage = '';
  String token = '';


  Future<void> _signIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final Map<String, dynamic> response = await SignInService.signIn(
          _emailController.text,
          _passwordController.text,
        );

        print('Response status: ${response['status']}');
        print('Response body: ${response['message']}');
        print('Response body: ${response['access_token']}');

        if (response['status'] == "success") {
          token = response['access_token'];
          await myBox.put('id', response['id']);
          await myBox.put('name', response['name']);
          print("success stored to hive");
          setState(() {
            serverMessage = response['message'];
            isError = false;
          });
          print('Login successful');
        } else {
          setState(() {
            serverMessage = response['message'];
            isError = true;
          });
          print('Login failed: ${response['message']}');
        }
      } catch (error) {
        setState(() {
          isError = true;
          serverMessage = 'Error: $error';
        });
        print('Error: $error');
      }
    }
  }



  Future<void> remember() async {
    await myBox.put('token', token);
  }

  bool showPass = true;
  bool checkTheBox = false;

  showPassword() {
    setState(() {
      showPass = !showPass;
    });
  }

  check() {
    setState(() {
      checkTheBox = !checkTheBox;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/logo.png",
                  width: 300,
                ),
                const SizedBox(height: 20),
                MyTextFormField(
                  hintText: 'Email',
                  inputController: _emailController,
                  icon: Icons.email,
                  errorInput: 'Please enter your email',
                ),
                const SizedBox(height: 10),
                MyTextFormFieldForPass(
                  hintText: 'Password',
                  inputController: _passwordController,
                  obsecureText: showPass,
                  icon: Icons.lock,
                  errorInput: 'Please enter your password',
                  onPressed: () {
                    setState(() {
                      showPass = !showPass;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Theme(
                            data: ThemeData(
                              unselectedWidgetColor: Colors.grey[500],
                            ),
                            child: Checkbox(
                              checkColor: Colors.white,
                              value: checkTheBox ? true : false,
                              onChanged: (bool? value) {
                                check();
                              },
                            ),
                          ),
                          const Text(
                            "Remember me",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Color(0xff080265),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                MyButton(
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    if (!_isLoading) {
                      setState(() {
                        _isLoading = true;
                      });
                      await _signIn();
                      if (!isError) {
                        if (checkTheBox) {
                          await remember();
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(serverMessage),
                            duration: const Duration(seconds: 1),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => Home()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(serverMessage),
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  customColor: Colors.blue,
                  checkButton: _isLoading,
                  text: "Sign In",
                ),
                const SizedBox(height: 20),
                Text("Or Sign In with",
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      child: Image.asset(
                        "assets/images/facebook.png",
                        width: 50,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      padding: const EdgeInsets.all(7),
                      child: Image.asset(
                        "assets/images/google.png",
                        width: 50,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      padding: const EdgeInsets.all(7),
                      child: const Icon(
                        Icons.apple,
                        color: Colors.black,
                        size: 50,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "REGISTER",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}