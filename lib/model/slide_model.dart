class SlideModel {
  final String id;
  final String title;
  final String text;
  final String lang;
  final String link;
  final String image;
  final String bkImage;

  SlideModel({
    required this.id,
    required this.title,
    required this.text,
    required this.lang,
    required this.link,
    required this.image,
    required this.bkImage,
  });

  factory SlideModel.fromJson(Map<String, dynamic> json) {
    return SlideModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      lang: json['lang']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      bkImage: json['bk_image']?.toString() ?? '',
    );
  }
}
