import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hatvest/view/page/deoplom-info/deoplom-info.dart';
import 'package:hatvest/core/theme/app_colors.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart';
import 'package:hatvest/viewmodel/cart-viewmodel.dart';
import 'package:hatvest/viewmodel/serives.dart';
import 'package:hatvest/viewmodel/home-viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:hatvest/model/offer_model.dart';
import 'package:hatvest/features/cart/presentation/pages/cart_page.dart' as hatvest_cart;

class OffersPage extends StatefulWidget {
  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  int selectedTab = 0;
  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;

  Widget _buildPlaceholder(String title) {
    final colors = [
      const Color(0xFF1A3C5E),
      const Color(0xFF2E7D32),
      const Color(0xFF1565C0),
      const Color(0xFF6A1B9A),
      const Color(0xFFE65100),
      const Color(0xFF00695C),
    ];
    final colorIndex = title.isNotEmpty ? title.codeUnitAt(0) % colors.length : 0;
    return Container(
      width: double.infinity,
      height: 130,
      color: colors[colorIndex],
      child: Center(
        child: Text(
          title.isNotEmpty ? title[0].toUpperCase() : 'H',
          style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _formatText(String text) {
    if (text.isEmpty) return text;
    // Don't modify fully Arabic text structure, just apply to words
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      if (word.toLowerCase() == 'vip') return 'VIP';
      // If it's English, capitalize first letter, lower the rest
      // For Arabic, this won't change anything
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  void _showCourseSelectorBottomSheet(
      BuildContext context, CourseViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          shrinkWrap: true,
          children: viewModel.courses.map((course) {
            final isSelected = viewModel.selectedTitle == course.title;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: Text(
                  course.title,
                  style: isSelected
                      ? getBoldStyle(color: primaryColor, fontSize: FontSize.s16)
                      : getMediumStyle(color: blackColors, fontSize: FontSize.s14),
                ),
                trailing: isSelected ? Icon(Icons.check_circle, color: primaryColor) : null,
                onTap: () {
                  viewModel.selectTitle(course.title);
                  Navigator.pop(context);
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    Future.microtask(() async {
      final courseVM = Provider.of<CourseViewModel>(context, listen: false);
      final homeVM = Provider.of<HomeViewModel>(context, listen: false);

      if (homeVM.result == null) {
        await homeVM.getResultData();
      }

      await courseVM.loadOffers(homeResult: homeVM.result);

      if (mounted) {
        setState(() {
          selectedTab = courseVM.isOnline ? 0 : 1;
        });
      }
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.position.pixels;
        double delta = 150.0;
        
        if (currentScroll >= maxScroll) {
          _scrollController.animateTo(0, duration: const Duration(milliseconds: 1000), curve: Curves.easeOut);
        } else {
          _scrollController.animateTo(currentScroll + delta, duration: const Duration(milliseconds: 1000), curve: Curves.linear);
        }
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProfileViewModel>(context);
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("offers".tr(), style: getBoldStyle(color: primaryColor, fontSize: FontSize.s20)),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_bag_outlined, color: primaryColor, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const hatvest_cart.Cart()),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          // خلفية الصفحة
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/picc2.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // محتوى الصفحة
          Consumer<CourseViewModel>(
            builder: (context, viewModel, _) {
              return Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                height: 45, // Reduced height for a sleeker look
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTab = 0;
                            viewModel.toggleOnline(true);
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: selectedTab == 0 ? primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "online".tr(),
                            style: getBoldStyle(
                                color: selectedTab == 0 ? Colors.white : grey,
                                fontSize: FontSize.s14), // Slightly smaller font
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTab = 1;
                            viewModel.toggleOnline(false);
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: selectedTab == 1 ? primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "offline".tr(),
                            style: getBoldStyle(
                                color: selectedTab == 1 ? Colors.white : grey,
                                fontSize: FontSize.s14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () => _showCourseSelectorBottomSheet(context, viewModel),
                  child: Row(
                    children: [
                      SvgPicture.asset("assets/icons/filter.svg", color: primaryColor, width: 18),
                      const SizedBox(width: 8),
                      Text("filter".tr(), style: getBoldStyle(color: primaryColor, fontSize: FontSize.s15)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: viewModel.isOnline
                    ? _onlineOffersWidget(viewModel)
                    : _offlineOffersWidget(viewModel),
              ),
            ],
          );
            },
          ),
        ],
      ),
    );
  }

  Widget _onlineOffersWidget(CourseViewModel viewModel) {
    if (viewModel.isLoading) return const Center(child: CircularProgressIndicator());
    final offers = viewModel.selectedOffers;
    if (viewModel.selectedTitle == null || offers.isEmpty) {
      return Center(
        child: Text(
          "no_data".tr(),
          style: getMediumStyle(color: grey, fontSize: FontSize.s16),
        ),
      );
    }
    return _buildOffersGrid(offers);
  }

  Widget _offlineOffersWidget(CourseViewModel viewModel) {
    if (viewModel.isLoading) return const Center(child: CircularProgressIndicator());
    final offers = viewModel.selectedOffers;
    if (viewModel.selectedTitle == null || offers.isEmpty) {
      return Center(
        child: Text(
          "no_data".tr(),
          style: getMediumStyle(color: grey, fontSize: FontSize.s16),
        ),
      );
    }
    return _buildOffersGrid(offers);
  }

  Widget _buildOffersGrid(List<Offer> offers) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      itemCount: offers.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 15,
        childAspectRatio: 0.56,
      ),
      itemBuilder: (context, index) {
        final offer = offers[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => DeoplomInfo(
              offerId: int.tryParse(offer.id) ?? 0,
              offerData: offer,
            )));
          },
          child: Container(
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: offer.image != null && offer.image.isNotEmpty
                          ? Image.network(offer.image, width: double.infinity, height: 130, fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Image.asset("assets/images/courssess.png", height: 130, fit: BoxFit.cover))
                          : Image.asset("assets/images/courssess.png", height: 130, fit: BoxFit.cover),
                    ),
                    if (offer.oldFees != null && offer.oldFees!.isNotEmpty)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text("SALE".tr(), style: getBoldStyle(color: Colors.white, fontSize: FontSize.s12)),
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatText(offer.courseTitle ?? ''),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: getBoldStyle(color: context.textPrimary, fontSize: FontSize.s15),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _formatText(offer.title ?? ''),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: getMediumStyle(color: context.textSecondary, fontSize: FontSize.s12),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Text("${offer.fees} ج.م", style: getBoldStyle(color: primaryColor, fontSize: FontSize.s16)),
                                const Spacer(),
                                if (offer.oldFees != null)
                                  Text(offer.oldFees!, style: TextStyle(decoration: TextDecoration.lineThrough, color: grey, fontSize: FontSize.s12)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Consumer<CartViewModel>(
                              builder: (context, cartViewModel, _) {
                                final isLoading = cartViewModel.isItemLoading(offer.id);
                                return InkWell(
                                  onTap: isLoading ? null : () {
                                    cartViewModel.addItemToCart(context: context, itemId: offer.id, itemType: offer.itemType, itemTitleEn: offer.titleEn, itemTitleAr: offer.titleAr);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
                                      ],
                                    ),
                                    child: Center(
                                      child: isLoading
                                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                          : Text("add_to_arabic".tr(), style: getBoldStyle(color: Colors.white, fontSize: FontSize.s12)),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
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
