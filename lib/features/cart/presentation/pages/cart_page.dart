import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/shared/widgets/custom_buttons.dart';
import 'package:hatvest/features/cart/presentation/pages/checkout_page.dart';
import 'package:hatvest/core/theme/app_colors.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:provider/provider.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  late CartViewModel cartViewModel;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
      cartViewModel.getCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final locale = context.locale;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // لون خلفية أهدأ وأفخم
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "cart".tr(),
          style: getBoldStyle(color: primaryColor, fontSize: FontSize.s20),
        ),
      ),
      body: Consumer<CartViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final cartItems = viewModel.cart.expand((cart) => cart.items).toList();

          if (cartItems.isEmpty || viewModel.cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)
                      ]
                    ),
                    child: Icon(Icons.shopping_bag_outlined, size: 70, color: primaryColor.withOpacity(0.5)),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "cart_empty".tr(),
                    style: getBoldStyle(color: grey, fontSize: FontSize.s18),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 120,
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: item.itemImage != null && item.itemImage.isNotEmpty
                                ? Image.network(
                                    item.itemImage,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 95,
                                    errorBuilder: (context, error, stackTrace) => Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(
                                        "assets/images/logo.png",
                                        width: 100,
                                        height: 95,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      "assets/images/logo.png",
                                      width: 100,
                                      height: 95,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.itemTitleAr ?? item.itemTitleEn,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: getBoldStyle(color: blackColors, fontSize: FontSize.s16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${item.price} ج.م",
                                  style: getBoldStyle(color: addCard, fontSize: FontSize.s17),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              viewModel.removeItemFromCart(item.cartItemId);
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.redAccent, size: 18),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 30,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "your_order".tr(),
                            style: getBoldStyle(color: grey, fontSize: FontSize.s15),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "${cartItems.length} عناصر",
                              style: getBoldStyle(color: primaryColor, fontSize: FontSize.s12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _RowWidget("prices".tr(), "ج.م ${viewModel.cart.first.primaryPrice}"),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(thickness: 0.5),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "total".tr(),
                            style: getBoldStyle(color: blackColors, fontSize: FontSize.s18),
                          ),
                          Text(
                            "ج.م ${viewModel.cart.first.totalPrice}",
                            style: getBoldStyle(color: primaryColor, fontSize: FontSize.s22),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CheckOut()),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor, primaryColor.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "checkout".tr(),
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

  Widget _RowWidget(
    String text,
    String text2, {
    Color? color,
    TextStyle? text2Style,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: getRegularStyle(color: blackColors, fontSize: FontSize.s18),
          ),
          Text(
            text2,
            style: text2Style ??
                getRegularStyle(
                  color: color ?? grey,
                  fontSize: FontSize.s16,
                ),
          ),
        ],
      ),
    );
  }
}
