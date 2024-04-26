import 'package:flutter/material.dart';
import 'package:smart_piggy/screens/vertify_code.dart';

import '../components/my_button.dart';
import '../components/my_text_field.dart';
import '../services/login.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool isError = true;
  String serverMessage = '';

  Future<void> _sendEmail() async {
    if (_formKey.currentState?.validate() ?? false) {

      final String email = _emailController.text;

      try {
        final Map<String, dynamic> response =
        await ForgotPasswordService.sendEmail(email);

        print('Response status: ${response['status']}');
        print('Response body: ${response['message']}');

        if (response['status'] == "success") {
          setState(() {
            serverMessage = response['message'];
            isError = false;
          });
          print('Send email successful');
        } else {
          setState(() {
            serverMessage = response['message'];
            isError = true;
          });
          print('Send email failed: ${response['message']}');
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
                const SizedBox(height: 40),
                Image.asset(
                  "assets/images/logo.png",
                  width: 300,
                ),
                const SizedBox(height: 40),
                MyTextFormField(
                  hintText: 'Email',
                  inputController: _emailController,
                  icon: Icons.email_outlined,
                  errorInput: 'Please enter your email',
                ),
                const SizedBox(height: 12),
                MyButton(
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    if (!_isLoading) {
                      setState(() {
                        _isLoading = true;
                      });

                      await _sendEmail();
                      if(!isError){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(serverMessage),
                            duration: const Duration(seconds: 1),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VerifyCodeScreen()));
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
                  checkButton: _isLoading,
                  text: "Send Email",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}