import 'dart:convert';

SlidesResponse slidesResponseFromJson(String str) =>
    SlidesResponse.fromJson(json.decode(str));

String slidesResponseToJson(SlidesResponse data) => json.encode(data.toJson());

class SlidesResponse {
  List<Slide> slidesShow;

  SlidesResponse({
    required this.slidesShow,
  });

  factory SlidesResponse.fromJson(Map<String, dynamic> json) => SlidesResponse(
        slidesShow:
            List<Slide>.from(json["slides_show"].map((x) => Slide.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "slides_show": List<dynamic>.from(slidesShow.map((x) => x.toJson())),
      };
}

class Slide {
  String id;
  String title;
  String text;
  String lang;
  String link;
  String image;
  String bkImage;

  Slide({
    required this.id,
    required this.title,
    required this.text,
    required this.lang,
    required this.link,
    required this.image,
    required this.bkImage,
  });

  factory Slide.fromJson(Map<String, dynamic> json) => Slide(
        id: json["id"],
        title: json["title"],
        text: json["text"],
        lang: json["lang"],
        link: json["link"] ?? "",
        image: json["image"],
        bkImage: json["bk_image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "text": text,
        "lang": lang,
        "link": link,
        "image": image,
        "bk_image": bkImage,
      };
}
