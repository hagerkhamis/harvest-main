import 'package:hatvest/features/auth/data/models/authenticate_model.dart';
import 'package:hatvest/features/auth/data/models/user_response.dart';
import 'package:hatvest/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase {
  SignInUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserResponse> call(AuthenticateModel body) {
    return _repository.signIn(body);
  }
}
