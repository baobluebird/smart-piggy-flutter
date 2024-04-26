import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../services/saving.dart';

class LogSendMoneyScreen extends StatefulWidget {
  const LogSendMoneyScreen({Key? key});

  @override
  State<LogSendMoneyScreen> createState() => _LogSendMoneyScreenState();
}

class _LogSendMoneyScreenState extends State<LogSendMoneyScreen> {
  String _idUser = '';
  List<dynamic> _moneySendList = [];
  List<dynamic> _formattedMoneySendList = [];
  final myBox = Hive.box('myBox');

  Future<Map<String, dynamic>> _getPiggyData() async {
    final Map<String, dynamic> response =
    await GetLogMoneySendService.getLogMoneySend(_idUser);
    return response;
  }

  @override
  void initState() {
    super.initState();
    _idUser = myBox.get('id', defaultValue: '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _getPiggyData(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              final Map<String, dynamic> response = snapshot.data!;
              print(response);
              if (response['data'] != null) {
                _moneySendList = response['data'];
                _formattedMoneySendList = _formatMoneySendList(_moneySendList);
              } else {
                _moneySendList = [];
                _formattedMoneySendList = [];
              }
              return _moneySendList.isNotEmpty
                  ? SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: _formattedMoneySendList.map((log) {
                      return Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Money: ${log['money']}',
                              style:
                              TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text('Time: ${log['formattedTime']}'),
                            SizedBox(height: 4),
                            Text('ID: ${log['_id']}'),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )
                  : Center(
                child: Text('No data to display'),
              );
            }
          }
        },
      ),
    );
  }

  List<dynamic> _formatMoneySendList(List<dynamic> moneySendList) {
    return moneySendList.map((log) {
      final time = DateTime.parse(log['time']);
      final formattedTime = DateFormat.yMd().add_Hms().format(time);
      return {
        ...log,
        'formattedTime': formattedTime,
      };
    }).toList();
  }
}
