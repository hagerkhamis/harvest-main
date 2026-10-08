import 'package:flutter/material.dart';
import 'package:hatvest/features/cart/data/datasources/cart_service.dart';
import 'package:hatvest/features/cart/data/models/cart_response.dart';
import 'package:hatvest/features/cart/data/models/invoice_response.dart';
import 'package:hatvest/features/cart/data/models/payment_details_model.dart';
import 'package:hatvest/features/cart/presentation/pages/checkout_page.dart';
import 'package:hatvest/shared/helpers/snackbar_helper.dart';

class CartViewModel extends ChangeNotifier {
  final CartService _cartService = CartService();
  final Map<String, bool> _loadingItems = {};

  List<Invoice> _invoices = [];
  List<Invoice> get invoices => _invoices;

  bool isItemLoading(String itemId) => _loadingItems[itemId] ?? false;

  List<CartModel> _cart = [];
  List<CartModel> get cart => _cart;
  bool get isLoading => _isLoading;
  bool _isLoading = false;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> addItemToCart({
    required BuildContext context,
    required String itemId,
    required String itemType,
    String? itemTitleEn,
    String? itemTitleAr,
    String? branchId,
  }) async {
    _loadingItems[itemId] = true;
    notifyListeners();

    try {
      final message = await _cartService.addToCart(
        itemId: itemId,
        itemType: itemType,
        itemTitleEn: itemTitleEn,
        itemTitleAr: itemTitleAr,
        branchId: branchId,
      );
      showAwesomeSnackBar(
        // context: context,
        title: "Success!",
        message: message,
        type: SnackbarType.success,
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CheckOut()),
      );
    } catch (e) {
      String errorMsg = "فشل في الإضافة إلى السلة";
      final errStr = e.toString();
      // Extract meaningful message from exception
      if (errStr.contains('Exception: ')) {
        errorMsg = errStr.replaceAll('Exception: ', '');
      }
      showAwesomeSnackBar(
        title: "Error!",
        message: errorMsg,
        type: SnackbarType.error,
      );
    } finally {
      _loadingItems[itemId] = false;
      notifyListeners();
    }
  }

  Future<void> removeItemFromCart(String cartItemId) async {
    _cart = _cart.map((cartModel) {
      final updatedItems = cartModel.items
          .where((item) => item.cartItemId != cartItemId)
          .toList();
      return CartModel(
        id: cartModel.id,
        leadId: cartModel.leadId,
        serviceCharge: cartModel.serviceCharge,
        deliveryCost: cartModel.deliveryCost,
        vat: cartModel.vat,
        primaryPrice: cartModel.primaryPrice,
        vatCost: cartModel.vatCost,
        serviceChargeCost: cartModel.serviceChargeCost,
        coupon: cartModel.coupon,
        couponDiscount: cartModel.couponDiscount,
        couponCost: cartModel.couponCost,
        offerDiscount: cartModel.offerDiscount,
        netPrice: cartModel.netPrice,
        totalPrice: cartModel.totalPrice,
        items: updatedItems,
      );
    }).where((cartModel) => cartModel.items.isNotEmpty).toList();
    notifyListeners();
  }

  Future<void> getCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cart = await _cartService.fetchCart();
    } catch (e) {
      print("Error fetching cart: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  //
  Future<void> applyCoupon(String cartId, String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newCart = await _cartService.applyCoupon(cartId, code);
      if (newCart.isNotEmpty) {
        _cart = newCart; // Replace old data
        await getCart();
      }
    } catch (e) {
      print("Error applying coupon: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  //
  Future<void> fetchInvoices() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _cartService.fetchInvoices();
      _invoices = response.invoices;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  //>>>

  PaymentData? paymentData;

  Future<void> getPaymentDetails(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _cartService.fetchPaymentDetails(id);
      if (response.success) {
        paymentData = response.data;
      } else {
        _errorMessage = "Failed to fetch payment details";
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
