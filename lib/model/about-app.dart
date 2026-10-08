class PageData {
  final int id;
  final String titleAr;
  final String textAr;
  final String titleEn;
  final String textEn;

  PageData({
    required this.id,
    required this.titleAr,
    required this.textAr,
    required this.titleEn,
    required this.textEn,
  });

  factory PageData.fromJson(Map<String, dynamic> json) {
    return PageData(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      titleAr: json['title_ar'] ?? json['title'] ?? '',
      textAr: json['text_ar'] ?? json['content'] ?? '',
      titleEn: json['title_en'] ?? json['title_ar'] ?? json['title'] ?? '',
      textEn: json['text_en'] ?? json['text_ar'] ?? json['content'] ?? '',
    );
  }
}

class AboutResponse {
  final List<PageData> pages;
  final String facebook;
  final String linkedin;
  final String youtube;
  final String instagram;
  final String twitter;
  final String tiktok;

  AboutResponse({
    required this.pages,
    required this.facebook,
    required this.linkedin,
    required this.youtube,
    required this.instagram,
    required this.twitter,
    required this.tiktok,
  });

  factory AboutResponse.fromJson(Map<String, dynamic> json) {
    List pageList = [];
    if (json['page'] is List) {
      pageList = json['page'];
    } else if (json['page'] is Map) {
      pageList = [json['page']];
    }

    return AboutResponse(
      pages: pageList
          .where((e) => e is Map)
          .map((e) => PageData.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      facebook: json['facebook'] ?? '',
      linkedin: json['linkedin'] ?? '',
      youtube: json['youtube'] ?? '',
      instagram: json['instagram'] ?? '',
      twitter: json['twitter'] ?? '',
      tiktok: json['tiktok'] ?? '',
    );
  }
}
