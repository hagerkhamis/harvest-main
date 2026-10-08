class AuthenticateModel {
  String? mobile;
  String? password;

  AuthenticateModel({
    this.mobile,
    this.password,
  });

  Map<String, dynamic> toJson() {
    final isEmail = mobile?.contains('@') ?? false;
    if (isEmail) {
      return {
        'email': mobile?.toString(),
        'password': password,
      };
    } else {
      return {
        'mobile': mobile?.toString(),
        'mobile_1': mobile?.toString(),
        'phone': mobile?.toString(),
        'username': mobile?.toString(),
        'password': password,
      };
    }
  }
}




