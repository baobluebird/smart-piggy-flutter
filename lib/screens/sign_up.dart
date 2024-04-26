import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:smart_piggy/screens/sign_in.dart';

import '../components/my_button.dart';
import '../components/my_text_field.dart';
import '../services/login.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool isError = true;
  String serverMessage = '';
  File? _image;

  Future<void> _signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      final String name = _nameController.text;
      final String email = _emailController.text;
      final String password = _passwordController.text;
      final String confirmPassword = _confirmPasswordController.text;
      final String date = _dateController.text;


      try {
        final Map<String, dynamic> response =
        await SignUpService.signUp(name,email, date, password, confirmPassword, _image);

        print('Response status: ${response["status"]}');
        print('Response body: ${response["message"]}');

        if (response['status'] == "success") {
          setState(() {
            serverMessage = response["message"];
            isError = false;
          });
          print('Create successful');
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = pickedDate.toString().split(" ")[0];
      });
    }
  }

  bool showPass = true;
  bool showConfirm = true;

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
  Future<File> pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);

      if (pickedFile == null) {
        throw Exception('No image selected.');
      }

      return File(pickedFile.path);
    } catch (e) {
      print('Error picking image: $e');
      throw e;
    }
  }

  selectImage() async {
    File im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
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
              Stack(
                children: [
                  _image != null
                      ? CircleAvatar(
                    radius: 64,
                    backgroundImage: FileImage(_image!),
                    backgroundColor: Colors.red,
                  )
                      : const CircleAvatar(
                    radius: 64,
                    backgroundImage: NetworkImage(
                        'https://i.stack.imgur.com/l60Hf.png'),
                    backgroundColor: Colors.red,
                  ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(Icons.add_a_photo),
                    ),
                  )
                ],
              ),
              MyTextFormField(
                hintText: 'Name',
                inputController: _nameController,
                icon: Icons.person_outline,
                errorInput: 'Please enter your email',
              ),
              const SizedBox(height: 12),
              MyTextFormField(
                hintText: 'Email',
                inputController: _emailController,
                icon: Icons.email_outlined,
                errorInput: 'Please enter your email',
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: MyTextFormField(
                    hintText: 'Date of Birth',
                    inputController: _dateController,
                    icon: Icons.calendar_today,
                    errorInput: 'Please select your date of birth',
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
                    showConfirm = !showConfirm;
                  });
                },
              ),
              const SizedBox(height: 30),
              MyButton(
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  if(_nameController.text.isEmpty || _emailController.text.isEmpty || _dateController.text.isEmpty || _passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please type all fields"),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if(_image == null){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please choose your avatar"),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (!_isLoading) {
                    setState(() {
                      _isLoading = true;
                    });

                    await _signUp();
                    if(!isError){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(serverMessage),
                          duration: const Duration(seconds: 1),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop();
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
                customColor: Colors.blue,
                text: "Sign Up",
                checkButton: _isLoading,
              ),
              const SizedBox(height: 20),
              Text("Or Sign Up with",
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
                      size: 60,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
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
                              builder: (context) => const SignInScreen()));
                    },
                    child: const Text(
                      "LOGIN",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}