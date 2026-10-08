// signup_service.dart
import 'package:dio/dio.dart';
import 'package:hatvest/view/page/test-siup/%20branch_model.dart';

class SignUpService {
  final Dio _dio = Dio();
  final String baseUrl = "/"; // Change this

  Future<List<Branch>> getBranches() async {
    final response = await _dio.get(
      "//getbranches",
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': 'PostmanRuntime/7.32.2',
        },
      ),
    );
    List branchesJson = response.data['Branches'] ?? [];
    return branchesJson.map((b) => Branch.fromJson(b)).toList();
  }

  Future<List<Country>> getCountries() async {
    final response = await _dio.get(
      "//getcountry",
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': 'PostmanRuntime/7.32.2',
        },
      ),
    );
    List countriesJson = response.data['Countries'] ?? [];
    return countriesJson.map((c) => Country.fromJson(c)).toList();
  }

  // Future<void> signUp(Map<String, dynamic> data) async {
  //   await _dio.post(
  //     "//register",
  //     data: data,
  //     options: Options(
  //       headers: {
  //         'Accept': 'application/json',
  //         'Content-Type': 'application/json',
  //         'Accept-Language': 'en',
  //         'User-Agent': 'PostmanRuntime/7.32.2',
  //       },
  //     ),
  //   );
  // }

  Future<void> signUp(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        "//register",
        data: data,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'User-Agent': 'PostmanRuntime/7.32.2',
          },
        ),
      );

      print("✅ Signup Response Status: ${response.statusCode}");
      print("✅ Signup Response Data: ${response.data}");
    } on DioException catch (e) {
      print("❌ Signup Error Status: ${e.response?.statusCode}");
      print("❌ Signup Error Data: ${e.response?.data}");
      print("❌ Signup Error Message: ${e.message}");
      rethrow;
    } catch (e) {
      print("❌ Unexpected Error: $e");
      rethrow;
    }
  }
}
