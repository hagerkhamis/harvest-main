import 'package:hatvest/features/auth/data/models/auth_response_model.dart';
import 'package:hatvest/features/auth/data/models/authenticate_model.dart';
import 'package:hatvest/features/auth/data/models/signup_model.dart';
import 'package:hatvest/features/auth/data/models/user_response.dart';

abstract class AuthRepository {
  Future<UserResponse> signIn(AuthenticateModel body);
  Future<bool> signUp(SignupModel body);
  Future<AuthResponseModel?> refreshToken();
  Future<void> resendOtp(String mobile);
  Future<void> verifyOtp(String mobile, String code);
}
