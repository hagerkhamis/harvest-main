import 'package:hatvest/core/utils/book_url_helper.dart';

class DigitalBook {
  final String title;
  final String link;

  DigitalBook({required this.title, required this.link});

  factory DigitalBook.fromJson(Map<String, dynamic> json) {
    return DigitalBook(
      title: json['title']?.toString() ?? '',
      link: BookUrlHelper.normalize(json['link']?.toString() ?? ''),
    );
  }
}
