class GetHelpItem {
  final int id;
  final String titleAr;
  final String textAr;
  final String titleEn;
  final String textEn;
  final String image;

  GetHelpItem({
    required this.id,
    required this.titleAr,
    required this.textAr,
    required this.titleEn,
    required this.textEn,
    required this.image,
  });

  factory GetHelpItem.fromJson(Map<String, dynamic> json) {
    return GetHelpItem(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      titleAr: json['title_ar'] ?? json['title'] ?? '',
      textAr: json['text_ar'] ?? json['content'] ?? '',
      titleEn: json['title_en'] ?? json['title'] ?? '',
      textEn: json['text_en'] ?? json['content'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class GetHelpResponse {
  final String onlineDesc;
  final String offlineDesc;
  final List<GetHelpItem> items;

  GetHelpResponse({
    required this.onlineDesc,
    required this.offlineDesc,
    required this.items,
  });

  factory GetHelpResponse.fromJson(Map<String, dynamic> json) {
    return GetHelpResponse(
      onlineDesc: json['online_desc'] ?? '',
      offlineDesc: json['offline_desc'] ?? '',
      items: (json['get_help'] as List?)
              ?.map((e) => GetHelpItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }
}
