import 'package:hatvest/features/cart/data/models/cart_response.dart';
import 'package:hatvest/features/cart/data/models/invoice_response.dart';
import 'package:hatvest/features/cart/data/models/payment_details_model.dart';

class CartState {
  const CartState({
    this.isLoading = false,
    this.cart = const [],
    this.invoices = const [],
    this.paymentData,
    this.errorMessage,
  });

  final bool isLoading;
  final List<CartModel> cart;
  final List<Invoice> invoices;
  final PaymentData? paymentData;
  final String? errorMessage;

  CartState copyWith({
    bool? isLoading,
    List<CartModel>? cart,
    List<Invoice>? invoices,
    PaymentData? paymentData,
    String? errorMessage,
  }) {
    return CartState(
      isLoading: isLoading ?? this.isLoading,
      cart: cart ?? this.cart,
      invoices: invoices ?? this.invoices,
      paymentData: paymentData ?? this.paymentData,
      errorMessage: errorMessage,
    );
  }
}
