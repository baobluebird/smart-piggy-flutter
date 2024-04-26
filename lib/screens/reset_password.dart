import 'package:flutter/material.dart';
import 'package:smart_piggy/screens/sign_in.dart';

import '../components/my_button.dart';
import '../components/my_text_field.dart';
import '../services/login.dart';


class ResetPassScreen extends StatefulWidget {
  final String idUser;
  const ResetPassScreen({super.key, required this.idUser});

  @override
  State<ResetPassScreen> createState() => _ResetPassScreenState();
}

class _ResetPassScreenState extends State<ResetPassScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool isError = true;
  String serverMessage = '';

  Future<void> _resetPass() async {
    if (_formKey.currentState?.validate() ?? false) {
      final String password = _passwordController.text;
      final String confirmPassword = _confirmPasswordController.text;

      try {
        final Map<String, dynamic> response =
        await ResetPassService.resetPass(widget.idUser,password, confirmPassword);

        print('Response status: ${response['status']}');
        print('Response body: ${response['message']}');

        if (response['status'] == "success") {
          setState(() {
            serverMessage = response['message'];
            isError = false;
          });
          print('Change password successful');
        } else {
          setState(() {
            serverMessage = response['message'];
            isError = true;
          });
          print('Create failed: ${response['message']}');
        }
      } catch (error) {
        setState(() {
          serverMessage = 'Error: $error';
          isError = true;
        });
        print('Error: $error');
      }
    }
  }

  bool showPass = false;
  bool showConfirm = false;

  showConfPass() {
    setState(() {
      showConfirm = !showConfirm;
    });
  }

  showPassword() {
    setState(() {
      showPass = !showPass;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: 40),
              Image.asset("assets/images/logo.png",),
              MyTextFormFieldForPass(
                hintText: 'Password',
                inputController: _passwordController,
                obsecureText: showPass,
                icon: Icons.lock_outline,
                errorInput: 'Please enter your password',
                onPressed: () {
                  setState(() {
                    showPass = !showPass;
                  });
                },
              ),
              const SizedBox(height: 12),
              MyTextFormFieldForPass(
                hintText: 'Confirm Password',
                inputController: _confirmPasswordController,
                obsecureText: showPass,
                icon: Icons.lock_outline,
                errorInput: 'Please enter your confirm password',
                onPressed: () {
                  setState(() {
                    showPass = !showPass;
                  });
                },
              ),
              const SizedBox(height: 30),
              MyButton(
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  if (!_isLoading) {
                    setState(() {
                      _isLoading = true;
                    });

                    await _resetPass();
                    if(!isError){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(serverMessage),
                          duration: const Duration(seconds: 1),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignInScreen()));
                    }else{
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
                customColor: const Color.fromARGB(255, 10, 185, 121),
                text: "Reset Password",
                checkButton: _isLoading,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}