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
      allData: AllData.fromJson(json['all-data']),
      book: Book.fromJson(json['Book']),
      diploma:
          json['Diploma'] != null ? Diploma.fromJson(json['Diploma']) : null,
      offlineOffers: (json['offline_offers'] as List)
          .map((e) => Offer.fromJson(e))
          .toList(),
      onlineOffers: (json['online_offers'] as List)
          .map((e) => Offer.fromJson(e))
          .toList(),
      bestOffer: json['bestOffer'] != null
          ? BestOffer.fromJson(json['bestOffer'])
          : null, // ✅ parse as BestOffer
      tracks: (json['tracks'] as List).map((e) => Track.fromJson(e)).toList(),
      onlineDesc: json['online_desc'],
      offlineDesc: json['offline_desc'],
      termsApprove: json['terms_approve'], // fix: use correct key
      message: json['message'],
    );
  }
}

class AllData {
  final GeneralResult generalResult;
  final SkillsResult skillsResult;

  AllData({required this.generalResult, required this.skillsResult});

  factory AllData.fromJson(Map<String, dynamic> json) {
    return AllData(
      generalResult: GeneralResult.fromJson(json['General_Result']),
      skillsResult: SkillsResult.fromJson(json['Skills_Result']),
    );
  }
}

class GeneralResult {
  final PtResult ptResult;
  final List<ExamResult> examResult;

  GeneralResult({required this.ptResult, required this.examResult});

  factory GeneralResult.fromJson(Map<String, dynamic> json) {
    return GeneralResult(
      ptResult: PtResult.fromJson(json['PtResult']),
      examResult: (json['ExamResult'] as List)
          .map((e) => ExamResult.fromJson(e))
          .toList(),
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
      pt: (json['PT'] as num).toDouble(),
      ptLabel: json['pt_label'],
      track: json['Track'],
      allSkillsGrade: json['allskillsgrade'],
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
      level: json['level'],
      result: json['result'],
      allGrade: json['allgrade'],
      allSkillsGrade: json['allskillsgrade'],
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
      name: json['name'],
      label: json['label'],
      track: json['Track'],
      level: json['Level'],
      total: (json['total'] as num).toDouble(),
      allGrade: json['allgrade'],
      allSkillsGrade: json['allskillsgrade'],
    );
  }
}

class Book {
  final String title;
  final String link;

  Book({required this.title, required this.link});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'],
      link: json['link'],
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
      type: json['type'],
      title: json['title'],
      diplomaImg: json['diploma_img'],
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
      id: json['id'],
      image: json['image'],
      courseTitle: json['course_title'],
      endDate: json['end_date'],
      title: json['title'],
      titleEn: json['title_en'],
      titleAr: json['title_ar'],
      itemType: json['item_type'],
      fees: json['fees'],
      oldFees: json['old_fees'],
      paymentPlan: json['payment_plan'],
    );
  }
}

class Track {
  final int id;
  final String title;

  Track({required this.id, required this.title});

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      title: json['title'],
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
      id: json['id'] ?? "",
      image: json['image'] ?? "",
      track: json['track'] ?? "",
      courseTitle: json['course_title'] ?? "",
      endDate: DateTime.parse(json['end_date']),
      title: json['title'] ?? "",
      offerType: json['offer_ty'] ?? "",
      fees: json['fees'] ?? "",
      oldFees: json['old_fees'] ?? "",
      itemType: json['item_type'] ?? "",
      paymentPlan: json['payment_plan'] ?? "",
    );
  }
}
