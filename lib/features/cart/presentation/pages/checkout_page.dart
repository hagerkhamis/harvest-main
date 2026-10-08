import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/features/cart/data/datasources/cart_service.dart';
import 'package:hatvest/features/cart/presentation/pages/my_payment_page.dart';
import 'package:hatvest/features/cart/presentation/pages/payment_webview_page.dart';
import 'package:hatvest/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:hatvest/shared/widgets/custom_buttons.dart';
import 'package:hatvest/shared/widgets/custom_snackbar.dart';
import 'package:hatvest/core/theme/app_colors.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart';
import 'package:provider/provider.dart';

class CheckOut extends StatefulWidget {
  const CheckOut({
    super.key,
  });

  @override
  State<CheckOut> createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  late CartViewModel cartViewModel;
  late final CartService _checkoutService;

  String? _selectedPaymentMethod;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkoutService = CartService();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cartViewModel = Provider.of<CartViewModel>(context, listen: false);
      cartViewModel.getCart();
    });
  }

  final TextEditingController _walletMobileController = TextEditingController();
  final TextEditingController _walletNameController = TextEditingController();
  TextEditingController couponController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final viewModel = Provider.of<ProfileViewModel>(context);
    final pay = viewModel.profile?.applePay;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: blackColors, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "checkout".tr(),
          style: getBoldStyle(color: primaryColor, fontSize: FontSize.s20),
        ),
      ),
      body: Consumer<CartViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final cart = viewModel.cart.isNotEmpty ? viewModel.cart.first : null;
          final cartItems = cart?.items ?? [];

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "cart_items".tr(),
                        style: getBoldStyle(color: primaryColor, fontSize: FontSize.s17),
                      ),
                      const SizedBox(height: 15),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: context.cardBg,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: item.itemImage != null && item.itemImage.isNotEmpty
                                      ? Image.network(
                                          item.itemImage,
                                          fit: BoxFit.cover,
                                          width: 60,
                                          height: 60,
                                          errorBuilder: (context, error, stackTrace) => Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Image.asset(
                                              "assets/images/logo.png",
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Image.asset(
                                            "assets/images/logo.png",
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.itemTitleAr ?? item.itemTitleEn,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: getBoldStyle(color: blackColors, fontSize: FontSize.s14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${item.price} ج.م",
                                        style: getBoldStyle(color: addCard, fontSize: FontSize.s14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 25),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "discount_code".tr(),
                              style: getBoldStyle(color: blackColors, fontSize: FontSize.s15),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: couponController,
                                    decoration: InputDecoration(
                                      hintText: "enter_discount_code".tr(),
                                      hintStyle: getRegularStyle(color: grey, fontSize: FontSize.s14),
                                      filled: true,
                                      fillColor: context.surfaceBg,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () async {
                                    final code = couponController.text.trim();
                                    if (code.isEmpty) {
                                      CustomSnackbar.show(context, "discount_code_required".tr());
                                      return;
                                    }
                                    final id = Provider.of<CartViewModel>(context, listen: false);
                                    final cartId = id.cart.first.items.first.cartId;
                                    await viewModel.applyCoupon(cartId, code);
                                    if (!viewModel.isLoading) {
                                      CustomSnackbar.show(context, "discount_applied_success".tr());
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: addCard,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  child: Text("apply".tr(), style: getBoldStyle(color: Colors.white, fontSize: FontSize.s14)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        "choose_payment_method".tr(),
                        style: getBoldStyle(color: primaryColor, fontSize: FontSize.s17),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Column(
                          children: [
                            if (pay == "1") ...[
                              _buildPaymentMethod(
                                "cash_on_delivery".tr(),
                                sidePicture: "assets/icons/cash.png",
                                type: "Cash On Delivery",
                              ),
                            ] else ...[
                              _buildPaymentMethod(
                                "fawry_payment".tr(),
                                sidePicture: "assets/icons/fawry.png",
                                type: "PayAtFawry",
                              ),
                              const Divider(height: 1, indent: 20, endIndent: 20),
                              _buildPaymentMethod(
                                "card_payment".tr(),
                                sidePicture: "assets/icons/card.png",
                                type: "PayUsingCC",
                              ),
                              const Divider(height: 1, indent: 20, endIndent: 20),
                              _buildPaymentMethod(
                                "wallet_payment".tr(),
                                sidePicture: "assets/icons/mobile.png",
                                type: "MWALLET",
                              ),
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, -10)),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "your_order".tr(),
                        style: getBoldStyle(color: blackColors, fontSize: FontSize.s16),
                      ),
                      const SizedBox(height: 15),
                      _RowWidget("prices".tr().split(':').first, "ج.م ${viewModel.cart.isNotEmpty ? viewModel.cart.first.primaryPrice : 0}"),
                      const SizedBox(height: 10),
                      _RowWidget(
                        "discount".tr(),
                        viewModel.cart.isNotEmpty && viewModel.cart.first.couponCost.isNotEmpty
                            ? "- ج.م ${viewModel.cart.first.couponCost}"
                            : "ج.م 0",
                        color: viewModel.cart.isNotEmpty && viewModel.cart.first.couponCost.isNotEmpty ? Colors.redAccent : grey,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(thickness: 0.5),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("total".tr(), style: getBoldStyle(color: blackColors, fontSize: FontSize.s18)),
                          Text(
                            "ج.م ${viewModel.cart.isNotEmpty ? (viewModel.cart.first.netPrice.isNotEmpty ? viewModel.cart.first.netPrice : viewModel.cart.first.totalPrice) : 0}",
                            style: getBoldStyle(color: primaryColor, fontSize: FontSize.s22),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _selectedPaymentMethod != null ? () => _sendCheckoutRequest() : null,
                        child: Container(
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _selectedPaymentMethod != null
                                  ? [primaryColor, primaryColor.withOpacity(0.8)]
                                  : [Colors.grey, Colors.grey.shade400],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              if (_selectedPaymentMethod != null)
                                BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                            ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    "complete_payment".tr(),
                                    style: getBoldStyle(color: Colors.white, fontSize: FontSize.s18),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _RowWidget(String text, String text2, {Color? color, TextStyle? text2Style}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text, style: getMediumStyle(color: grey, fontSize: FontSize.s15)),
        Text(text2, style: text2Style ?? getBoldStyle(color: color ?? blackColors, fontSize: FontSize.s16)),
      ],
    );
  }

  Widget _buildPaymentMethod(String text, {String? sidePicture, required String type}) {
    bool isSelected = _selectedPaymentMethod == type;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = type),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? primaryColor : grey.withOpacity(0.5), width: 2),
                  ),
                  child: isSelected
                      ? Center(child: Container(width: 10, height: 10, decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle)))
                      : null,
                ),
                const SizedBox(width: 15),
                if (sidePicture != null) ...[
                  Image.asset(sidePicture, width: 35, height: 35, fit: BoxFit.contain),
                  const SizedBox(width: 15),
                ],
                Expanded(child: Text(text, style: getBoldStyle(color: blackColors, fontSize: FontSize.s15))),
              ],
            ),
            if (type == "MWALLET" && isSelected) ...[
              const SizedBox(height: 20),
              TextField(
                controller: _walletMobileController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "wallet_number".tr(),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _walletNameController,
                decoration: InputDecoration(
                  labelText: "name".tr(),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _sendCheckoutRequest() async {
    if (_selectedPaymentMethod == null) {
      CustomSnackbar.show(context, "choose_payment_required".tr());
      return;
    }

    if (_selectedPaymentMethod == "MWALLET") {
      if (_walletMobileController.text.isEmpty ||
          _walletNameController.text.isEmpty) {
        CustomSnackbar.show(context, "wallet_data_required".tr());
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    final id = Provider.of<CartViewModel>(context, listen: false);
    final cartId = id.cart.first.items.first.cartId;

    final body = {
      "cart_id": cartId,
      "paymentMethod": _selectedPaymentMethod!,
    };

    if (_selectedPaymentMethod == "MWALLET") {
      body["e_wallet_mobile"] = _walletMobileController.text;
      body["print_name"] = _walletNameController.text;
    }

    final response = await _checkoutService.checkout(body);

    setState(() {
      _isLoading = false;
    });

    if (response != null) {
      // ✅ Cash on Delivery → على طول يروح MyPayment
      if (_selectedPaymentMethod == "Cash On Delivery") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyPayment()),
        );
        return;
      }

      // ✅ باقي الطرق
      final redirectUrl = response['payment_page_url'];
      if (redirectUrl != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebView(paymentUrl: redirectUrl),
          ),
        );
      } else {
        CustomSnackbar.show(context, "order_sent_success".tr());
      }
    } else {
      CustomSnackbar.show(context, "order_sent_failed".tr());
    }
  }
}
