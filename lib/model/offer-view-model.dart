class OfferDetailsModel {
  final Offer offer;
  final String message;

  OfferDetailsModel({required this.offer, required this.message});

  factory OfferDetailsModel.fromJson(Map<String, dynamic> json) {
    return OfferDetailsModel(
      offer: Offer.fromJson(json['Offers']),
      message: json['message'],
    );
  }
}

class Offer {
  final int id;
  final String title;
  final String image;
  final String course;
  final String track;
  final String fees;
  final String titleEn;
  final String titleAr;
  final String itemType;
  //
  final String numLevels;
  final String startDate;
  final String endDate;

  final List<Branch> branches;

  Offer({
    required this.id,
    required this.title,
    required this.image,
    required this.course,
    required this.track,
    required this.fees,
    required this.titleEn,
    required this.titleAr,
    required this.itemType,
    //
    required this.numLevels,
    required this.startDate,
    required this.endDate,
    required this.branches,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'],
      title: json['title'],
      image: json['image'] ?? '',
      course: json['course'] ?? '',
      track: json['track'] ?? '',
      fees: json['fees'] ?? '',
      titleEn: json['title_en'],
      titleAr: json['title_ar'],
      itemType: json['item_type'],
      //
      numLevels: json['num_levels'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',

      branches:
          (json['branches'] as List).map((e) => Branch.fromJson(e)).toList(),
    );
  }
}

class Branch {
  final String id;
  final String name;

  Branch({required this.id, required this.name});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(id: json['id'], name: json['name']);
  }
}
