import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../connections/ip.dart';


class SignInService {
  static Future<Map<String, dynamic>> signIn(String email, String password) async {
    final Map<String, dynamic> requestBody = {
      "email": email,
      "password": password,
    };

    try {
      final response = await http.post(
        Uri.parse('$ip/api/user/sign-in'),
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody;
      } else {
        // Handle other status codes (e.g., display an error message)
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

class SignUpService {
  static Future<Map<String, dynamic>> signUp(String name, String email, String date,  String password, String confirmPassword, File? image) async {
    final url = Uri.parse('$ip/api/user/sign-up');
    final request = http.MultipartRequest('POST', url);

    request.files.add(await http.MultipartFile.fromPath('image', image!.path));
    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['date'] = date;
    request.fields['password'] = password;
    request.fields['confirmPassword'] = confirmPassword;

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final decodedResponse = json.decode(responseBody);
        return {'status':decodedResponse['status'], 'message': decodedResponse['message']};
      } else {
        print('Error: ${response.statusCode}');
        return {'status': 'error', 'message': 'Server error'};
      }
    } catch (error) {
      print('Error: $error');
      return {'status': 'error', 'message': 'Network error'};
    }
  }
}

class ForgotPasswordService {
  static Future<Map<String, dynamic>> sendEmail(String email) async {
    final Map<String, dynamic> requestBody = {
      "email": email,
    };

    try {
      final response = await http.post(
        Uri.parse('$ip/api/user/forgot-password'),
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody;
      } else {
        // Handle other status codes (e.g., display an error message)
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

class VerifyCodeService {
  static Future<Map<String, dynamic>> verifyCode(String code) async {
    final Map<String, dynamic> requestBody = {
      "code": code,
    };
    try {
      final response = await http.post(
        Uri.parse('$ip/api/user/verify-code'),
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody;
      } else {
        // Handle other status codes (e.g., display an error message)
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

class ResetPassService {
  static Future<Map<String, dynamic>> resetPass(String idUser, String password, String confirmPassword) async {
    final Map<String, dynamic> requestBody = {
      "password": password,
      "confirmPassword": confirmPassword,
    };
    var url = '$ip/api/user/update-pass/$idUser';
    print(url);
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody;
      } else {
        // Handle other status codes (e.g., display an error message)
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

class DecodeTokenService {
  static Future<Map<String, dynamic>> decodeToken(String token) async {
    final Map<String, dynamic> requestBody = {
      "token": token,
    };
    var url = '$ip/api/user/send-token';
    print(url);
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody;
      } else {
        // Handle other status codes (e.g., display an error message)
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

class LogoutService {
  static Future<Map<String, dynamic>> logout(String token) async {
    final Map<String, dynamic> requestBody = {
      "token": token,
    };
    var url = '$ip/api/user/log-out';
    print(url);
    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody;
      } else {
        // Handle other status codes (e.g., display an error message)
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

class UpdateUserService {
  static Future<Map<String, dynamic>> updateUser(String id, String name, File? image) async {

    final url = Uri.parse('$ip/api/user/update-user/$id');
    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('image', image!.path));
    request.fields['name'] = name;

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final decodedResponse = json.decode(responseBody);
        return {'status':decodedResponse['status'], 'message': decodedResponse['message']};
      } else {
        print('Error: ${response.statusCode}');
        return {'status': 'error', 'message': 'Server error'};
      }
    } catch (error) {
      print('Error: $error');
      return {'status': 'error', 'message': 'Network error'};
    }
  }
}