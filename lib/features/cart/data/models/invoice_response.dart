class InvoiceResponse {
  final List<Invoice> invoices;
  final String message;

  InvoiceResponse({required this.invoices, required this.message});

  factory InvoiceResponse.fromJson(Map<String, dynamic> json) {
    return InvoiceResponse(
      invoices: (json['Invoices'] as List)
          .map((e) => Invoice.fromJson(e))
          .toList(),
      message: json['message'] ?? '',
    );
  }
}

class Invoice {
  final int id;
  final String branchName;
  final String totalPrice;
  final String? totalDiscount;
  final String paymentMethod;
  final String referenceNum;
  final String uploadBill;
  final String paymentStatus;
  final String merchantRefNumber;
  final String createdAt;
  final List<LeadPayment>? leadPayments;

  Invoice({
    required this.id,
    required this.branchName,
    required this.totalPrice,
    this.totalDiscount,
    required this.paymentMethod,
    required this.referenceNum,
    required this.uploadBill,
    required this.paymentStatus,
    required this.merchantRefNumber,
    required this.createdAt,
    this.leadPayments,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      branchName: json['branch_name'] ?? '',
      totalPrice: json['total_price'] ?? '',
      totalDiscount: json['total_discount'],
      paymentMethod: json['payment_method'] ?? '',
      referenceNum: json['reference_num'] ?? '',
      uploadBill: json['upload_bill'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      merchantRefNumber: json['merchantRefNumber'] ?? '',
      createdAt: json['created_at'] ?? '',
      leadPayments: json['lead_payments'] != null
          ? (json['lead_payments'] as List)
              .map((e) => LeadPayment.fromJson(e))
              .toList()
          : [],
    );
  }
}

class LeadPayment {
  final String id;
  final String? type;
  final String uploadBill;
  final String typeTitle;
  final String amount;
  final String? discount;
  final String rest;
  final String paymentPlan;
  final String includeBooks;
  final List<SubPayment>? subPayments;

  LeadPayment({
    required this.id,
    this.type,
    required this.uploadBill,
    required this.typeTitle,
    required this.amount,
    this.discount,
    required this.rest,
    required this.paymentPlan,
    required this.includeBooks,
    this.subPayments,
  });

  factory LeadPayment.fromJson(Map<String, dynamic> json) {
    return LeadPayment(
      id: json['id'] ?? '',
      type: json['type'],
      uploadBill: json['upload_bill'] ?? '',
      typeTitle: json['type_title'] ?? '',
      amount: json['amount'] ?? '',
      discount: json['discount'],
      rest: json['rest'] ?? '',
      paymentPlan: json['payment_plan'] ?? '',
      includeBooks: json['include_books'] ?? '',
      subPayments: json['sub_payment'] != null
          ? (json['sub_payment'] as List)
              .map((e) => SubPayment.fromJson(e))
              .toList()
          : [],
    );
  }
}

class SubPayment {
  final String id;
  final String amount;
  final String paymentMethod;
  final String referenceNum;
  final String uploadBill;
  final String dueDate;
  final String paid;
  final String paymentDate;

  SubPayment({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.referenceNum,
    required this.uploadBill,
    required this.dueDate,
    required this.paid,
    required this.paymentDate,
  });

  factory SubPayment.fromJson(Map<String, dynamic> json) {
    return SubPayment(
      id: json['id']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      referenceNum: json['reference_num']?.toString() ?? '',
      uploadBill: json['upload_bill']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',
      paid: json['paid']?.toString() ?? '',
      paymentDate: json['payment_date']?.toString() ?? '',
    );
  }
}
