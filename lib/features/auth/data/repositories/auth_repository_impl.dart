import 'package:hatvest/features/auth/data/datasources/auth_service.dart';
import 'package:hatvest/features/auth/data/models/auth_response_model.dart';
import 'package:hatvest/features/auth/data/models/authenticate_model.dart';
import 'package:hatvest/features/auth/data/models/signup_model.dart';
import 'package:hatvest/features/auth/data/models/user_response.dart';
import 'package:hatvest/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._authService);

  final AuthService _authService;

  @override
  Future<UserResponse> signIn(AuthenticateModel body) {
    return _authService.signIn(body);
  }

  @override
  Future<bool> signUp(SignupModel body) {
    return _authService.signUp(body);
  }

  @override
  Future<AuthResponseModel?> refreshToken() {
    return _authService.refreshToken();
  }

  @override
  Future<void> resendOtp(String mobile) {
    return _authService.resendOtp(mobile);
  }

  @override
  Future<void> verifyOtp(String mobile, String code) {
    return _authService.verifyOtp(mobile, code);
  }
}
