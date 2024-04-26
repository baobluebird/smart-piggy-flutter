import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../connections/ip.dart';


class GetTotalMoneyService {
  static Future<Map<String, dynamic>> getTotalMoney(String idUser) async {
    try {
      final response = await http.post(
        Uri.parse('$ip/api/user/get-total-money/$idUser'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody;
      } else {
        print('Error: ${response.statusCode}');
        return {'status': 'error', 'message': 'Server error'};
      }
    } catch (error) {
      // Handle network or other errors
      print('Error: $error');
      return {'status': 'error', 'message': 'Network error'};
    }
  }
}

class GetLogMoneySendService {
  static Future<Map<String, dynamic>> getLogMoneySend(String idUser) async {
    try {
      final response = await http.post(
        Uri.parse('$ip/api/user/get-log-money-send/$idUser'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody;
      } else {
        print('Error: ${response.statusCode}');
        return {'status': 'error', 'message': 'Server error'};
      }
    } catch (error) {
      // Handle network or other errors
      print('Error: $error');
      return {'status': 'error', 'message': 'Network error'};
    }
  }
}