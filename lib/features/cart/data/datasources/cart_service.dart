import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hatvest/core/constants/api_constant.dart';
import 'package:hatvest/core/network/dio_client.dart';
import 'package:hatvest/features/cart/data/models/cart_response.dart';
import 'package:hatvest/features/cart/data/models/invoice_response.dart';
import 'package:hatvest/features/cart/data/models/payment_details_model.dart';

class CartService {
  final Dio _dio = dioClient;

  Future<String> addToCart({
    required String itemId,
    required String itemType,
    String? itemTitleEn,
    String? itemTitleAr,
    String? branchId,
  }) async {
    try {
      final data = {
        "item_id": itemId,
        "item_type": itemType,
        if (itemTitleEn != null) "item_title_en": itemTitleEn,
        if (itemTitleAr != null) "item_title_ar": itemTitleAr,
        if (branchId != null) "branch_id": branchId,
      };

      final response = await _dio.post(
        "${ApiConstants.baseUrl}${ApiConstants.addtocart}",

        // 'https://testsys.harvestcollege.co.uk//addtocart',
        data: data,
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );

      dynamic rawData = response.data;
      while (rawData is String) {
        try {
          rawData = jsonDecode(rawData);
        } catch (e) {
          break;
        }
      }

      if (response.statusCode == 200) {
        if (rawData is Map) {
          final msg = rawData['message']?.toString() ?? '';
          // Some APIs return 200 but with error in message
          if (msg.toLowerCase().contains('error') || msg.toLowerCase().contains('fail')) {
            throw Exception(msg);
          }
          return msg.isNotEmpty ? msg : 'Added to cart';
        }
        return 'Added to cart';
      } else {
        String errorMsg = 'فشل في الإضافة إلى السلة';
        if (rawData is Map && rawData.containsKey('message')) {
          errorMsg = rawData['message']?.toString() ?? errorMsg;
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      print("CartService Error: $e");
      if (e is DioException) {
        print("CartService DioError response: ${e.response?.data}");
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          throw Exception(data['message'].toString());
        }
      }
      rethrow;
    }
  }

//

  Future<List<CartModel>> fetchCart() async {
    try {
      final response = await _dio.get(
        "${ApiConstants.baseUrl}${ApiConstants.showcart}",
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );
      
      dynamic rawData = response.data;
      
      // Recursive decoding in case of double encoding
      while (rawData is String) {
        try {
          rawData = jsonDecode(rawData);
        } catch (e) {
          break;
        }
      }

      if (rawData is Map && rawData.containsKey("cart")) {
        final cartList = rawData["cart"] as List;
        return cartList.map((e) => CartModel.fromJson(e)).toList();
      } else if (rawData is List) {
        return rawData.map((e) => CartModel.fromJson(e)).toList();
      }
      
      return [];
    } catch (e) {
      throw Exception("Failed to load cart: $e");
    }
  }

  Future<List<CartModel>> applyCoupon(String cartId, String code) async {
    try {
      final response = await _dio.post(
        "${ApiConstants.baseUrl}${ApiConstants.addcoupoun}",
        data: {
          "cart_id": cartId,
          "code": code,
        },
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );

      if (response.statusCode == 200) {
        dynamic rawData = response.data;
        while (rawData is String) {
          try {
            rawData = jsonDecode(rawData);
          } catch (e) {
            break;
          }
        }

        if (rawData is Map && rawData.containsKey("cart")) {
          final data = rawData["cart"] as List;
          return data.map((e) => CartModel.fromJson(e)).toList();
        } else if (rawData is List) {
          return rawData.map((e) => CartModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print("Error applying coupon: $e");
    }
    return [];
  }

  //
  Future<InvoiceResponse> fetchInvoices() async {
    final response = await _dio.get(
      "${ApiConstants.baseUrl}${ApiConstants.payments}",
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );
    if (response.statusCode == 200) {
      dynamic rawData = response.data;
      while (rawData is String) {
        try {
          rawData = jsonDecode(rawData);
        } catch (e) {
          break;
        }
      }
      
      if (rawData is Map) {
        return InvoiceResponse.fromJson(Map<String, dynamic>.from(rawData));
      } else if (rawData is List && rawData.isNotEmpty && rawData[0] is Map) {
        // Handle case where it might be wrapped in a list
        return InvoiceResponse.fromJson(Map<String, dynamic>.from(rawData[0]));
      }
      throw Exception('Invalid invoice response format');
    } else {
      throw Exception('Failed to load invoices');
    }
  }

  //
  Future<Map<String, dynamic>?> checkout(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(
        "${ApiConstants.baseUrl}${ApiConstants.fawryPay}",
        data: body,
        options: Options(
          headers: {'requiresToken': true},
        ),
      );

      if (response.statusCode == 200) {
        dynamic rawData = response.data;
        while (rawData is String) {
          try {
            rawData = jsonDecode(rawData);
          } catch (e) {
            break;
          }
        }
        return rawData is Map ? Map<String, dynamic>.from(rawData) : null;
      } else {
        print('Error: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('Exception: $e');
    }
    return null;
  }

  //>>>>>
  Future<PaymentDetailsResponse> fetchPaymentDetails(int id) async {
    final response = await _dio.get(
      "${ApiConstants.baseUrl}${ApiConstants.showPaymentDetails}/$id",
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );

    if (response.statusCode == 200) {
      dynamic rawData = response.data;
      while (rawData is String) {
        try {
          rawData = jsonDecode(rawData);
        } catch (e) {
          break;
        }
      }
      
      if (rawData is Map) {
        return PaymentDetailsResponse.fromJson(Map<String, dynamic>.from(rawData));
      }
      throw Exception("Invalid payment details format");
    } else {
      throw Exception("Failed to load payment details");
    }
  }
}
