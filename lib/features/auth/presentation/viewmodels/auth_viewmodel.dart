import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hatvest/core/constants/general_constant.dart';
import 'package:hatvest/core/enums/request_status.dart';
import 'package:hatvest/features/auth/data/datasources/auth_service.dart';
import 'package:hatvest/features/auth/data/models/auth_response_model.dart';
import 'package:hatvest/features/auth/data/models/authenticate_model.dart';
import 'package:hatvest/features/auth/data/models/signup_model.dart';
import 'package:hatvest/features/auth/data/models/user_response.dart';
import 'package:hatvest/shared/widgets/snackbar_helper.dart';
import 'package:hatvest/view/page/email-opt/email-opt.dart';
import 'package:hatvest/view/page/new-email-password/new-email-password.dart';
import 'package:hatvest/view/page/new-passward/new-passward.dart';
import 'package:hatvest/view/page/otp-page/otp-page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel with ChangeNotifier {
  final token = "token";
  final AuthService _authService = AuthService();

  // final _authService = AuthService.instance;
  final _storage = const FlutterSecureStorage();

  // bool get recentlyCreated => currentUser??.recentlyCreated ?? false;

  RequestStatus _submitStatus = RequestStatus.idle;
  RequestStatus get submitStatus => _submitStatus;
  set submitStatus(RequestStatus value) {
    _submitStatus = value;
    notifyListeners();
  }

  UserResponse? _currentUser;
  UserResponse? get currentUser => _currentUser;
  set currentUser(UserResponse? value) {
    _currentUser = value;
    notifyListeners();
  }

  Future<UserResponse?> signIn(String mobile, String password) async {
    try {
      submitStatus = RequestStatus.loading;

      var result = await _authService.signIn(AuthenticateModel(
        mobile: mobile,
        password: password,
      ));

      currentUser = result;
      submitStatus = RequestStatus.success;

      await _storeUserCredentialsToLocalStorage(mobile, password);

      return result;
    } catch (e) {
      submitStatus = RequestStatus.failed;
      rethrow;
    }
  }

  Future<UserResponse?> signInWithGoogle({
    required String email,
    required String name,
    required String phone,
    required String idToken,
    String? accessToken,
  }) async {
    try {
      submitStatus = RequestStatus.loading;

      final result = await _authService.googleSignIn(
        email: email,
        name: name,
        phone: phone,
        idToken: idToken,
        accessToken: accessToken,
      );

      currentUser = result;
      submitStatus = RequestStatus.success;

      await _storeUserCredentialsToLocalStorage(phone, '');

      return result;
    } catch (e) {
      submitStatus = RequestStatus.failed;
      rethrow;
    }
  }

  Future<UserResponse?> signInWithApple({
    required String identityToken,
    String? fName,
    String? lName,
    String? deviceToken,
  }) async {
    try {
      submitStatus = RequestStatus.loading;

      final result = await _authService.appleSignIn(
        identityToken: identityToken,
        fName: fName,
        lName: lName,
        deviceToken: deviceToken,
      );

      currentUser = result;
      submitStatus = RequestStatus.success;

      await _storeUserCredentialsToLocalStorage('', '');

      return result;
    } catch (e) {
      submitStatus = RequestStatus.failed;
      rethrow;
    }
  }

