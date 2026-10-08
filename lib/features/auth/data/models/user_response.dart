class UserResponse {
  final String accessToken;
  final String tokenType;
  final Lead lead;
  final String message;

  UserResponse({
    required this.accessToken,
    required this.tokenType,
    required this.lead,
    required this.message,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      accessToken: json['access_token'] ?? "",
      tokenType: json['token_type'] ?? "",
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
  final String fName;
  final String lName;
  final String mName;
  final Country country;
  final String nameAr;
  final String resetCode;
  final String email;
  final int approve;
  final String image;
  final String phoneVerify;
  final String emailVerify;
  final String ptLevel;
  final Application? adultPtApplication;
  final Application? kidsPtApplication;

  Lead({
    required this.name,
    required this.type,
    required this.gender,
    required this.mobile1,
    required this.mobile2,
    required this.fName,
    required this.lName,
    required this.mName,
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
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      mobile1: json['mobile_1']?.toString() ?? '',
      mobile2: json['mobile_2']?.toString() ?? '',
      fName: json['f_name']?.toString() ?? '',
      lName: json['l_name']?.toString() ?? '',
      mName: json['m_name']?.toString() ?? '',
      country: Country.fromJson(json['country'] ?? {}),
      nameAr: json['name_ar']?.toString() ?? '',
      resetCode: json['reset_code']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      approve: int.tryParse(json['approve']?.toString() ?? '0') ?? 0,
      image: json['image']?.toString() ?? '',
      phoneVerify: json['phone_verify']?.toString() ?? '',
      emailVerify: json['email_verify']?.toString() ?? '',
      ptLevel: json['pt_level']?.toString() ?? '',
      adultPtApplication: json['adult_pt_application'] != null
          ? Application.fromJson(json['adult_pt_application'])
          : null,
      kidsPtApplication: json['kids_pt_application'] != null
          ? Application.fromJson(json['kids_pt_application'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'gender': gender,
      'mobile_1': mobile1,
      'mobile_2': mobile2,
      'f_name': fName,
      'l_name': lName,
      'm_name': mName,
      'country': country.toJson(),
      'name_ar': nameAr,
      'reset_code': resetCode,
      'email': email,
      'approve': approve,
      'image': image,
      'phone_verify': phoneVerify,
      'email_verify': emailVerify,
      'pt_level': ptLevel,
    };
  }
}

class Application {
  final int id;
  final String finish;

  Application({required this.id, required this.finish});

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'],
      finish: json['finish'],
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
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }
}
