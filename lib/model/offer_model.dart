class Course {
  final String id;
  final String title;
  final List<Offer> offers;

  Course({
    required this.id,
    required this.title,
    required this.offers,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      offers: (json['offers'] as List?)
              ?.map((offerJson) => Offer.fromJson(offerJson))
              .toList() ??
          [],
    );
  }
}

class Offer {
  final String id;
  final String image;
  final String courseTitle;
  final String title;
  final String titleEn;
  final String titleAr;
  final String itemType;
  final String fees;
  final String oldFees;
  final String desc;
  final String track;

  const Offer({
    required this.id,
    required this.image,
    required this.courseTitle,
    required this.title,
    required this.titleEn,
    required this.titleAr,
    required this.itemType,
    required this.fees,
    required this.oldFees,
    required this.desc,
    this.track = '',
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    String itype = json['item_type']?.toString() ?? '';
    if (itype.isEmpty) {
      // Smart fallback: most offers are courses
      itype = 'course';
    }
    return Offer(
      id: json['id']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      courseTitle: json['course_title']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      titleEn: json['title_en']?.toString() ?? '',
      titleAr: json['title_ar']?.toString() ?? '',
      itemType: itype,
      fees: json['fees']?.toString() ?? '',
      oldFees: json['old_fees']?.toString() ?? '',
      desc: json['desc']?.toString() ?? '',
      track: json['track']?.toString() ?? '',
    );
  }
}
