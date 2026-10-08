class Country {
  final int id;
  final String code;
  final String name;

  Country({required this.id, required this.code, required this.name});

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        id: json['id'],
        code: json['code'],
        name: json['name'],
      );
}

class LeadModel {
  final String name;
  final String type;
  final String gender;
  final String mobile1;
  final String? mobile2;
  final String fName;
  final String lName;
  final String? mName;
  final Country country;
  final String email;
  final String image;
  final String? applePay;

  final String ptLevel;
  final AdultPtApplication? adultPtApplication;
  final AdultPtApplication? kidsPtApplication;

  LeadModel({
    required this.name,
    required this.type,
    required this.gender,
    required this.mobile1,
    this.mobile2,
    this.applePay,
    required this.fName,
    required this.lName,
    this.mName,
    required this.country,
    required this.email,
    required this.image,
    this.ptLevel = '',
    this.adultPtApplication,
    this.kidsPtApplication,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) => LeadModel(
        name: json['name'],
        type: json['type'],
        gender: json['gender'],
        mobile1: json['mobile_1'],
        mobile2: json['mobile_2'],
        fName: json['f_name'],
        lName: json['l_name'],
        mName: json['m_name'],
        country: Country.fromJson(json['country']),
        email: json['email'],
        applePay: json['apple_pay'],

        image: json['image'],
        ptLevel: json['pt_level']?.toString() ?? '',
        adultPtApplication: json['adult_pt_application'] != null
            ? AdultPtApplication.fromJson(json['adult_pt_application'])
            : null,
        kidsPtApplication: json['kids_pt_application'] != null
            ? AdultPtApplication.fromJson(json['kids_pt_application'])
            : null,
        // kidsPtApplication: json['kids_pt_application'],
      );
}

class AdultPtApplication {
  final int id;
  final String finish;

  AdultPtApplication({
    required this.id,
    required this.finish,
  });

  factory AdultPtApplication.fromJson(Map<String, dynamic> json) {
    return AdultPtApplication(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      finish: json['finish']?.toString() ?? '0',
    );
  }
}
