import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/theme/app_colors.dart';
import 'package:hatvest/model/home-model.dart' show BestOffer;
import 'package:hatvest/shared/widgets/countdowntimer.dart'
    show CountdownTimer;
import 'package:hatvest/shared/widgets/custom_buttons.dart';
import 'package:hatvest/shared/widgets/networkimage-withheaders.dart'
    show NetworkImageWithHeaders;
import 'package:hatvest/shared/widgets/showterms-dialog.dart'
    show showTermsDialog;
import 'package:hatvest/core/utils/slide_link_helper.dart';
import 'package:hatvest/view/page/book-web-viewpage/book-web-viewpage.dart';
import 'package:hatvest/view/page/deoplom-info/deoplom-info.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart';
import 'package:hatvest/viewmodel/cart-viewmodel.dart';
import 'package:hatvest/viewmodel/home-viewmodel.dart' show HomeViewModel;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedTab = 0;

  int selectedTab2 = 0;

  double progressValue = 0.3;
  int currentIndex = 0;

  bool _checkedVersion = false;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final homeVM = Provider.of<HomeViewModel>(context, listen: false);
      homeVM.fetchSlides();
      homeVM.getProfile();
      homeVM.getResultData();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
      await profileVM.loadTerms();

      // safe null check
      if (profileVM.result != null && profileVM.result!.termsApprove == false) {
        await showTermsDialog(context);
      }
    });
  }

  void _showForceUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // prevent closing
      builder: (context) {
        return AlertDialog(
          title: Text(
            'force_update_title'.tr(),
            style: getBoldStyle(color: context.textPrimary, fontSize: FontSize.s20),
          ),
          content: Text(
            'force_update_message'.tr(),
            style: getMediumStyle(
              color: context.textPrimary,
            ),
          ),
          actions: [
            CustomButtons(
              onTap: () {
                launchUrl(Uri.parse(
                    'https://play.google.com/store/apps/details?id=com.harvest.harvest'));
              },
              text: "force_update_button".tr(),
            )
          ],
        );
      },
    );
  }

  Future<void> _onRefresh() async {
    final profileVM = Provider.of<HomeViewModel>(context, listen: false);
    await profileVM.getProfile();
    await profileVM.getResultData();
    // await profileVM.fetchDeals();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final viewModel = Provider.of<HomeViewModel>(context);
    final result = viewModel.result;
    final book = viewModel.result?.book;
    final bestOffer = viewModel.result?.bestOffer;
    final locale = context.locale;

    final double ptGrade = result?.allData.generalResult.ptResult.pt ?? 0.0;
    final double examGrade = double.tryParse(
            result?.allData?.generalResult?.ptResult?.allSkillsGrade ?? '') ??
        1.0;

    final double progress = (examGrade != 0.0) ? ptGrade / examGrade : 0.0;

    if (result == null) return const SizedBox();

    return Scaffold(
      body: Stack(
        children: [
          // Scrollable content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "welcome_harvest".tr(),
                                    style: getBoldStyle(
                                        color: context.textPrimary, fontSize: FontSize.s24),
                                  ),
                                  Text(
                                    "${viewModel.profile?.name}",
                                    style: getBoldStyle(
                                        color: context.textPrimary, fontSize: FontSize.s18),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.search, color: context.textPrimary, size: 28),
                              onPressed: () {
                                // TODO: Add search functionality
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.notifications_outlined, color: context.textPrimary, size: 28),
                              onPressed: () {
                                Navigator.of(context).pushNamed('/notifications');
                              },
                            ),
                            Image.asset("assets/images/logo.png", height: 40),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: screenHeight *
                        0.35, // ✅ fixed height instead of Expanded

                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: viewModel.slides.length,
                      onPageChanged: viewModel.setCurrentIndex,
                      itemBuilder: (context, index) {
                        final slide = viewModel.slides[index];
                        return GestureDetector(
                          onTap: () {
                            final link = SlideLinkHelper.resolve(slide.link);
                            if (link.isEmpty) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookWebViewPage(
                                  url: link,
                                  title: slide.title.isNotEmpty
                                      ? slide.title
                                      : null,
                                ),
                              ),
                            );
                          },
                          child: Stack(
                          fit: StackFit.expand,
                          children: [
                            NetworkImageWithHeaders(url: slide.image),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.center,
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 60,
                              left: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    slide.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    slide.text,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (bestOffer != null) buildBestOffer(bestOffer, context),
                  const SizedBox(height: 16),
                  _oflineCourses(context),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  _branchesSection(context),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  _certificatesSection(context),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  _digitalMaterialsSection(context),
                  SizedBox(
                    height: screenHeight * 0.01,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            "assets/images/level1.png",
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Book title & link
                                Text(
                                  book!.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                // Button to open webview
                                CustomButtons(
                                  width: 170,
                                  text: "book_offer".tr(),
                                  onTap: () {
                                    if (book!.link.isNotEmpty) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              BookWebViewPage(url: book.link),
                                        ),
                                      );
                                    }
                                  },
                                  color: primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.01,
                  ),
                  SizedBox(
                    height: 260,
                    child: PageView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // PT Result Page
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularPercentIndicator(
                              radius: 110.0,
                              lineWidth: 40.0,
                              animation: true,
                              percent: progress.clamp(0.0, 1.0),
                              center: Text(
                                "${(progress * 100).toInt()}%",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                              progressColor: primaryColor,
                              backgroundColor: Colors.grey[300]!,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              result.allData.generalResult.ptResult.ptLabel ??
                                  "",
                              style: getMediumStyle(color: context.textPrimary),
                            ),
                          ],
                        ),

                        // Exam Result Pages
                        if (result.allData.generalResult.examResult != null &&
                            result.allData.generalResult.examResult.isNotEmpty)
                          ...result!.allData.generalResult.examResult
                              .map((exam) {
                            final double resultValue =
                                double.tryParse(exam.result) ?? 0.0;
                            final double allSkillsGrade =
                                double.tryParse(exam.allSkillsGrade) ?? 1.0;
                            final double examProgress = (allSkillsGrade != 0)
                                ? resultValue / allSkillsGrade
                                : 0.0;

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularPercentIndicator(
                                  radius: 110.0,
                                  lineWidth: 40.0,
                                  animation: true,
                                  percent: examProgress.clamp(0.0, 1.0),
                                  center: Text(
                                    "${(examProgress * 100).toInt()}%",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                  progressColor: primaryColor,
                                  backgroundColor: Colors.grey[300]!,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  exam.level ?? "exam_level".tr(),
                                  style: getMediumStyle(color: context.textPrimary),
                                ),
                              ],
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.04,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _oflineCourses(BuildContext contex) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final viewModel = Provider.of<HomeViewModel>(context);

    final result = viewModel.result;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "offers".tr(),
                style:
                    getRegularStyle(color: context.textPrimary, fontSize: FontSize.s18),
              ),
            ],
          ),
          SizedBox(
            height: screenHeight * 0.02,
          ),
          SizedBox(
            width: 400,
            height: 400,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: result!.offlineOffers.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DeoplomInfo(
                            offerId: int.parse(result.offlineOffers[index].id)),
                      ),
                    );
                    // Navigator.of(context).pushReplacementNamed('/deplomeInfo');
                  },
                  child: Container(
                    width: 180,
                    decoration: const BoxDecoration(),
                    child: Column(
                      children: [
                        result.offlineOffers[index].image != null &&
                                result.offlineOffers[index].image.isNotEmpty
                            ? Image.network(
                                result.offlineOffers[index].image,
                                width: 180,
                                height: 110,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    "assets/images/courssess.png",
                                    width: 180,
                                    height: 110,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                "assets/images/courssess.png",
                                width: 180,
                                height: 110,
                                fit: BoxFit.cover,
                              ),
                        Container(
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 5),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: screenHeight * 0.02,
                                ),
                                Text(
                                  result.offlineOffers[index].courseTitle ?? '',
                                  style: getBoldStyle(
                                      color: whiteColor,
                                      fontSize: FontSize.s16),
                                ),
                                SizedBox(
                                  height: screenHeight * 0.004,
                                ),
                                Text(
                                  result.offlineOffers[index].title
                                          ?.split(' ')
                                          .take(3)
                                          .join(' ') ??
                                      '',
                                  style: getBoldStyle(
                                    color: whiteColor,
                                    fontSize: FontSize.s14,
                                  ),
                                ),
                                SizedBox(
                                  height: screenHeight * 0.01,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${result.offlineOffers[index].fees} / ج.م",
                                        style: getBoldStyle(
                                            color: whiteColor,
                                            fontSize: FontSize.s18),
                                      ),
                                      Text(
                                        result.offlineOffers[index].oldFees ??
                                            "",
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontWeight: FontWeight.bold,
                                            color: grey),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: screenHeight * 0.004,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0, vertical: 5.0),
                                  child: Card(
                                    elevation: 2.0,
                                    child: Consumer<CartViewModel>(
                                      builder: (context, cartViewModel, _) {
                                        final isLoading =
                                            cartViewModel.isItemLoading(
                                                result.offlineOffers[index].id);

                                        return GestureDetector(
                                          onTap: isLoading
                                              ? null
                                              : () {
                                                  cartViewModel.addItemToCart(
                                                    context: context,
                                                    itemId: result
                                                        .offlineOffers[index]
                                                        .id,
                                                    itemType: result
                                                        .offlineOffers[index]
                                                        .itemType,
                                                    itemTitleEn: result
                                                        .offlineOffers[index]
                                                        .titleEn,
                                                    itemTitleAr: result
                                                        .offlineOffers[index]
                                                        .titleAr,
                                                  );
                                                },
                                          child: Container(
                                            width: 140,
                                            height: 45.0,
                                            decoration: BoxDecoration(
                                              color: addCard,
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
                                SizedBox(
                                  height: screenHeight * 0.01,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBestOffer(BestOffer offer, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to DeoplomInfo page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DeoplomInfo(
              offerId: int.tryParse(offer.id) ?? 0, // safe parsing
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offer image
            offer.image.isNotEmpty
                ? Image.network(
                    offer.image,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    "assets/images/slid-re.png",
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    offer.courseTitle,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  CountdownTimer(endDate: offer.endDate),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "price".tr(namedArgs: {
                          "value": offer.fees.toString(),
                        }),
                        // "${"price".tr()}: ${offer.fees} ج.م",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      if (offer.oldFees.isNotEmpty)
                        Text(
                          "old_price".tr(namedArgs: {
                            "value": offer.oldFees.toString(),
                          }),
                          // "${"old_price".tr()}: ${offer.oldFees} ج.م",
                          style: const TextStyle(
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAccessSection(BuildContext context, String titleKey, IconData icon, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(route);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor.withOpacity(0.8), primaryColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: whiteColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: whiteColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  titleKey.tr(),
                  style: getBoldStyle(color: whiteColor, fontSize: FontSize.s18),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: whiteColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _branchesSection(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                "branches_title".tr(),
                style: getRegularStyle(color: context.textPrimary, fontSize: FontSize.s18),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/branches');
                  },
                  child: Container(
                    width: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor.withOpacity(0.8), primaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, color: whiteColor, size: 50),
                        const SizedBox(height: 12),
                        Text(
                          "branches_title".tr(),
                          style: getBoldStyle(color: whiteColor, fontSize: FontSize.s16),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _certificatesSection(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium, color: primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                "certificates_title".tr(),
                style: getRegularStyle(color: context.textPrimary, fontSize: FontSize.s18),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/all-certificate');
                  },
                  child: Container(
                    width: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor.withOpacity(0.8), primaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.workspace_premium, color: whiteColor, size: 50),
                        const SizedBox(height: 12),
                        Text(
                          "certificates_title".tr(),
                          style: getBoldStyle(color: whiteColor, fontSize: FontSize.s16),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _digitalMaterialsSection(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.menu_book, color: primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                "digital_materials_title".tr(),
                style: getRegularStyle(color: context.textPrimary, fontSize: FontSize.s18),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/digtal-book');
                  },
                  child: Container(
                    width: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor.withOpacity(0.8), primaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, color: whiteColor, size: 50),
                        const SizedBox(height: 12),
                        Text(
                          "digital_materials_title".tr(),
                          style: getBoldStyle(color: whiteColor, fontSize: FontSize.s16),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

