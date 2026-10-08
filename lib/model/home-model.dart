import 'package:hatvest/core/utils/book_url_helper.dart';

class ResultResponse {
  final AllData allData;
  final Book book;
  final Diploma? diploma;
  final List<Offer> offlineOffers;
  final List<Offer> onlineOffers;
  final BestOffer? bestOffer; // ✅ change to BestOffer?
  final List<Track> tracks;
  final String onlineDesc;
  final String offlineDesc;
  final int termsApprove;
  final String message;

  ResultResponse({
    required this.allData,
    required this.book,
    this.diploma,
    required this.offlineOffers,
    required this.onlineOffers,
    this.bestOffer,
    required this.tracks,
    required this.onlineDesc,
    required this.offlineDesc,
    required this.termsApprove,
    required this.message,
  });

  factory ResultResponse.fromJson(Map<String, dynamic> json) {
    return ResultResponse(
      allData: json['all-data'] != null 
          ? AllData.fromJson(json['all-data']) 
          : AllData(
              generalResult: GeneralResult(
                ptResult: PtResult(pt: 0.0, ptLabel: '', track: '', allSkillsGrade: ''),
                examResult: []
              ),
              skillsResult: SkillsResult(
                ptSkills: PtSkills(name: '', label: '', email: '', track: '', number: '', total: 0, allSkillsGrade: ''),
                examSkills: []
              )
            ),
      book: json['Book'] != null ? Book.fromJson(json['Book']) : Book(title: '', link: ''),
      diploma: json['Diploma'] != null ? Diploma.fromJson(json['Diploma']) : null,
      offlineOffers: (json['offline_offers'] as List?)
              ?.map((e) => Offer.fromJson(e))
              .toList() ?? 
              (json['courses'] as List?)
              ?.map((e) => Offer.fromJson(e))
              .toList() ?? [],
      onlineOffers: (json['online_offers'] as List?)
              ?.map((e) => Offer.fromJson(e))
              .toList() ?? 
              (json['courses'] as List?)
              ?.map((e) => Offer.fromJson(e))
              .toList() ?? [],
      bestOffer: json['bestOffer'] != null ? BestOffer.fromJson(json['bestOffer']) : null,
      tracks: (json['tracks'] as List?)?.map((e) => Track.fromJson(e)).toList() ?? [],
      onlineDesc: json['online_desc']?.toString() ?? '',
      offlineDesc: json['offline_desc']?.toString() ?? '',
      termsApprove: int.tryParse(json['terms_approve']?.toString() ?? '0') ?? 0,
      message: json['message']?.toString() ?? '',
    );
  }
}

class AllData {
  final GeneralResult generalResult;
  final SkillsResult skillsResult;

  AllData({required this.generalResult, required this.skillsResult});

  factory AllData.fromJson(Map<String, dynamic> json) {
    return AllData(
      generalResult: GeneralResult.fromJson(json['General_Result'] ?? {}),
      skillsResult: SkillsResult.fromJson(json['Skills_Result'] ?? {}),
    );
  }
}

class GeneralResult {
  final PtResult ptResult;
  final List<ExamResult> examResult;

  GeneralResult({required this.ptResult, required this.examResult});

  factory GeneralResult.fromJson(Map<String, dynamic> json) {
    return GeneralResult(
      ptResult: PtResult.fromJson(json['PtResult'] ?? {}),
      examResult: (json['ExamResult'] as List?)
          ?.map((e) => ExamResult.fromJson(e))
          .toList() ?? [],
    );
  }
}

class PtResult {
  final double pt;
  final String ptLabel;
  final String track;
  final String allSkillsGrade;

  PtResult(
      {required this.pt,
      required this.ptLabel,
      required this.track,
      required this.allSkillsGrade});

  factory PtResult.fromJson(Map<String, dynamic> json) {
    return PtResult(
      pt: double.tryParse(json['PT']?.toString() ?? '0.0') ?? 0.0,
      ptLabel: json['pt_label']?.toString() ?? '',
      track: json['Track']?.toString() ?? '',
      allSkillsGrade: json['allskillsgrade']?.toString() ?? '',
    );
  }
}

//
class ExamResult {
  final String level;
  final String result;
  final String allGrade;
  final String allSkillsGrade;

  ExamResult({
    required this.level,
    required this.result,
    required this.allGrade,
    required this.allSkillsGrade,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      level: json['level']?.toString() ?? '',
      result: json['result']?.toString() ?? '',
      allGrade: json['allgrade']?.toString() ?? '',
      allSkillsGrade: json['allskillsgrade']?.toString() ?? '',
    );
  }
}

class SkillsResult {
  final PtSkills ptSkills;
  final List<ExamSkills> examSkills;

  SkillsResult({required this.ptSkills, required this.examSkills});

