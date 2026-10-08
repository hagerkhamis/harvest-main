import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hatvest/core/constants/api_constant.dart';
import 'package:hatvest/core/network/dio_client.dart';
import 'package:hatvest/features/auth/data/models/auth_response_model.dart'
    show AuthResponseModel;
import 'package:hatvest/features/auth/data/models/authenticate_model.dart';
import 'package:hatvest/features/auth/data/models/signup_model.dart';
import 'package:hatvest/features/auth/data/models/user_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = dioClient;
  // AuthService._privateConstructor() {
  //   _dio.interceptors.add(AppInterceptors());
  // }
  // static final AuthService instance = AuthService._privateConstructor();
  bool bioAuthShow = false;

  Future<UserResponse> signIn(AuthenticateModel body) async {
    try {
      print("Login Request Data: ${body.toJson()}");
      final response = await _dio.post(
        "${ApiConstants.baseUrl}${ApiConstants.login}",
        data: body.toJson(),
      );
      print("Login Response Status: ${response.statusCode}");
      print("Login Response Data: ${response.data}");

      if (response.statusCode == 200) {
        final rawData = response.data;
        final data = rawData is String ? jsonDecode(rawData) : rawData;

        if (data is Map<String, dynamic>) {
          final message = data['message']?.toString() ?? '';
          if (message.toLowerCase().contains('unauthor') ||
              response.statusCode == 401) {
            throw "un_auth_error";
          }

          final token = data['access_token'];
          if (token == null || token.toString().isEmpty) {
            throw message.isNotEmpty
                ? message
                : "حدث خطأ اثناء العملية، الرجاء إعادة المحاولة";
          }

          final prefs = await SharedPreferences.getInstance();
          if (token != null) {
            await prefs.setString('auth_token', token.toString());
          }

          // 🔹 Save mobile_1 for refreshToken use
          if (data['lead'] != null && data['lead']['mobile_1'] != null) {
            await prefs.setString('mobile', data['lead']['mobile_1'].toString());
          }
          return UserResponse.fromJson(data);
        }

        throw "حدث خطأ اثناء العملية، الرجاء إعادة المحاولة";
      }

      throw "حدث خطأ اثناء العملية، الرجاء إعادة المحاولة";
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response!.data;
        print("Status Code: ${e.response!.statusCode}");
        print("Response Data: $responseData");

        if (e.response!.statusCode == 401 ||
            e.response!.statusCode == 403 ||
            (responseData is Map<String, dynamic> &&
                responseData['message']
                    .toString()
                    .toLowerCase()
                    .contains('unauthor'))) {
          throw "un_auth_error";
        }

        if (responseData is Map<String, dynamic> &&
            responseData['message'] != null) {
          throw responseData['message'].toString();
        }
      } else {
        print("Dio error: ${e.message}");
      }
      throw "حدث خطأ اثناء العملية، الرجاء إعادة المحاولة";
    }
  }

  Future<UserResponse> googleSignIn({
    required String email,
    required String name,
    required String phone,
    required String idToken,
    String? accessToken,
  }) async {
    try {
      final response = await _dio.post(
        "${ApiConstants.baseUrl}${ApiConstants.googleLogin}",
        data: jsonEncode({
          'email': email,
          'name': name,
          'mobile_1': phone,
          'phone': phone,
          'id_token': idToken,
          'token_id': idToken,
          'access_token': accessToken,
          'provider': 'google',
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['message'] == 'Unauthorised') {
          throw "un_auth_error";
        }

        final token = data['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        if (data['lead'] != null && data['lead']['mobile_1'] != null) {
          await prefs.setString('mobile', data['lead']['mobile_1']);
        }

        return UserResponse.fromJson(data);
      }
      throw "حدث خطأ اثناء العملية، الرجاء إعادة المحاولة";
    } on DioException catch (e) {
      if (e.response != null) {
        print("Status Code: ${e.response!.statusCode}");
        print("Response Data: ${e.response!.data}");

        if (e.response!.statusCode == 401 ||
            e.response!.data['message'] == 'Unauthorised') {
          throw "un_auth_error";
        }
      } else {
        print("Dio error: ${e.message}");
      }
      throw "حدث خطأ اثناء العملية، الرجاء إعادة المحاولة";
    }
  }

  Future<UserResponse> appleSignIn({
    required String identityToken,
    String? fName,
    String? lName,
    String? deviceToken,
  }) async {
    try {
      final response = await _dio.post(
        "${ApiConstants.baseUrl}${ApiConstants.appleLogin}",
        data: jsonEncode({
          'identityToken': identityToken,
          if (fName != null) 'f_name': fName,
          if (lName != null) 'l_name': lName,
          if (deviceToken != null) 'device_token': deviceToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['message'] == 'Unauthorised') {
          throw "un_auth_error";
        }

        final token = data['access_token'];
        final prefs = await SharedPreferences.getInstance();
        if (token != null) {
          await prefs.setString('auth_token', token.toString());
        }

        if (data['lead'] != null && data['lead']['mobile_1'] != null) {
          await prefs.setString('mobile', data['lead']['mobile_1'].toString());
        }

        return UserResponse.fromJson(data);
      }
      throw "حدث خطأ اثناء العملية، الرجاء إعادة المحاولة";
    } on DioException catch (e) {
      if (e.response != null) {
        print("Status Code: ${e.response!.statusCode}");
        print("Response Data: ${e.response!.data}");

        if (e.response!.statusCode == 401 ||
            (e.response!.data is Map && e.response!.data['message'] == 'Unauthorised')) {
          throw "un_auth_error";
        }
      } else {
        print("Dio error: ${e.message}");
      }
      throw "حدث خطأ اثناء العملية، الرجاء إعادة المحاولة";
    }
  }

  Future<bool> signUp(SignupModel body) async {
    try {
      final response = await _dio.post(
        "${ApiConstants.baseUrl}${ApiConstants.register}",
        data: body.toJson(),
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      // ✅ Case 1: Server actually sends an error with 422
      if (response.statusCode == 422) {
        final message = response.data["message"] ?? "حدث خطأ اثناء العملية";
        throw message;
      }

      if (response.statusCode == 200) {
        final data = response.data;
        print("Registration Response: $data");

        if (data is Map<String, dynamic>) {
          if (data['status'] == false || data['success'] == false) {
            throw data['message'] ?? "فشل التسجيل";
          }

          if (data.containsKey("message") &&
              data["access_token"] == null &&
              data["token"] == null) {
            final msg = data['message'].toString().toLowerCase();
            if (msg.contains('error') || msg.contains('failed') || msg.contains('exists')) {
              throw data['message'];
            }
          }

          // Save access_token from registration response
          if (data.containsKey('access_token') && data['access_token'] != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('auth_token', data['access_token'].toString());
            print("✅ Token saved after registration");
          }
        }
        return true;
      }

      throw "حدث خطأ اثناء العملية, الرجاء اعادة المحاولة";
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 422) {
          final message =
              e.response!.data["message"] ?? "حدث خطأ اثناء العملية";
          throw message;
        }
        if (e.response!.statusCode == 401) {
          throw "un_auth_error";
        }
      }
      throw "حدث خطأ اثناء العملية, الرجاء اعادة المحاولة";
    }
  }

  //
  Future<AuthResponseModel?> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mobile = prefs.getString('mobile') ?? '';

      if (mobile.isEmpty) return null;

      final response = await _dio.post(
        "${ApiConstants.baseUrl}${ApiConstants.refresh}",
        data: {"mobile": mobile, "device_token": ""},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        dynamic rawData = response.data;
        while (rawData is String) {
          try {
            rawData = jsonDecode(rawData);
          } catch (_) {
            break;
          }
        }
        
        Map<String, dynamic> data;
        if (rawData is Map) {
          data = Map<String, dynamic>.from(rawData);
        } else if (rawData is List && rawData.isNotEmpty) {
          data = Map<String, dynamic>.from(rawData[0]);
        } else {
          return null;
        }

        // Save token for future requests
        if (data.containsKey('access_token')) {
          await prefs.setString('auth_token', data['access_token'].toString());
          return AuthResponseModel.fromJson(data);
        }
      }
    } catch (e) {
      print("Error refreshing token: $e");
    }
    return null;
  }

  //
  Future<void> newPassword({
    required String mobile,
    required String password,
    required String passwordConfirmation,
    String? code,
  }) async {
    try {
      final payload = {
        "mobile_1": mobile,
        "password": password,
        "password_confirmation": passwordConfirmation,
      };

      if (code != null && code.isNotEmpty) {
        payload["code"] = code;
      }

      final response = await _dio.post(
        "${ApiConstants.baseUrl}${ApiConstants.newPassword}",
        data: payload,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to change password");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  //
  //>> resendOtp
  Future<void> resendOtp(String mobile) async {
    try {
      await _dio.post("${ApiConstants.baseUrl}${ApiConstants.resendOtp}",
          data: jsonEncode({
            "mobile_1": mobile,
          }),
          options: Options(
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ));
    } catch (e) {
      throw Exception("Error resending OTP: $e");
    }
  }

  //>> verifyOtp
  Future<void> verifyOtp(String mobile, String code) async {
    try {
      await _dio.post("${ApiConstants.baseUrl}${ApiConstants.mobileVerify}",
          data: jsonEncode({
            "mobile_1": mobile,
            "code": code,
          }),
          options: Options(
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ));
    } catch (e) {
      throw Exception("Error verifying mobile: $e");
    }
  }

  //>> setNewPassword
  Future<void> setNewPassword(
      String mobile,
      String password,
      String passwordConfirmation,
      {
        String? code,
      }) async {
    await newPassword(
      mobile: mobile,
      password: password,
      passwordConfirmation: passwordConfirmation,
      code: code,
    );
  }

  //>> forgetPassword
  Future<void> forgetPassword(String mobile) async {
    try {
      final response = await _dio.post(
        "${ApiConstants.baseUrl}${ApiConstants.forgetPassword}",
        data: jsonEncode({
          "mobile_1": mobile,
        }),
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to request password reset");
      }
    } catch (e) {
      throw Exception("Error requesting password reset: $e");
    }
  }
  //>>>> email reset

  Future<void> resendEmailOtp(String email) async {
    await _dio
        .post("${ApiConstants.baseUrl}${ApiConstants.forgetEmailPassword}",

            // "https://testsys.harvestcollege.co.uk//forget_email_password",
            data: {
          "email": email,
        });
  }

  //>> verifyEmailOtp
  Future<void> verifyEmailOtp(String email, String code) async {
    await _dio.post("${ApiConstants.baseUrl}${ApiConstants.emailVerify}",
        // "https://testsys.harvestcollege.co.uk//email_verify",
        data: {
          "email": email,
          "code": code,
        });
  }

  //>> setNewEmailPassword
  Future<void> setNewEmailPassword(
      String email, String password, String passwordConfirmation) async {
    await _dio
        .post("${ApiConstants.baseUrl}${ApiConstants.postNewPasswordEmail}",
            // "https://testsys.harvestcollege.co.uk//post_new_password_email",
            data: {
          "email": email,
          "password": password,
          "password_confirmation": passwordConfirmation,
        });
  }
}
