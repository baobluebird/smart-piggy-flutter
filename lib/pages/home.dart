import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:smart_piggy/screens/piggy.dart';
import 'package:smart_piggy/screens/user.dart';
import 'package:http/http.dart' as http;

import '../connections/ip.dart';
import '../screens/chart.dart';
import '../screens/log_send_money.dart';
import '../services/login.dart';
import 'login.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final myBox = Hive.box('myBox');
  late String storedToken;
  var Tabs = [];
  int currentTabIndex = 0;
  String serverMessage = '';
  String _nameUser = '';
  Uint8List? _image;
  String _idUser = '';

  Future<void> clearHiveBox(String boxName) async {
    var box = await Hive.openBox(boxName);
    await box.clear();
  }

  Future<Uint8List?> getImageFromServer(String id) async {
    var url = 'http://$ip:3003/api/user/get-image/$id';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      List<int> byteData =
      List<int>.from(jsonResponse['image']['data']['data']);

      Uint8List imageData = Uint8List.fromList(byteData);

      setState(() {
        _image = imageData;
      });

      return imageData;
    } else {
      print('Failed to load image: ${response.statusCode}');
      return null;
    }
  }


  Future<void> _logout(String token) async {
    try {
      final Map<String, dynamic> response = await LogoutService.logout(token);

      print('Response status: ${response['status']}');
      print('Response body: ${response['message']}');
      if (response['status'] == "OK") {
        setState(() {
          serverMessage = response['message'];
        });
        print(serverMessage);
      } else if (mounted) {
        setState(() {
          serverMessage = response['message'];
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          serverMessage = 'Error: $error';
        });
        print('Error: $error');
        print(serverMessage);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _nameUser = myBox.get('name', defaultValue: '');
    _idUser = myBox.get('id', defaultValue: '');
    getImageFromServer(_idUser);
    Tabs = [
      PiggyScreen(),
      LogSendMoneyScreen(),
      UserScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Smart Piggy'),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _image != null
                        ? CircleAvatar(
                      radius: 40,
                      backgroundImage: MemoryImage(_image!),
                      backgroundColor: Colors.red,
                    )
                        : const CircleAvatar(
                      radius: 50,
                      backgroundImage:
                      NetworkImage('https://i.stack.imgur.com/l60Hf.png'),
                      backgroundColor: Colors.red,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _nameUser,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('User'),
                leading: const Icon(Icons.person),
                onTap: () async {

                },
              ),
              ListTile(
                title: const Text('Log out'),
                leading: const Icon(
                  Icons.logout,
                ),
                onTap: () async {
                  storedToken = await myBox.get('token', defaultValue: '');
                  if (storedToken != '') {
                    await _logout(storedToken);
                    await clearHiveBox('myBox');
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logout successfully'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
              ),
            ],
          ),
        ),
        body: Tabs[currentTabIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentTabIndex,
          onTap: (currentIndex) {
            setState(() {
              currentTabIndex = currentIndex;
            });
          },
          selectedLabelStyle: const TextStyle(color: Colors.black45),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.remove_red_eye),
              label: 'Log',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'User',
            ),
          ],
        ),
      ),
    );
  }
}

