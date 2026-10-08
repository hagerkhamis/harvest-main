class ServicesDetailsModel {
  final TrainingServices trainigServices;
  final String message;

  ServicesDetailsModel({
    required this.trainigServices,
    required this.message,
  });

  factory ServicesDetailsModel.fromJson(Map<String, dynamic> json) {
    return ServicesDetailsModel(
      trainigServices: TrainingServices.fromJson(json["Trainig_Services"] ?? {}),
      message: json["message"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "Trainig_Services": trainigServices.toJson(),
        "message": message,
      };
}

class TrainingServices {
  final int id;
  final String track;
  final String title;
  final String titleEn;
  final String titleAr;
  final String appleId;
  final String desc;
  final String fullDesc;
  final String fullDescAr;
  final String shortdesc;
  final String shortDesc;
  final String shortDescAr;
  final String image;
  final String itemType;
  final String course;
  final String paymentPlan;
  final String fees;
  final String offerTy;

  TrainingServices({
    required this.id,
    required this.track,
    required this.title,
    required this.titleEn,
    required this.titleAr,
    required this.appleId,
    required this.desc,
    required this.fullDesc,
    required this.fullDescAr,
    required this.shortdesc,
    required this.shortDesc,
    required this.shortDescAr,
    required this.image,
    required this.itemType,
    required this.course,
    required this.paymentPlan,
    required this.fees,
    required this.offerTy,
  });

  factory TrainingServices.fromJson(Map<String, dynamic> json) {
    return TrainingServices(
      id: json["id"] ?? 0,
      track: json["track"] ?? "",
      title: json["title"] ?? "",
      titleEn: json["title_en"] ?? "",
      titleAr: json["title_ar"] ?? "",
      appleId: json["apple_id"] ?? "",
      desc: json["desc"] ?? "",
      fullDesc: json["full_desc"] ?? "",
      fullDescAr: json["full_desc_ar"] ?? "",
      shortdesc: json["shortdesc"] ?? "",
      shortDesc: json["short_desc"] ?? "",
      shortDescAr: json["short_desc_ar"] ?? "",
      image: json["image"] ?? "",
      itemType: json["item_type"] ?? "",
      course: json["course"] ?? "",
      paymentPlan: json["payment_plan"] ?? "",
      fees: json["fees"] ?? "",
      offerTy: json["offer_ty"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "track": track,
        "title": title,
        "title_en": titleEn,
        "title_ar": titleAr,
        "apple_id": appleId,
        "desc": desc,
        "full_desc": fullDesc,
        "full_desc_ar": fullDescAr,
        "shortdesc": shortdesc,
        "short_desc": shortDesc,
        "short_desc_ar": shortDescAr,
        "image": image,
        "item_type": itemType,
        "course": course,
        "payment_plan": paymentPlan,
        "fees": fees,
        "offer_ty": offerTy,
      };
}
