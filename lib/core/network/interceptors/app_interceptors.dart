import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hatvest/core/constants/api_constant.dart';

class AppInterceptors extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('lang') ?? 'ar';

    options.headers.addAll({
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Accept-Language': lang,
    });

    options.headers['User-Agent'] = Platform.isIOS ? 'ios' : 'android';

    if (options.headers.containsKey("requiresToken")) {
      options.headers.remove("requiresToken");
      final token = prefs.getString('auth_token');
      if (token != null && token.isNotEmpty && token != "null") {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    // Handle sendType header (e.g. for offers online/offline)
    if (options.headers.containsKey('sendType')) {
      final typeValue = options.headers['sendType'];
      options.headers.remove('sendType');
      if (typeValue == 'online' || typeValue == 'offline') {
        options.headers['type'] = typeValue;
      }
    }

    if (!options.path.startsWith('http')) {
      options.baseUrl = ApiConstants.baseUrl;
    }
    
    print("🚀 Request: ${options.method} ${options.baseUrl}${options.path}");
    print("📂 Headers: ${options.headers}");
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print("✅ Response [${response.statusCode}] from ${response.requestOptions.path}");
    String body = response.data.toString();
    if (body.length > 200) body = body.substring(0, 200);
    print("📄 Body: $body");
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print("❌ Error [${err.response?.statusCode}] from ${err.requestOptions.path}");
    print("📄 Error Data: ${err.response?.data}");
    handler.next(err);
  }
}


// class AppInterceptors extends Interceptor {
//   @override
//   Future<void> onRequest(
//       RequestOptions options, RequestInterceptorHandler handler) async {
//     // Add default headers
//     options.headers.addAll({
//       'Accept': 'application/json',
//       'Content-Type': 'application/json',
//       'User-Agent': 'PostmanRuntime/7.32.2',
//     });


//     if (options.headers.containsKey('sendUserAgent')) {
//       options.headers
//           .remove('sendUserAgent'); 

//       // Detect platform
//       String userAgent = 'unknown';
//       if (Platform.isAndroid) {
//         userAgent = 'android';
//       } else if (Platform.isIOS) {
//         userAgent = 'ios';
//       }

//       options.headers['User-Agent'] = userAgent;
//     }

//     // Add type header if requested
//     if (options.headers.containsKey('sendType')) {
//       final typeValue = options.headers['sendType'];
//       options.headers.remove('sendType');

//       // Validate the value if you want, or just send it
//       if (typeValue == 'online' || typeValue == 'offline') {
//         options.headers['type'] = typeValue;
//       }
//     }

//     // Authorization token logic, if needed
//     if (options.headers.containsKey("requiresToken")) {
//       options.headers.remove("requiresToken");
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('auth_token');
//       print('Auth Token: $token'); // Print token

//       if (token != null && token.isNotEmpty) {
//         options.headers['Authorization'] = 'Bearer $token';
//       }
//     }



//     options.baseUrl = ApiConstants.baseUrl;
//     handler.next(options);
//   }

//   @override
//   void onResponse(Response response, ResponseInterceptorHandler handler) {
//     super.onResponse(response, handler);
//   }

//   @override
//   void onError(DioError err, ErrorInterceptorHandler handler) {
//     super.onError(err, handler);
//   }
// }