  factory SkillsResult.fromJson(Map<String, dynamic> json) {
    return SkillsResult(
      ptSkills: PtSkills.fromJson(json['PtSkills'] ?? {}),
      examSkills: (json['ExamSkills'] as List<dynamic>? ?? [])
          .map((e) => ExamSkills.fromJson(e))
          .toList(),
    );
  }
}

class PtSkills {
  final String name;
  final String label;
  final String email;
  final String track;
  final String number;
  final double total;
  final String allSkillsGrade;

  PtSkills({
    required this.name,
    required this.label,
    required this.email,
    required this.track,
    required this.number,
    required this.total,
    required this.allSkillsGrade,
  });

  factory PtSkills.fromJson(Map<String, dynamic> json) {
    return PtSkills(
      name: json['name'] ?? "",
      label: json['label'] ?? "",
      email: json['email'] ?? "",
      track: json['Track'] ?? "",
      number: json['Number'] ?? "",
      total: (json['total'] ?? 0).toDouble(),
      allSkillsGrade: json['allskillsgrade'] ?? "",
    );
  }
}

//
// >>> level
class ExamSkills {
  final String name;
  final String label;
  final String track;
  final String level;
  final double total;
  final String allGrade;
  final String allSkillsGrade;

  ExamSkills({
    required this.name,
    required this.label,
    required this.track,
    required this.level,
    required this.total,
    required this.allGrade,
    required this.allSkillsGrade,
  });

  factory ExamSkills.fromJson(Map<String, dynamic> json) {
    return ExamSkills(
      name: json['name']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      track: json['Track']?.toString() ?? '',
      level: json['Level']?.toString() ?? '',
      total: double.tryParse(json['total']?.toString() ?? '0.0') ?? 0.0,
      allGrade: json['allgrade']?.toString() ?? '',
      allSkillsGrade: json['allskillsgrade']?.toString() ?? '',
    );
  }
}

class Book {
  final String title;
  final String link;

  Book({required this.title, required this.link});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title']?.toString() ?? '',
      link: BookUrlHelper.normalize(json['link']?.toString() ?? ''),
    );
  }
}

class Diploma {
  final String type;
  final String title;
  final String diplomaImg;

  Diploma({required this.type, required this.title, required this.diplomaImg});

  factory Diploma.fromJson(Map<String, dynamic> json) {
    return Diploma(
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      diplomaImg: json['diploma_img']?.toString() ?? '',
    );
  }
}

class Offer {
  final String id;
  final String image;
  final String courseTitle;
  final String endDate;
  final String title;
  final String titleEn;
  final String titleAr;
  final String itemType;

  final String fees;
  final String oldFees;
  final String paymentPlan;

  Offer({
    required this.id,
    required this.image,
    required this.courseTitle,
    required this.endDate,
    required this.title,
    required this.titleEn,
    required this.titleAr,
    required this.itemType,
    required this.fees,
    required this.oldFees,
    required this.paymentPlan,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      courseTitle: json['course_title']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      titleEn: json['title_en']?.toString() ?? '',
      titleAr: json['title_ar']?.toString() ?? '',
      itemType: json['item_type']?.toString() ?? '',
      fees: json['fees']?.toString() ?? '',
      oldFees: json['old_fees']?.toString() ?? '',
      paymentPlan: json['payment_plan']?.toString() ?? '',
    );
  }
}

class Track {
  final int id;
  final String title;

  Track({required this.id, required this.title});

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
    );
  }
}

class BestOffer {
  final String id;
  final String image;
  final String track;
  final String courseTitle;
  final DateTime endDate;
  final String title;
  final String offerType;
  final String fees;
  final String oldFees;
  final String itemType;
  final String paymentPlan;

  BestOffer({
    required this.id,
    required this.image,
    required this.track,
    required this.courseTitle,
    required this.endDate,
    required this.title,
    required this.offerType,
    required this.fees,
    required this.oldFees,
    required this.itemType,
    required this.paymentPlan,
  });

  factory BestOffer.fromJson(Map<String, dynamic> json) {
    return BestOffer(
      id: json['id']?.toString() ?? "",
      image: json['image']?.toString() ?? "",
      track: json['track']?.toString() ?? "",
      courseTitle: json['course_title']?.toString() ?? "",
      endDate: DateTime.tryParse(json['end_date']?.toString() ?? '') ?? DateTime.now(),
      title: json['title']?.toString() ?? "",
      offerType: json['offer_ty']?.toString() ?? "",
      fees: json['fees']?.toString() ?? "",
      oldFees: json['old_fees']?.toString() ?? "",
      itemType: json['item_type']?.toString() ?? "",
      paymentPlan: json['payment_plan']?.toString() ?? "",
    );
  }
}
