import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/services/user.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginService _service = LoginService();

  bool isLoading = false;
  String? errorMessage;

  Future<String?> login(String mobile, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await _service.login(mobile: mobile, password: password);

      if (response.statusCode == 200) {
        return response.data['access_token']; // or handle full response
      } else {
        errorMessage = 'فشل تسجيل الدخول';
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        print("Login failed: 403 Forbidden");
        errorMessage = 'تم رفض الدخول: غير مصرح به';
      } else {
        print("Error during login: ${e.message}");
        errorMessage = e.toString();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return null;
  }
}
