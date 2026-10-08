import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hatvest/features/auth/data/datasources/auth_service.dart';
import 'package:hatvest/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:hatvest/features/auth/domain/repositories/auth_repository.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authServiceProvider));
});