//
// viewmodels/auth_viewmodel.dart
  bool isLoading = false;

  Future<void> signUp(SignupModel signupData) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final success = await _authService.signUp(signupData);
      if (!success) {
        throw "فشل عملية التسجيل";
      }
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _storeUserCredentialsToLocalStorage(
      String phone, String password) async {
    await _storage.write(key: loggedPhoneStoreKey, value: phone);
    await _storage.write(key: loggedPasswordStoreKey, value: password);
    await _storage.delete(key: "is_logout");
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // احذف كل البيانات الخاصة بالمستخدم
      await prefs.remove('auth_token');
      await prefs.remove('mobile');

      await _storage.delete(key: loggedPhoneStoreKey);
      await _storage.delete(key: loggedPasswordStoreKey);

      // علّم إن المستخدم خرج
      await _storage.write(key: "is_logout", value: "true");

      currentUser = null;
      notifyListeners();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An error occurred while logging out",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  //
  AuthResponseModel? _userData;

  AuthResponseModel? get userData => _userData;

  Future<void> loadUserData() async {
    _userData = await _authService.refreshToken();
    notifyListeners();
  }

  //
  String? errorMessage;

  Future<bool> changePassword({
    required String mobile,
    required String password,
    required String passwordConfirmation,
  }) async {
    submitStatus = RequestStatus.loading;
    notifyListeners();

    try {
      await _authService.newPassword(
        mobile: mobile,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      submitStatus = RequestStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      submitStatus = RequestStatus.failed;
      notifyListeners();
      return false;
    }
  }

  //
  //>>>>>>>>>> sendOtp

  Future<void> sendOtp(BuildContext context, String mobile) async {
    try {
      isLoading = true;
      notifyListeners();

      await _authService.resendOtp(mobile);

      showAwesomeSnackBar(
        title: "تم الإرسال",
        message: "تم إرسال الرمز إلى رقمك.",
        type: SnackbarType.success,
      );

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => OtpPge(
                    mobile: mobile,
                  )));
      // Navigator.pushNamed(context, "/otp", arguments: mobile);
    } catch (e) {
      showAwesomeSnackBar(
        title: "خطأ",
        message: "فشل إرسال الرمز.",
        type: SnackbarType.error,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //>>>>>>>>>> verifyCode
  Future<void> verifyCode(
      BuildContext context, String mobile, String code) async {
    try {
      isLoading = true;
      notifyListeners();

      await _authService.verifyOtp(mobile, code);

      showAwesomeSnackBar(
        title: "تم التحقق",
        message: "تم التحقق من الرمز بنجاح.",
        type: SnackbarType.success,
      );
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => NewPasswordPage(
                    mobile: mobile,
                  )));
      // Navigator.pushNamed(context, "/new-password", arguments: mobile);
    } catch (e) {
      showAwesomeSnackBar(
        title: "خطأ",
        message: "رمز التحقق غير صحيح.",
        type: SnackbarType.error,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //>>>>>>>>>> resetPassword
  Future<void> resetPassword(BuildContext context, String mobile,
      String pass, String confirm, [String code = '']) async {
    try {
      isLoading = true;
      notifyListeners();

      await _authService.setNewPassword(
        mobile,
        pass,
        confirm,
        code: code,
      );

      showAwesomeSnackBar(
        title: "تم بنجاح",
        message: "تم تغيير كلمة المرور.",
        type: SnackbarType.success,
      );

      Navigator.pushReplacementNamed(context, "/login");
    } catch (e) {
      showAwesomeSnackBar(
        title: "خطأ",
        message: "فشل تغيير كلمة المرور.",
        type: SnackbarType.error,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //>>>>>>>>>>>>>>>>>>>>>>>>>>
  //>> email rset
  Future<void> sendEmailOtp(BuildContext context, String email) async {
    try {
      isLoading = true;
      notifyListeners();

      await _authService.resendEmailOtp(email);

      showAwesomeSnackBar(
        title: "تم الإرسال",
        message: "تم إرسال الرمز إلى اميلك.",
        type: SnackbarType.success,
      );

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => EmailOtpPage(
                    email: email,
                  )));
      // Navigator.pushNamed(context, "/otp", arguments: mobile);
    } catch (e) {
      showAwesomeSnackBar(
        title: "خطأ",
        message: "فشل إرسال الرمز.",
        type: SnackbarType.error,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //>>>
  Future<void> verifyEmailCode(
      BuildContext context, String email, String code) async {
    try {
      isLoading = true;
      notifyListeners();

      await _authService.verifyEmailOtp(email, code);

      showAwesomeSnackBar(
        title: "تم التحقق",
        message: "تم التحقق من الرمز بنجاح.",
        type: SnackbarType.success,
      );
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => NewEmailPage(
                    email: email,
                  )));
      // Navigator.pushNamed(context, "/new-password", arguments: mobile);
    } catch (e) {
      showAwesomeSnackBar(
        title: "خطأ",
        message: "رمز التحقق غير صحيح.",
        type: SnackbarType.error,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //>>>>>>>>>> resetPassword
  Future<void> resetEmailPassword(
      BuildContext context, String email, String pass, String confirm) async {
    try {
      isLoading = true;
      notifyListeners();

      await _authService.setNewEmailPassword(email, pass, confirm);

      showAwesomeSnackBar(
        title: "تم بنجاح",
        message: "تم تغيير كلمة المرور.",
        type: SnackbarType.success,
      );

      Navigator.pushReplacementNamed(context, "/login");
    } catch (e) {
      showAwesomeSnackBar(
        title: "خطأ",
        message: "فشل تغيير كلمة المرور.",
        type: SnackbarType.error,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
