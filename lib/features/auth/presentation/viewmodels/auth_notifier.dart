import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hatvest/core/enums/request_status.dart';
import 'package:hatvest/features/auth/data/models/authenticate_model.dart';
import 'package:hatvest/features/auth/data/models/signup_model.dart';
import 'package:hatvest/features/auth/presentation/providers/auth_providers.dart';
import 'package:hatvest/features/auth/presentation/states/auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> signIn({
    required String mobile,
    required String password,
  }) async {
    state = state.copyWith(
      status: RequestStatus.loading,
      isLoading: true,
      errorMessage: null,
    );

    try {
      final user = await ref.read(authRepositoryProvider).signIn(
            AuthenticateModel(
              mobile: mobile,
              password: password,
            ),
          );

      state = state.copyWith(
        status: RequestStatus.success,
        currentUser: user,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        status: RequestStatus.failed,
        errorMessage: error.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> signUp(SignupModel signupModel) async {
    state = state.copyWith(
      status: RequestStatus.loading,
      isLoading: true,
      errorMessage: null,
    );

    try {
      await ref.read(authRepositoryProvider).signUp(signupModel);
      state = state.copyWith(
        status: RequestStatus.success,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        status: RequestStatus.failed,
        errorMessage: error.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }
}
