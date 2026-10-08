import 'package:dio/dio.dart';
import 'package:hatvest/core/network/interceptors/app_interceptors.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio();

    dio.interceptors.add(AppInterceptors());
  }
}

final dioClient = DioClient().dio;
