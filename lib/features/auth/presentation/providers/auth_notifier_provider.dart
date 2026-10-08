import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hatvest/features/auth/presentation/states/auth_state.dart';
import 'package:hatvest/features/auth/presentation/viewmodels/auth_notifier.dart';

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
