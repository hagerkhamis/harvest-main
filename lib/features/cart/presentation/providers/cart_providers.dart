import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hatvest/features/cart/data/datasources/cart_service.dart';
import 'package:hatvest/features/cart/presentation/states/cart_state.dart';
import 'package:hatvest/features/cart/presentation/viewmodels/cart_viewmodel.dart';

final cartServiceProvider = Provider<CartService>((ref) {
  return CartService();
});

final cartViewModelProvider = ChangeNotifierProvider<CartViewModel>((ref) {
  return CartViewModel();
});

final cartStateProvider = Provider<CartState>((ref) {
  final viewModel = ref.watch(cartViewModelProvider);
  return CartState(
    isLoading: viewModel.isLoading,
    cart: viewModel.cart,
    invoices: viewModel.invoices,
    paymentData: viewModel.paymentData,
    errorMessage: viewModel.errorMessage,
  );
});
