// models/signup_model.dart
class SignupModel {
  final String fName;
  final String lName;
  final String email;
  final String gender;
  final String mobile1;
  final String branchId;
  final String password;
  final String country;
  final String track;

  SignupModel({
    required this.fName,
    required this.lName,
    required this.email,
    required this.gender,
    required this.mobile1,
    required this.branchId,
    required this.password,
    required this.country,
    required this.track,
  });

  Map<String, dynamic> toJson() {
    return {
      'f_name': fName,
      'l_name': lName,
      'email': email,
      'gender': gender,
      'mobile_1': mobile1,
      'branch_id': branchId,
      'password': password,
      'country': country,
      'prefered_track_id': track,
    };
  }
}
