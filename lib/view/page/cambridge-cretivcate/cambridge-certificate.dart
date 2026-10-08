import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart' as html;
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/core/utils/certificate_image_helper.dart';
import 'package:hatvest/shared/widgets/dynamic_certificate_image.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart';
import 'package:hatvest/viewmodel/cart-viewmodel.dart';
import 'package:provider/provider.dart';

class CambridgeCertificate extends StatefulWidget {
  const CambridgeCertificate({super.key});

  @override
  State<CambridgeCertificate> createState() => _CambridgeCertificateState();
}

class _CambridgeCertificateState extends State<CambridgeCertificate> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
      viewModel.getItem(3);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final viewModel = Provider.of<ProfileViewModel>(context);
    final item = viewModel.item;

    return Scaffold(
      body: SizedBox(
        height: screenHeight, // full screen height
        width: screenWidth,
        child: Stack(
          children: [

            /// ✅ Check for null
            if (viewModel.isLoading)
              const Center(child: CircularProgressIndicator())

            /// ✅ Handle errors
            else if (viewModel.errorMessage != null)
              Center(child: Text("load_error".tr()))

            /// ✅ Handle empty data
            else if (item == null)
              Center(
                child: Text(
                  "no_data".tr(),
                  style: TextStyle(fontSize: 18),
                ),
              )
            else
              SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        DynamicCertificateImage(
                          imageUrl: CertificateImageHelper.resolveForItem(
                            id: item.id,
                            imageFromApi: item.image,
                          ),
                          height: 220,
                        ),
                        Positioned(
                          top: 15,
                          left: 10,
                          child: SafeArea(
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.arrow_forward,
                                  color: Colors.black, size: 35),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.name,
                            style: getBoldStyle(
                                color: primaryColor, fontSize: FontSize.s22),
                          ),
                          Text(
                            "ج.م ${item.price}",
                            style: getBoldStyle(
                                color: primaryColor, fontSize: FontSize.s20),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: grey,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 15.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 15.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "category".tr(),
                                    style: getBoldStyle(
                                        color: grey, fontSize: FontSize.s20),
                                  ),
                                  Text(
                                    item.category.isEmpty
                                        ? "certificates".tr()
                                        : item.category,
                                    style: getBoldStyle(
                                        color: primaryColor,
                                        fontSize: FontSize.s20),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "payment_plan".tr(),
                                    style: getBoldStyle(
                                        color: grey, fontSize: FontSize.s20),
                                  ),
                                  Text(
                                    item.paymentPlan,
                                    style: getBoldStyle(
                                        color: primaryColor,
                                        fontSize: FontSize.s20),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 15.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "diploma_info".tr(),
                                style: getBoldStyle(
                                    color: blackColors, fontSize: FontSize.s18),
                              ),
                              Divider(),
                              html.Html(
                                data: item.fullDesc,
                                style: {
                                  "*": html.Style(
                                    fontFamily: FontConstants.fontFamily,
                                    fontSize: html.FontSize(15.0),
                                  ),
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5.0, vertical: 5.0),
                        child: Card(
                          elevation: 2.0,
                          child: Consumer<CartViewModel>(
                            builder: (context, cartViewModel, _) {
                              final isLoading =
                                  cartViewModel.isItemLoading(item.id.toString());
  
                              return GestureDetector(
                                onTap: isLoading
                                    ? null
                                    : () {
                                        cartViewModel.addItemToCart(
                                          context: context,
                                          itemId: item.id.toString(),
                                          itemType: item.itemType,
                                          // itemTitleEn: item.titleEn,
                                          // itemTitleAr: item.titleAr,
                                        );
                                      },
                                child: Container(
                                  width: double.infinity,
                                  height: 65.0,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(5.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: grey,
                                        blurRadius: 4.0,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: isLoading
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: whiteColor,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            "add_to_arabic".tr(),
                                            style: getBoldStyle(
                                              color: whiteColor,
                                              fontSize: FontSize.s15,
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // bottom padding
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
