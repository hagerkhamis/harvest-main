import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hatvest/proveider/locale_provider.dart';
import 'package:hatvest/proveider/theme_provider.dart';
import 'package:hatvest/core/theme/app_colors.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart';
import 'package:hatvest/viewmodel/auth_viewmodel.dart';
import 'package:hatvest/viewmodel/cart-viewmodel.dart';
import 'package:hatvest/viewmodel/home-viewmodel.dart';
import 'package:hatvest/viewmodel/serives.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback? onClose;
  final VoidCallback? onGoToGroupPage;

  const AppDrawer({super.key, this.onClose, this.onGoToGroupPage});

  Future<void> reloadAllData(BuildContext context) async {
    final homeVM = context.read<HomeViewModel>();
    final profileVM = context.read<ProfileViewModel>();
    final courseVM = context.read<CourseViewModel>();
    final cartVM = context.read<CartViewModel>();

    await Future.wait([
      homeVM.fetchSlides(),
      homeVM.getProfile(),
      homeVM.getResultData(),
      profileVM.loadGroups(),
      courseVM.fetchCoursesOnlien(),
      courseVM.fetchCoursesOflien(),
      cartVM.getCart(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context, viewModel),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildMenuItem(context,
                      onTap: () => Navigator.pushNamed(context, '/serviesPage'),
                      icon: Icons.grid_view_rounded,
                      title: "drawer_services".tr()),
                  _buildMenuItem(context,
                      onTap: () => Navigator.pushNamed(context, '/myPayment'),
                      icon: Icons.receipt_long_rounded,
                      title: "drawer_payments".tr()),
                  _buildMenuItem(context,
                      onTap: () => Navigator.pushNamed(context, '/digtal-book'),
                      icon: Icons.menu_book_rounded,
                      title: "drawer_digital_materials".tr()),
                  _buildMenuItem(context,
                      onTap: () => Navigator.pushNamed(context, '/track-progress'),
                      icon: Icons.bar_chart_rounded,
                      title: "drawer_progress".tr()),
                  _buildDivider(),
                  _buildMenuItem(context,
                      onTap: () => Navigator.pushNamed(context, '/inquiries-requests'),
                      icon: Icons.help_outline_rounded,
                      title: "drawer_inquiries".tr()),
                  _buildExpandableRequests(context),
                  _buildMenuItem(context,
                      onTap: () => Navigator.pushNamed(context, '/all-certificate'),
                      icon: Icons.workspace_premium_rounded,
                      title: "drawer_certificates".tr()),
                  _buildDivider(),
                  _buildMenuItem(context,
                      onTap: () => Navigator.pushNamed(context, '/about-page'),
                      icon: Icons.support_agent_rounded,
                      title: "drawer_help".tr()),
                  _buildMenuItem(context,
                      onTap: () => Navigator.pushNamed(context, '/get_help'),
                      icon: Icons.info_outline_rounded,
                      title: "drawer_about_app".tr()),
                  _buildMenuItem(context,
                      onTap: () => Navigator.pushNamed(context, '/branches'),
                      icon: Icons.location_on_outlined,
                      title: "drawer_branches".tr()),
                  _buildMenuItem(context,
                      onTap: () => Navigator.pushNamed(context, '/exams'),
                      icon: Icons.assignment_outlined,
                      title: "drawer_exams".tr()),
                  _buildDivider(),
                  _buildMenuItem(context,
                      onTap: () async {
                        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                        await authViewModel.logout();
                        if (!context.mounted) return;
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/welcome',
                          (route) => false,
                        );
                      },
                      icon: Icons.logout_rounded,
                      title: "drawer_logout".tr(),
                      color: Colors.redAccent),
                  const SizedBox(height: 16),
                  _buildSocialSection(context),
                  const SizedBox(height: 16),
                  _buildFooterControls(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HomeViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: AlignmentDirectional.topStart,
            child: IconButton(
              onPressed: onClose ?? () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/profilePage'),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      "assets/images/profile.png",
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/profilePage'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewModel.profile?.name ?? '',
                        style: getBoldStyle(color: Colors.white, fontSize: FontSize.s18),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "user_status_client".tr(),
                          style: getMediumStyle(color: Colors.white, fontSize: FontSize.s12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required VoidCallback onTap,
    required IconData icon,
    required String title,
    Color? color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemColor = color ?? context.textPrimary;
    final iconColor = color ?? (isDark ? Colors.white : primaryColor);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: getMediumStyle(color: itemColor, fontSize: FontSize.s16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Divider(color: Colors.black12, thickness: 0.5),
    );
  }

  Widget _buildExpandableRequests(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : primaryColor;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        leading: Icon(Icons.assignment_outlined, size: 22, color: iconColor),
        title: Text(
          "drawer_requests".tr(),
          style: getMediumStyle(color: context.textPrimary, fontSize: FontSize.s16),
        ),
        iconColor: iconColor,
        collapsedIconColor: isDark ? Colors.white70 : Colors.grey,
        children: [
          _buildSubMenuItem(
            context,
            onTap: () => Navigator.pushNamed(context, '/complain_request'),
            icon: Icons.report_problem_outlined,
            title: "drawer_complaint".tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: getBoldStyle(color: context.textPrimary, fontSize: FontSize.s15),
          ),
        ],
      ),
    );
  }

  Widget _buildSubMenuItem(
    BuildContext context, {
    required VoidCallback onTap,
    required IconData icon,
    required String title,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : primaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 4, 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: getMediumStyle(color: context.textPrimary, fontSize: FontSize.s15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialSection(BuildContext context) {
    final profileVM = context.watch<ProfileViewModel>();
    final links = profileVM.socialLinks;

    if (!profileVM.socialLinksFetched) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProfileViewModel>().fetchAboutApp();
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "follow_us".tr(),
          style: getMediumStyle(color: context.textSecondary, fontSize: FontSize.s12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if ((links['tiktok'] ?? '').isNotEmpty)
              _socialIcon(
                faIcon: FontAwesomeIcons.tiktok,
                bgColor: Colors.black,
                iconColor: Colors.white,
                onTap: () => _launchUrl(links['tiktok']!),
              ),
            if ((links['tiktok'] ?? '').isNotEmpty) const SizedBox(width: 10),
            if ((links['youtube'] ?? '').isNotEmpty)
              _socialIcon(
                faIcon: FontAwesomeIcons.youtube,
                bgColor: const Color(0xFFFF0000),
                iconColor: Colors.white,
                onTap: () => _launchUrl(links['youtube']!),
              ),
            if ((links['youtube'] ?? '').isNotEmpty) const SizedBox(width: 10),
            if ((links['twitter'] ?? '').isNotEmpty)
              _socialIcon(
                faIcon: FontAwesomeIcons.xTwitter,
                bgColor: Colors.black,
                iconColor: Colors.white,
                onTap: () => _launchUrl(links['twitter']!),
              ),
            if ((links['twitter'] ?? '').isNotEmpty) const SizedBox(width: 10),
            if ((links['instagram'] ?? '').isNotEmpty)
              _socialIcon(
                faIcon: FontAwesomeIcons.instagram,
                bgColor: const Color(0xFFE1306C),
                iconColor: Colors.white,
                onTap: () => _launchUrl(links['instagram']!),
              ),
            if ((links['instagram'] ?? '').isNotEmpty) const SizedBox(width: 10),
            if ((links['facebook'] ?? '').isNotEmpty)
              _socialIcon(
                faIcon: FontAwesomeIcons.facebookF,
                bgColor: const Color(0xFF1877F2),
                iconColor: Colors.white,
                onTap: () => _launchUrl(links['facebook']!),
              ),
          ],
        ),
      ],
    );
  }

  Widget _socialIcon({
    required FaIconData faIcon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: FaIcon(faIcon, color: iconColor, size: 20),
        ),
      ),
    );
  }

  Widget _buildFooterControls(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    return Column(
      children: [
        // Dark/Light toggle
        GestureDetector(
          onTap: () => themeProvider.toggleTheme(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModeOption(
                  icon: Icons.nightlight_round,
                  label: "Dark",
                  isSelected: isDark,
                  selectedBg: const Color(0xFF162740),
                  selectedIconColor: Colors.white,
                  unselectedIconColor: Colors.grey,
                ),
                const SizedBox(width: 4),
                _buildModeOption(
                  icon: Icons.wb_sunny_rounded,
                  label: "Light",
                  isSelected: !isDark,
                  selectedBg: Colors.white,
                  selectedIconColor: const Color(0xFFFFC107),
                  unselectedIconColor: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Language buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLangBtn(context, "AR", context.locale.languageCode == 'ar'),
            const SizedBox(width: 20),
            _buildLangBtn(context, "EN", context.locale.languageCode == 'en'),
          ],
        ),
      ],
    );
  }

  Widget _buildModeOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color selectedBg,
    required Color selectedIconColor,
    required Color unselectedIconColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? selectedBg : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isSelected
            ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)]
            : [],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? selectedIconColor : unselectedIconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? selectedIconColor : unselectedIconColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangBtn(BuildContext context, String lang, bool isSelected) {
    return GestureDetector(
      onTap: () => _changeLanguage(context, lang.toLowerCase()),
      child: Container(
        width: 60,
        height: 35,
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8)]
              : [],
        ),
        child: Center(
          child: Text(
            lang,
            style: getBoldStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontSize: FontSize.s14,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } catch (e) {
        debugPrint('Could not launch $url: $e');
      }
    }
  }

  Future<void> _changeLanguage(BuildContext context, String lang) async {
    if (context.locale.languageCode == lang) return;
    await context.setLocale(Locale(lang));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', lang);
    context.read<LocaleProvider>().changeDirection(lang);
    reloadAllData(context);
  }
}
