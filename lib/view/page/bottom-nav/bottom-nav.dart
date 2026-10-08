import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hatvest/shared/widgets/placement_test_fab.dart';
import 'package:hatvest/shared/widgets/app-drawer.dart';
import 'package:hatvest/view/page/calendar/calendar_page.dart';
import 'package:hatvest/view/page/cart/cart.dart';
import 'package:hatvest/view/page/group/group.dart';
import 'package:hatvest/view/page/home/home-page.dart';
import 'package:hatvest/view/page/offers/offers-page.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart';
import 'package:provider/provider.dart';

class BottomNav extends StatefulWidget {
  final int index;

  const BottomNav({Key? key, this.index = 0}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late int _selectedIndex;
  bool _isDrawerOpen = false;

  final List<Widget> _pages = [
    const HomePage(),
    GroupPage(),
    OffersPage(),
    const CalendarPage(),
  ];

  final List<String> _baseIcons = const [
    "assets/icons/home",
    "assets/icons/group",
    "assets/icons/discount",
    "assets/icons/calendar",
    "assets/icons/menua", // Drawer
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index.clamp(0, _pages.length - 1);
    Future.microtask(() {
      if (!mounted) return;
      final profileVM = context.read<ProfileViewModel>();
      if (profileVM.profile == null) {
        profileVM.getProfile();
      }
    });
  }

  void _onItemTapped(int index) {
    if (index == _baseIcons.length - 1) {
      setState(() => _isDrawerOpen = true);
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  void goToGroupPage() {
    setState(() {
      _selectedIndex = 1;
      _isDrawerOpen = false;
    });
  }

  void _closeDrawer() {
    setState(() => _isDrawerOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final labels = [
      "home".tr(),
      "my_groups".tr(),
      "offers".tr(),
      "calendar".tr(),
      "menu".tr(),
    ];

    return Scaffold(

      body: Stack(
        children: [
          _pages[_selectedIndex],

          /// ✅ Drawer Overlay
          if (_isDrawerOpen)
            GestureDetector(
              onTap: _closeDrawer,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {}, // absorb taps inside drawer
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      color: Colors.white,
                      child: AppDrawer(
                        onClose: _closeDrawer,
                        onGoToGroupPage: goToGroupPage,
                      ),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),

          // Placement test — hidden when drawer is open
          if (_selectedIndex != 3 && !_isDrawerOpen)
            PositionedDirectional(
              end: 20,
              bottom: 110,
              child: const PlacementTestFab(),
            ),
        ],
      ),

      /// ✅ Bottom Navigation (Modern & Professional)
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_baseIcons.length, (index) {
              final isSelected = _selectedIndex == index;
              final iconPath = isSelected && index < _pages.length
                  ? "${_baseIcons[index]}-fill.svg"
                  : "${_baseIcons[index]}.svg";

              return GestureDetector(
                onTap: () => _onItemTapped(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        iconPath,
                        width: 26,
                        height: 26,
                        color: isSelected ? primaryColor : const Color(0xFF64748B),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[index],
                        style: TextStyle(
                          color: isSelected ? primaryColor : const Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
