import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/view/page/cambridge-cretivcate/cambridge-certificate.dart'
    show CambridgeCertificate;
import 'package:hatvest/view/page/certificates_page/certificates_page.dart'
    show CertificatesPage;
import 'package:hatvest/view/page/harvest-cretivcate/harvest-certificate.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/cart-viewmodel.dart' show CartViewModel;
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart' show Html;

import '../../resources/font_manager.dart' show FontSize;

// Import your existing pages (but we’ll use them as widgets inside this screen)

class CertificatesTabsPage extends StatefulWidget {
  const CertificatesTabsPage({super.key});

  @override
  State<CertificatesTabsPage> createState() => _CertificatesTabsPageState();
}

class _CertificatesTabsPageState extends State<CertificatesTabsPage> {
  int _selectedIndex = 0;

  // final List<String> tabs = [
  //   "شهادة هارفست",
  //   "شهادة كامبريدج",
  //   "شهادة أخرى",
  // ];

  final List<String> tabs = [
    "harvest_certificate".tr(),
    "cambridge_certificate".tr(),
  ];

  Widget _buildSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return const HatvestCertificate();
      case 1:
        return const CambridgeCertificate();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("certificates".tr(),
            style: getBoldStyle(color: primaryColor, fontSize: FontSize.s20)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_forward, color: blackColors, size: 35),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/picc3.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
          // 🔹 Top Tabs
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabs.length, (index) {
                final isSelected = _selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: isSelected ? primaryColor : Colors.transparent),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        tabs[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? whiteColor : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // const Divider(),

          // 🔹 Show content for selected tab
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildSelectedPage(),
            ),
          ),
        ],
      ),
        ],
      ),
    );
  }
}
