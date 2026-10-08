import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart';
import 'package:hatvest/viewmodel/cart-viewmodel.dart';
import 'package:provider/provider.dart';

class ServicesInfo extends StatefulWidget {
  final int offerId;

  const ServicesInfo({super.key, required this.offerId});

  @override
  State<ServicesInfo> createState() => _ServicesInfoState();
}

class _ServicesInfoState extends State<ServicesInfo> {
  String _getFirstWords(String text, int wordCount) {
    final words = text.trim().split(RegExp(r'\s+'));
    return words.take(wordCount).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel()..getServiesDetails(widget.offerId),
      child: Scaffold(
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(child: Text(viewModel.errorMessage!));
            }

            final offer = viewModel.serviesDetails?.trainigServices;

            if (offer == null) {
              return const Center(child: Text("No data found."));
            }
            return Stack(
              children: [
                // Foreground content
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            offer.image.isNotEmpty
                                ? Image.network(
                                    offer.image,
                                    width: double.infinity,
                                    fit: BoxFit.fitWidth,
                                  )
                                : Image.asset(
                                    "assets/images/ifno-deplom.png",
                                    width: double.infinity,
                                    fit: BoxFit.fitWidth,
                                  ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 35.0, horizontal: 10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.share,
                                        color: whiteColor,
                                        size: 40,
                                      )),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: whiteColor,
                                        borderRadius:
                                            BorderRadius.circular(12.0)),
                                    child: Center(
                                      child: IconButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          icon: Icon(
                                            Icons.arrow_forward,
                                            color: blackColors,
                                            size: 35,
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${offer.title}",
                                style: getBoldStyle(
                                  color: lightblack,
                                  fontSize: FontSize.s22,
                                ),
                              ),
                              SizedBox(
                                height: screenHeight * 0.01,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${offer.track}",
                                    style: getBoldStyle(
                                      color: lightblack,
                                      fontSize: FontSize.s18,
                                    ),
                                  ),
                                  Text(
                                    "${offer.fees} ج.م",
                                    style: getBoldStyle(
                                      color: lightblack,
                                      fontSize: FontSize.s18,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: screenHeight * 0.01,
                              ),
                              Divider(
                                color: grey,
                              ),
                              SizedBox(
                                height: screenHeight * 0.01,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "diploma_info".tr(),
                                        style: getBoldStyle(
                                          color: lightblack,
                                          fontSize: FontSize.s18,
                                        ),
                                      ),
                                      Divider(
                                        color: grey,
                                      ),
                                      _RowWidget("category".tr(), "${offer.track}"),
                                      Divider(
                                        color: grey,
                                      ),
                                      _RowWidget("diploma_info".tr(),
                                          _getFirstWords(offer.title, 3)),
                                      Divider(
                                        color: grey,
                                      ),
                                      // _RowWidget(
                                      //     "المستويات", "${offer.numLevels}"),
                                      Divider(
                                        color: grey,
                                      ),
                                      // _RowWidget(
                                      //     "تاريخ البدء", "${offer.startDate}"),
                                      Divider(
                                        color: grey,
                                      ),
                                      // _RowWidget(
                                      //     "تاريخ الانتهاء", "${offer.endDate}"),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: screenHeight * 0.01,
                              ),
                              Text(
                                "drawer_branches".tr(),
                                style: getBoldStyle(
                                  color: blackColors,
                                  fontSize: FontSize.s18,
                                ),
                              ),
                              SizedBox(
                                height: screenHeight * 0.01,
                              ),
                              // SingleChildScrollView(
                              //   scrollDirection: Axis.horizontal,
                              //   child: Row(
                              //     children: offer.branches.map((b) {
                              //       return Padding(
                              //         padding:
                              //             const EdgeInsets.only(right: 8.0),
                              //         child: Container(
                              //           width: 100,
                              //           height: 75,
                              //           decoration: BoxDecoration(
                              //             color: whiteColor,
                              //             borderRadius:
                              //                 BorderRadius.circular(12.0),
                              //           ),
                              //           child: Center(
                              //             child: Text(
                              //               b.name,
                              //               textAlign: TextAlign.center,
                              //               style: getRegularStyle(
                              //                 color: grey,
                              //                 fontSize: FontSize.s16,
                              //               ),
                              //             ),
                              //           ),
                              //         ),
                              //       );
                              //     }).toList(),
                              //   ),
                              // ),
                              SizedBox(
                                height: screenHeight * 0.01,
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0, vertical: 5.0),
                                  child: Card(
                                    elevation: 2.0,
                                    child: Consumer<CartViewModel>(
                                      builder: (context, cartViewModel, _) {
                                        final isLoading = cartViewModel
                                            .isItemLoading(offer.id.toString());

                                        return GestureDetector(
                                          onTap: isLoading
                                              ? null
                                              : () {
                                                  cartViewModel.addItemToCart(
                                                    context: context,
                                                    itemId: offer.id.toString(),
                                                    itemType: offer.itemType,
                                                    itemTitleEn: offer.titleEn,
                                                    itemTitleAr: offer.titleAr,
                                                  );
                                                },
                                          child: Container(
                                            width: double.infinity,
                                            height: 65.0,
                                            decoration: BoxDecoration(
                                              color: primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
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
                                                      child:
                                                          CircularProgressIndicator(
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
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _RowWidget(String text, String text2) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
      child: Row(
        children: [
          Text(
            text,
            style: getRegularStyle(color: blackColors, fontSize: FontSize.s18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text2,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: getRegularStyle(color: grey, fontSize: FontSize.s16),
            ),
          ),
        ],
      ),
    );
  }
}
