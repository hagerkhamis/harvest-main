import 'package:dio/dio.dart';
import 'package:hatvest/constants/api_constant.dart';

class LoginService {
  final Dio _dio = Dio();

  Future<Response> login(
      {required String mobile, required String password}) async {
    try {
      final response = await _dio.post(
        "${ApiConstants.baseUrl}${ApiConstants.login}",

        // 'https://testsys.harvestcollege.co.uk//login',
        data: {
          'mobile': mobile,
          'password': password,
        },
        // options: Options(
        //   headers: {
        //     'Accept': 'application/json',
        //     'Content-Type': 'application/json',
        //   },
        // ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
