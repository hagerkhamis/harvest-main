import 'package:hatvest/core/enums/request_status.dart';
import 'package:hatvest/features/auth/data/models/user_response.dart';

class AuthState {
  const AuthState({
    this.status = RequestStatus.idle,
    this.currentUser,
    this.errorMessage,
    this.isLoading = false,
  });

  final RequestStatus status;
  final UserResponse? currentUser;
  final String? errorMessage;
  final bool isLoading;

  AuthState copyWith({
    RequestStatus? status,
    UserResponse? currentUser,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
