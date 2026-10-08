import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hatvest/model/serives-corse-model.dart' show Service;
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/model/offer_model.dart' as offer_model;
import 'package:hatvest/shared/widgets/networkimage-withheaders.dart';
import 'package:hatvest/view/page/deoplom-info/deoplom-info.dart';
import 'package:hatvest/viewmodel/cart-viewmodel.dart';
import 'package:hatvest/viewmodel/serives.dart';
import 'package:provider/provider.dart';

class ServiesPage extends StatefulWidget {
  @override
  State<ServiesPage> createState() => _ServiesPageState();
}

class _ServiesPageState extends State<ServiesPage> {
  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;
  String? _lastSelectedTitle;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_scrollController.hasClients) return;

      final position = _scrollController.position;
      final maxScroll = position.maxScrollExtent;
      if (maxScroll <= 0) return;

      final currentScroll = position.pixels;
      // One grid row ≈ card height (~ screen-based) + spacing.
      final delta = MediaQuery.sizeOf(context).height * 0.28;

      if (currentScroll >= maxScroll - 4) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.animateTo(
          (currentScroll + delta).clamp(0.0, maxScroll),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.linear,
        );
      }
    });
  }

  void _resetScrollIfNeeded(String? selectedTitle) {
    if (selectedTitle == _lastSelectedTitle) return;
    _lastSelectedTitle = selectedTitle;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _showCourseSelectorBottomSheet(
    BuildContext context,
    CourseViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          shrinkWrap: true,
          children: viewModel.serives.map((serives) {
            return ListTile(
              title: Text(serives.title),
              onTap: () {
                viewModel.selectTitle(serives.title);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CourseViewModel()..fetchServices(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "page_services".tr(),
            style: getBoldStyle(color: primaryColor, fontSize: FontSize.s20),
          ),
          centerTitle: false,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/bottomNav');
              },
              icon: Icon(
                Icons.arrow_forward,
                color: blackColors,
                size: 35,
              ),
            ),
          ],
        ),
        body: Consumer<CourseViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.serives.isEmpty) {
              final isServerError = viewModel.servicesError == 'server';
              final isIncomplete = viewModel.servicesError == 'incomplete';
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isServerError || isIncomplete
                            ? Icons.cloud_off_outlined
                            : Icons.inbox_outlined,
                        size: 48,
                        color: grey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isServerError
                            ? "services_server_error".tr()
                            : isIncomplete
                                ? "services_incomplete_error".tr()
                                : "no_data".tr(),
                        textAlign: TextAlign.center,
                        style: getMediumStyle(
                          color: grey,
                          fontSize: FontSize.s16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: viewModel.fetchServices,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                        ),
                        child: Text(
                          "retry".tr(),
                          style: getBoldStyle(
                            color: Colors.white,
                            fontSize: FontSize.s14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (viewModel.selectedTitle != _lastSelectedTitle) {
              final title = viewModel.selectedTitle;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _resetScrollIfNeeded(title);
              });
            }

            return Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            _showCourseSelectorBottomSheet(context, viewModel),
                        child: Row(
                          children: [
                            Text(
                              "filter".tr(),
                              style: getBoldStyle(color: primaryColor),
                            ),
                            const SizedBox(width: 5),
                            SvgPicture.asset("assets/icons/filter.svg"),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: viewModel.serives.map((service) {
                              final isSelected =
                                  viewModel.selectedTitle == service.title;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: ChoiceChip(
                                  label: Text(service.title),
                                  selected: isSelected,
                                  selectedColor: primaryColor,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : blackColors,
                                  ),
                                  onSelected: (_) {
                                    viewModel.selectTitle(service.title);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(child: _servicesContent(viewModel)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _servicesContent(CourseViewModel viewModel) {
    final services = viewModel.selectedSerives;

    if (services.isEmpty) {
      return Center(
        child: Text(
          "no_data".tr(),
          style: getMediumStyle(color: grey, fontSize: FontSize.s16),
        ),
      );
    }

    return _buildOffersGrid(services);
  }

  Widget _buildOffersGrid(List<Service> services) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final locale = context.locale.languageCode;
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 3 / 6,
      ),
      itemBuilder: (context, index) {
        final offer = services[index];
        final displayTitle = offer.displayTitleForLocale(locale);
        final priceText = offer.fees.isNotEmpty ? '${offer.fees} ج.م' : '';
        return GestureDetector(
          onTap: () {
            final offerData = offer_model.Offer(
              id: offer.id.toString(),
              image: offer.image,
              courseTitle: offer.course,
              title: displayTitle.isNotEmpty ? displayTitle : offer.title,
              titleEn: offer.titleEn,
              titleAr: offer.titleAr,
              itemType: offer.itemType.isNotEmpty ? offer.itemType : 'service',
              fees: offer.fees,
              oldFees: '',
              desc: offer.desc,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DeoplomInfo(
                  offerId: offer.id,
                  offerData: offerData,
                ),
              ),
            );
          },
          child: SizedBox(
            width: 165,
            child: Column(
              children: [
                offer.image.isNotEmpty
                    ? NetworkImageWithHeaders(
                        url: offer.image,
                        width: 190,
                        height: 110,
                        fit: BoxFit.cover,
                        errorWidget: Image.asset(
                          "assets/images/courssess.png",
                          width: 190,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        "assets/images/courssess.png",
                        width: 190,
                        height: 110,
                        fit: BoxFit.cover,
                      ),
                Container(
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5.0,
                      vertical: 5,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          displayTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: getBoldStyle(
                            color: blackColors,
                            fontSize: FontSize.s15,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.008),
                        if (priceText.isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  priceText,
                                  style: getBoldStyle(
                                    color: primaryColor,
                                    fontSize: FontSize.s15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: screenHeight * 0.004),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5.0,
                            vertical: 5.0,
                          ),
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
                                            itemType: offer.itemType.isNotEmpty
                                                ? offer.itemType
                                                : 'service',
                                            itemTitleEn: offer.titleEn,
                                            itemTitleAr: offer.titleAr,
                                          );
                                        },
                                  child: Container(
                                    width: 140,
                                    height: 45.0,
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(5.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withOpacity(0.25),
                                          blurRadius: 6.0,
                                          offset: const Offset(0, 3),
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
                        SizedBox(height: screenHeight * 0.01),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
