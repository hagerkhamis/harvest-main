class CertificateResponse {
  final List<Certificate> certificates;
  final String message;

  CertificateResponse({
    required this.certificates,
    required this.message,
  });

  factory CertificateResponse.fromJson(Map<String, dynamic> json) {
    List certificatesList = [];
    if (json['certificates'] is List) {
      certificatesList = json['certificates'];
    } else if (json['extra_item'] is Map) {
      certificatesList = [json['extra_item']];
    } else if (json['extra_item'] is List) {
      certificatesList = json['extra_item'];
    }

    return CertificateResponse(
      certificates: certificatesList
          .where((e) => e is Map)
          .map((e) => Certificate.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      message: json['message'] ?? '',
    );
  }
}

class Certificate {
  final int id;
  final String displayName;
  final String pdf;
  final String status;
  final String image;
  final String serial;
  final String certificateRequestUrl;

  Certificate({
    required this.id,
    required this.displayName,
    required this.pdf,
    required this.status,
    required this.image,
    required this.serial,
    required this.certificateRequestUrl,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      displayName: json['display_name'] ?? json['name'] ?? json['Track'] ?? '',
      pdf: json['pdf'] ?? '',
      status: json['status'] ?? '',
      image: json['image'] ?? '',
      serial: json['serial'] ?? '',
      certificateRequestUrl: json['certificate_request_url'] ?? '',
    );
  }
}
