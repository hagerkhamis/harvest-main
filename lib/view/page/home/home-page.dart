import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/theme/app_colors.dart';
import 'package:hatvest/model/home-model.dart' show BestOffer;
import 'package:hatvest/model/offer_model.dart' show Course, Offer;
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
import 'package:hatvest/view/page/offers/offers-page.dart';
import 'package:hatvest/core/theme/app_colors.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart';
import 'package:hatvest/viewmodel/cart-viewmodel.dart';
import 'package:hatvest/viewmodel/home-viewmodel.dart' show HomeViewModel;
import 'package:hatvest/viewmodel/serives.dart' show CourseViewModel;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hatvest/features/cart/presentation/pages/cart_page.dart' as hatvest_cart;
import 'package:hatvest/view/page/search/search_page.dart';
import 'package:hatvest/view/page/survey-page/survey-page.dart';
import 'package:hatvest/shared/widgets/loading_indicator.dart';


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
  final ScrollController _offersScrollController = ScrollController();
  Timer? _offersTimer;
  Timer? _sliderTimer;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final homeVM = Provider.of<HomeViewModel>(context, listen: false);
      homeVM.fetchSlides();
      homeVM.getProfile();
      homeVM.getResultData();
      
      final cartVM = Provider.of<CartViewModel>(context, listen: false);
      cartVM.getCart();

      // Pre-load courses so they are available for slide navigation
      final courseVM = Provider.of<CourseViewModel>(context, listen: false);
      courseVM.fetchCoursesOnlien();
      courseVM.fetchCoursesOflien();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
      await profileVM.loadTerms();

      // safe null check
      if (profileVM.result != null && profileVM.result!.termsApprove == false) {
        await showTermsDialog(context);
      }
      
      // Start auto scroll for offers
      _startAutoScroll();
      // Start auto scroll for main slider
      _startSliderAutoScroll();
    });
  }


  void _startAutoScroll() {
    _offersTimer?.cancel();
    _offersTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_offersScrollController.hasClients) {
        double maxScroll = _offersScrollController.position.maxScrollExtent;
        double currentScroll = _offersScrollController.offset;
        double itemWidth = 197.0; // card width (180) + separator (14)

        if (currentScroll >= maxScroll) {
          _offersScrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 1200), // More fluid duration
            curve: Curves.easeOutQuint, // Smoother curve
          );
        } else {
          _offersScrollController.animateTo(
            currentScroll + itemWidth,
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutQuint,
          );
        }
      }
    });
  }

  void _startSliderAutoScroll() {
    _sliderTimer?.cancel();
    _sliderTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final slidesCount = Provider.of<HomeViewModel>(context, listen: false).slides.length;
        final count = slidesCount > 0 ? slidesCount : 3;
        int nextIndex = (currentIndex + 1) % count;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _offersScrollController.dispose();
    _offersTimer?.cancel();
    _sliderTimer?.cancel();
    super.dispose();
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

  void _handleSlideNavigation(BuildContext context, String link, String title) {
    final trimmedLink = link.trim().toLowerCase();
    final trimmedTitle = title.trim().toLowerCase();
    debugPrint('SLIDE TAPPED => link: "$trimmedLink", title: "$title"');

    // إذا كان الـ link فاضي، نتعامل بناءً على الـ title
    if (trimmedLink.isEmpty || trimmedLink == '#') {
      // التعامل بناءً على العنوان فقط
      if (trimmedTitle.contains('level_test') || 
          trimmedTitle.contains('placement') ||
          trimmedTitle.contains('اختبار') ||
          trimmedTitle.contains('تحديد المستوى')) {
        Navigator.pushNamed(context, '/exams');
        return;
      }

      if (trimmedTitle.contains('kids_diploma') || 
          trimmedTitle.contains('diploma_kids') ||
          trimmedTitle.contains('الطفل الذكي') ||
          trimmedTitle.contains('دبلومة الطفل') ||
          trimmedTitle.contains('kidzy')) {
        Navigator.pushNamed(context, '/offers');
        return;
      }

      if (trimmedTitle.contains('american_dialect') || 
          trimmedTitle.contains('اللهجة الأمريكية') ||
          trimmedTitle.contains('أمريكية')) {
        Navigator.pushNamed(context, '/offers');
        return;
      }

      if (trimmedTitle.contains('graduates') || 
          trimmedTitle.contains('خريجين') ||
          trimmedTitle.contains('طلابنا')) {
        Navigator.pushNamed(context, '/all-certificate');
        return;
      }

      if (trimmedTitle.contains('annual_subscription') || 
          trimmedTitle.contains('اشتراك سنوي') ||
          trimmedTitle.contains('سنوي')) {
        Navigator.pushNamed(context, '/offers');
        return;
      }

      if (trimmedTitle.contains('offers') || 
          trimmedTitle.contains('عروض') ||
          trimmedTitle.contains('ريمونتادا')) {
        Navigator.pushNamed(context, '/offers');
        return;
      }

      // إذا مفيش match، مش هنعمل حاجة
      return;
    }

    // التعامل مع الروابط الداخلية في التطبيق (بناءً على الـ link)
    if (trimmedLink.contains('level_test') || 
        trimmedLink.contains('placement') ||
        trimmedLink.contains('login') ||
        trimmedTitle.contains('اختبار') ||
        trimmedTitle.contains('تحديد المستوى')) {
      Navigator.pushNamed(context, '/exams');
      return;
    }

    if (trimmedLink.contains('kids_diploma') || 
        trimmedLink.contains('diploma_kids') ||
        trimmedLink.contains('kidzy') ||
        trimmedLink.contains('show_offer') ||
        trimmedTitle.contains('الطفل الذكي') ||
        trimmedTitle.contains('دبلومة الطفل')) {
      Navigator.pushNamed(context, '/offers');
      return;
    }

    if (trimmedLink.contains('american_dialect') || 
        trimmedTitle.contains('اللهجة الأمريكية')) {
      Navigator.pushNamed(context, '/offers');
      return;
    }

    if (trimmedLink.contains('graduates') || 
        trimmedTitle.contains('خريجين') ||
        trimmedTitle.contains('طلابنا')) {
      Navigator.pushNamed(context, '/all-certificate');
      return;
    }

    if (trimmedLink.contains('annual_subscription') || 
        trimmedTitle.contains('اشتراك سنوي')) {
      Navigator.pushNamed(context, '/offers');
      return;
    }

    if (trimmedLink.contains('offers') || 
        trimmedTitle.contains('عروض')) {
      Navigator.pushNamed(context, '/offers');
      return;
    }

    // إذا كان رابط خارجي (http/https)، افتحه في WebView
    if (trimmedLink.startsWith('http://') || trimmedLink.startsWith('https://')) {
      final resolvedLink = SlideLinkHelper.resolve(link);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookWebViewPage(
            url: resolvedLink,
            title: title.isNotEmpty ? title : null,
          ),
        ),
      );
      return;
    }

    // الافتراضي: لو في link مش فاضي، فتحه في WebView
    final resolvedLink = SlideLinkHelper.resolve(link);
    if (resolvedLink.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookWebViewPage(
            url: resolvedLink,
            title: title.isNotEmpty ? title : null,
          ),
        ),
      );
    }
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

    if (viewModel.isLoading && result == null) {
      return Scaffold(
        body: Center(
          child: LoadingIndicator(color: primaryColor),
        ),
      );
    }
    
    if (result == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                viewModel.errorMessage ?? "load_error".tr(),
                style: getMediumStyle(color: context.textPrimary, fontSize: FontSize.s16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => viewModel.getResultData(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text(
                  "retry".tr(),
                  style: getBoldStyle(color: Colors.white, fontSize: FontSize.s14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // خلفية الصفحة
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/picc1.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "welcome_harvest".tr(),
                                style: getBoldStyle(
                                    color: context.textPrimary, fontSize: FontSize.s20),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SearchPage(),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.search, color: primaryColor, size: 30),
                                ),
                                Stack(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/notifications');
                                      },
                                      icon: Icon(Icons.notifications_outlined, color: primaryColor, size: 30),
                                    ),
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: const Text(
                                          '1',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Consumer<CartViewModel>(
                                  builder: (context, cartVM, _) {
                                    final cartCount = cartVM.cart.length;
                                    return Stack(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => const hatvest_cart.Cart(),
                                              ),
                                            );
                                          },
                                          icon: Icon(Icons.shopping_bag_outlined, color: primaryColor, size: 30),
                                        ),
                                        if (cartCount > 0)
                                          Positioned(
                                            right: 8,
                                            top: 8,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              constraints: const BoxConstraints(
                                                minWidth: 16,
                                                minHeight: 16,
                                              ),
                                              child: Text(
                                                '$cartCount',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                                Image.asset(
                                  "assets/images/logo.png",
                                  height: 35,
                                )
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          " ${viewModel.profile?.name}",
                          style: getBoldStyle(
                              color: context.textPrimary, fontSize: FontSize.s16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Image Slider Section
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      SizedBox(
                        height: screenHeight * 0.22,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: viewModel.slides.isNotEmpty ? viewModel.slides.length : 3,
                          onPageChanged: (index) {
                            setState(() {
                              currentIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            if (viewModel.slides.isNotEmpty) {
                              final slide = viewModel.slides[index];
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  _handleSlideNavigation(context, slide.link, slide.title);
                                },
                                child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    )
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      slide.image.isNotEmpty
                                          ? NetworkImageWithHeaders(
                                              url: slide.image,
                                              fit: BoxFit.cover,
                                              errorWidget: slide.bkImage.isNotEmpty
                                                  ? NetworkImageWithHeaders(url: slide.bkImage, fit: BoxFit.cover)
                                                  : Image.asset("assets/images/pic${(index % 3) + 1}.png", fit: BoxFit.cover),
                                            )
                                          : slide.bkImage.isNotEmpty
                                              ? NetworkImageWithHeaders(
                                                  url: slide.bkImage,
                                                  fit: BoxFit.cover,
                                                  errorWidget: Image.asset("assets/images/pic${(index % 3) + 1}.png", fit: BoxFit.cover),
                                                )
                                              : Image.asset(
                                                  "assets/images/pic${(index % 3) + 1}.png",
                                                  fit: BoxFit.cover,
                                                ),
                                      if (slide.title.isNotEmpty) ...[
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.center,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 25,
                                          left: 15,
                                          right: 15,
                                          child: Text(
                                            slide.title,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: getBoldStyle(color: Colors.white, fontSize: FontSize.s16),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                            }

                            final List<String> localImages = [
                              "assets/images/pic1.png",
                              "assets/images/pic2.png",
                              "assets/images/pic3.png",
                            ];
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.asset(
                                  localImages[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Dots Indicator
                      Positioned(
                        bottom: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(viewModel.slides.isNotEmpty ? viewModel.slides.length : 3, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              width: currentIndex == index ? 20 : 8,
                              decoration: BoxDecoration(
                                color: currentIndex == index ? Colors.white : Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  if (bestOffer != null) buildBestOffer(bestOffer, context),
                  const SizedBox(height: 20),
                  _oflineCourses(context),
                  const SizedBox(height: 20),
                  _branchesSection(context),
                  const SizedBox(height: 12),
                  _certificatesSection(context),
                  const SizedBox(height: 12),
                  _digitalMaterialsSection(context),
                  const SizedBox(height: 12),
                  _examsSection(context),
                  const SizedBox(height: 12),
                  _trackProgressSection(context),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "exam_level".tr(),
                          style: getBoldStyle(color: context.textPrimary, fontSize: FontSize.s18),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: context.cardBg,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                            ]
                          ),
                          child: PageView(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularPercentIndicator(
                                    radius: 60.0,
                                    lineWidth: 12.0,
                                    animation: true,
                                    percent: progress.clamp(0.0, 1.0),
                                    center: Text(
                                      "${(progress * 100).toInt()}%",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                    progressColor: primaryColor,
                                    backgroundColor: Colors.grey[200]!,
                                    circularStrokeCap: CircularStrokeCap.round,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    result.allData.generalResult.ptResult.ptLabel ?? "",
                                    style: getMediumStyle(color: grey, fontSize: FontSize.s14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(String title) {
    // Generate a color based on the title
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
      width: 180,
      height: 115,
      color: colors[colorIndex],
      child: Center(
        child: Text(
          title.isNotEmpty ? title[0].toUpperCase() : 'H',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _oflineCourses(BuildContext context) {
    return Consumer<CourseViewModel>(
      builder: (context, courseVM, _) {
        // Use all offline courses directly regardless of isOnline flag
        final offers = courseVM.allOfflineCourses.expand((c) => c.offers).toList();

        if (offers.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  "offers".tr(),
                  style: getBoldStyle(color: Colors.black, fontSize: FontSize.s18),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 310,
                child: ListView.separated(
                  controller: _offersScrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: offers.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DeoplomInfo(
                              offerId: int.tryParse(offer.id) ?? 0,
                              offerData: offer,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 180,
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.divider, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                              child: Stack(
                                children: [
                                  offer.image.isNotEmpty
                                      ? Image.network(
                                          offer.image,
                                          width: 180,
                                          height: 115,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Image.asset(
                                            "assets/images/courssess.png",
                                            width: 180,
                                            height: 115,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Image.asset(
                                          "assets/images/courssess.png",
                                          width: 180,
                                          height: 115,
                                          fit: BoxFit.cover,
                                        ),
                                  if (offer.oldFees.isNotEmpty && offer.oldFees != '0')
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          "SALE".tr(),
                                          style: getBoldStyle(color: Colors.white, fontSize: FontSize.s12),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    offer.courseTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: getBoldStyle(color: primaryColor, fontSize: FontSize.s14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    offer.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: getMediumStyle(color: context.textSecondary, fontSize: FontSize.s12),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Text(
                                        "${offer.fees} ج.م",
                                        style: getBoldStyle(color: const Color(0xFF1B5E20), fontSize: FontSize.s15),
                                      ),
                                      const SizedBox(width: 8),
                                      if (offer.oldFees.isNotEmpty && offer.oldFees != '0')
                                        Text(
                                          offer.oldFees,
                                          style: TextStyle(
                                            decoration: TextDecoration.lineThrough,
                                            color: Colors.grey.shade500,
                                            fontSize: 10,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Consumer<CartViewModel>(
                                    builder: (context, cartViewModel, _) {
                                      final isLoading = cartViewModel.isItemLoading(offer.id);
                                      return GestureDetector(
                                        onTap: isLoading ? null : () {
                                          cartViewModel.addItemToCart(
                                            context: context,
                                            itemId: offer.id,
                                            itemType: offer.itemType,
                                            itemTitleEn: offer.titleEn,
                                            itemTitleAr: offer.titleAr,
                                          );
                                        },
                                        child: Container(
                                          height: 38,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius: BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: primaryColor.withOpacity(0.4),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              )
                                            ],
                                          ),
                                          child: Center(
                                            child: isLoading
                                                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                                : Text(
                                                    "add_to_arabic".tr(),
                                                    style: getBoldStyle(color: Colors.white, fontSize: FontSize.s12),
                                                  ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
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
      },
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

  Widget _branchesSection(BuildContext context) {
    return _quickNavCard(
      context,
      title: "branches_title".tr(),
      subtitle: "page_branches".tr(),
      icon: Icons.location_on_rounded,
      route: '/branches',
      color1: const Color(0xFF56AB2F),
      color2: const Color(0xFFA8E063),
    );
  }

  Widget _certificatesSection(BuildContext context) {
    return _quickNavCard(
      context,
      title: "certificates_title".tr(),
      subtitle: "drawer_certificates".tr(),
      icon: Icons.workspace_premium_rounded,
      route: '/all-certificate',
      color1: const Color(0xFF11998E),
      color2: const Color(0xFF38EF7D),
    );
  }

  Widget _digitalMaterialsSection(BuildContext context) {
    return _quickNavCard(
      context,
      title: "digital_materials_title".tr(),
      subtitle: "drawer_digital_materials".tr(),
      icon: Icons.menu_book_rounded,
      route: '/digtal-book',
      color1: const Color(0xFF4776E6),
      color2: const Color(0xFF8E54E9),
    );
  }

  Widget _examsSection(BuildContext context) {
    return _quickNavCard(
      context,
      title: "exams_title".tr(),
      subtitle: "drawer_exams".tr(),
      icon: Icons.quiz_rounded,
      route: '/exams',
      color1: const Color(0xFFf7971e),
      color2: const Color(0xFFffd200),
    );
  }

  Widget _trackProgressSection(BuildContext context) {
    return _quickNavCard(
      context,
      title: "page_track_progress".tr(),
      subtitle: "drawer_progress".tr(),
      icon: Icons.trending_up_rounded,
      route: '/track-progress',
      color1: const Color(0xFFe52d27),
      color2: const Color(0xFFb31217),
    );
  }

  Widget _quickNavCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
    required Color color1,
    required Color color2,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(route),
        child: Container(
          width: double.infinity,
          height: 90,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color1, color2],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color1.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: getBoldStyle(color: Colors.white, fontSize: FontSize.s18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: getRegularStyle(color: Colors.white.withOpacity(0.85), fontSize: FontSize.s13),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.8), size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



