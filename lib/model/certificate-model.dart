import 'package:hatvest/core/utils/certificate_image_helper.dart';

class CertificateModel {
  final int id;
  final String track;
  final String name;
  final String fullDesc;
  final String price;
  final String image;
  final String itemType;
  final String paymentPlan;
  final String appleId;
  final String category;

  CertificateModel({
    required this.id,
    required this.track,
    required this.name,
    required this.fullDesc,
    required this.price,
    required this.image,
    required this.itemType,
    required this.paymentPlan,
    required this.appleId,
    required this.category,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      track: json['Track']?.toString() ?? json['track']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      fullDesc: json['full_desc']?.toString() ?? json['desc']?.toString() ?? '',
      price: json['price']?.toString() ?? json['fees']?.toString() ?? '0',
      image: CertificateImageHelper.fromJson(json),
      itemType: json['item_type']?.toString() ?? '',
      paymentPlan: json['payment_plan']?.toString() ?? '',
      appleId: json['apple_id']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
    );
  }
}
