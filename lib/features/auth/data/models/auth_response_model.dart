// auth_response_model.dart
class AuthResponseModel {
  final String accessToken;
  final String tokenType;
  final Lead lead;
  final String message;

  AuthResponseModel({
    required this.accessToken,
    required this.tokenType,
    required this.lead,
    required this.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      lead: Lead.fromJson(json['lead']),
      message: json['message'],
    );
  }
}

class Lead {
  final String name;
  final String type;
  final String gender;
  final String mobile1;
  final String mobile2;
  final String firstName;
  final String lastName;
  final String middleName;
  final Country country;
  final String nameAr;
  final String resetCode;
  final String email;
  final int approve;
  final String image;
  final String phoneVerify;
  final String emailVerify;
  final String ptLevel;
  final AdultPtApplication? adultPtApplication;
  final dynamic kidsPtApplication;

  Lead({
    required this.name,
    required this.type,
    required this.gender,
    required this.mobile1,
    required this.mobile2,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.country,
    required this.nameAr,
    required this.resetCode,
    required this.email,
    required this.approve,
    required this.image,
    required this.phoneVerify,
    required this.emailVerify,
    required this.ptLevel,
    this.adultPtApplication,
    this.kidsPtApplication,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      name: json['name'],
      type: json['type'],
      gender: json['gender'],
      mobile1: json['mobile_1'],
      mobile2: json['mobile_2'],
      firstName: json['f_name'],
      lastName: json['l_name'],
      middleName: json['m_name'],
      country: Country.fromJson(json['country']),
      nameAr: json['name_ar'],
      resetCode: json['reset_code'],
      email: json['email'],
      approve: json['approve'] ?? 0,
      image: json['image'],
      phoneVerify: json['phone_verify'],
      emailVerify: json['email_verify'],
      ptLevel: json['pt_level'],
      adultPtApplication: json['adult_pt_application'] != null 
          ? AdultPtApplication.fromJson(json['adult_pt_application']) 
          : null,
      kidsPtApplication: json['kids_pt_application'],
    );
  }
}

class Country {
  final int id;
  final String code;
  final String name;

  Country({
    required this.id,
    required this.code,
    required this.name,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      code: json['code'],
      name: json['name'],
    );
  }
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
      id: json['id'],
      finish: json['finish'],
    );
  }
}