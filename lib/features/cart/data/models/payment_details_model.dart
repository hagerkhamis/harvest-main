class PaymentDetailsResponse {
  final bool success;
  final PaymentData? data;

  PaymentDetailsResponse({required this.success, this.data});

  factory PaymentDetailsResponse.fromJson(Map<String, dynamic> json) {
    return PaymentDetailsResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? PaymentData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PaymentData {
  final int id;
  final double totalPrice;
  final String paymentStatus;
  final String platform;
  final String createdAt;
  final Lead? lead;
  final List<Payment> payments;

  PaymentData({
    required this.id,
    required this.totalPrice,
    required this.paymentStatus,
    required this.platform,
    required this.createdAt,
    required this.lead,
    required this.payments,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      id: json['id'] ?? 0,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      paymentStatus: json['payment_status'] ?? "",
      platform: json['platform'] ?? "",
      createdAt: json['created_at'] ?? "",
      lead: json['lead'] != null
          ? Lead.fromJson(json['lead'] as Map<String, dynamic>)
          : null,
      payments: (json['payments'] as List<dynamic>? ?? [])
          .map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Lead {
  final int id;
  final String nameEn;
  final String nameAr;
  final String mobile1;
  final String email;
  final String customerType;

  Lead({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.mobile1,
    required this.email,
    required this.customerType,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] ?? 0,
      nameEn: json['name_en'] ?? "",
      nameAr: json['name_ar'] ?? "",
      mobile1: json['mobile_1'] ?? "",
      email: json['email'] ?? "",
      customerType: json['customer_type'] ?? "",
    );
  }
}

class Payment {
  final int id;
  final String amount;
  final String discount;
  final String rest;
  final String paymentStatus;
  final String paymentMethod;
  final String platform;
  final String createdAt;
  final List<SubPayment> subPayments;

  Payment({
    required this.id,
    required this.amount,
    required this.discount,
    required this.rest,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.platform,
    required this.createdAt,
    required this.subPayments,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      amount: json['amount'] ?? "",
      discount: json['discount'] ?? "",
      rest: json['rest'] ?? "",
      paymentStatus: json['payment_status'] ?? "",
      paymentMethod: json['payment_method'] ?? "",
      platform: json['platform'] ?? "",
      createdAt: json['created_at'] ?? "",
      subPayments: (json['sub_payments'] as List<dynamic>? ?? [])
          .map((e) => SubPayment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SubPayment {
  final int id;
  final String leadPaymentId;
  final String amount;
  final String? paymentMethodId;
  final dynamic referenceNum;
  final dynamic uploadBill;
  final DateTime? dueDate;
  final String paid;
  final DateTime? paymentDate;
  final String? branchId;
  final String? employeeId;
  final String? ownerId;
  final dynamic paymentStatus;
  final dynamic paymentMethod;
  final dynamic merchantRefNumber;
  final dynamic fawryFees;
  final String type;
  final String count;
  final String delayFees;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;

  SubPayment({
    required this.id,
    required this.leadPaymentId,
    required this.amount,
    required this.paymentMethodId,
    required this.referenceNum,
    required this.uploadBill,
    required this.dueDate,
    required this.paid,
    required this.paymentDate,
    required this.branchId,
    required this.employeeId,
    required this.ownerId,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.merchantRefNumber,
    required this.fawryFees,
    required this.type,
    required this.count,
    required this.delayFees,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory SubPayment.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null || value.toString().isEmpty) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    return SubPayment(
      id: json["id"] ?? 0,
      leadPaymentId: json["lead_payment_id"]?.toString() ?? "",
      amount: json["amount"]?.toString() ?? "",
      paymentMethodId: json["payment_method_id"]?.toString(),
      referenceNum: json["reference_num"],
      uploadBill: json["upload_bill"],
      dueDate: parseDate(json["due_date"]),
      paid: json["paid"]?.toString() ?? "",
      paymentDate: parseDate(json["payment_date"]),
      branchId: json["branch_id"]?.toString(),
      employeeId: json["employee_id"]?.toString(),
      ownerId: json["owner_id"]?.toString(),
      paymentStatus: json["payment_status"],
      paymentMethod: json["paymentMethod"] ?? "",
      merchantRefNumber: json["merchantRefNumber"],
      fawryFees: json["fawryFees"],
      type: json["type"]?.toString() ?? "",
      count: json["count"]?.toString() ?? "",
      delayFees: json["delay_fees"]?.toString() ?? "",
      createdAt: parseDate(json["created_at"]),
      updatedAt: parseDate(json["updated_at"]),
      deletedAt: json["deleted_at"],
    );
  }
}
