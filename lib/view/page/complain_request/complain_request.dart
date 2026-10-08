import 'package:easy_localization/easy_localization.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hatvest/view/page/add-complain/add-complain.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart';
import 'package:provider/provider.dart';

class ComplainRequest extends StatefulWidget {
  const ComplainRequest({super.key});

  @override
  State<ComplainRequest> createState() => _ComplainRequestState();
}

class _ComplainRequestState extends State<ComplainRequest> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ProfileViewModel>(context, listen: false).fetchComplainData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProfileViewModel>(context);

    final inquiries = _selectedIndex == 0
        ? viewModel.openInquiries
        : viewModel.closedInquiries;

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "page_complaint".tr(),
          style: getBoldStyle(color: primaryColor, fontSize: FontSize.s18),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_forward, color: primaryColor, size: 28),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
              children: [
                // Thinner Add Complaint Card
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 10, 25, 15),
                  child: GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddComplain(labelTypes: viewModel.labelTypes),
                        ),
                      );
                      if (mounted) {
                        Provider.of<ProfileViewModel>(context, listen: false).fetchComplainData();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
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
                          Icon(Icons.add_circle, color: primaryColor, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            "add_complaint_btn".tr(),
                            style: getBoldStyle(color: primaryColor, fontSize: FontSize.s15),
                          ),
                          const Spacer(),
                          Icon(Icons.chevron_right, color: grey.withOpacity(0.5), size: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                // Sleeker & Smaller Tabs
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  height: 38,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Row(
                    children: [
                      _buildTabItem(0, "tab_ongoing".tr()),
                      _buildTabItem(1, "tab_ended".tr()),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : inquiries.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              itemCount: inquiries.length,
                              itemBuilder: (context, index) {
                                return _buildInquiryCard(inquiries[index]);
                              },
                            ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildTabItem(int index, String text) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            text,
            style: getBoldStyle(
              color: isSelected ? Colors.white : grey,
            fontSize: FontSize.s14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInquiryCard(dynamic inquiry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            inquiry.inquire,
            style: getBoldStyle(color: blackColors, fontSize: FontSize.s14),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 15,
            runSpacing: 8,
            children: [
              _buildSmallInfo(Icons.location_on, inquiry.branchName),
              _buildSmallInfo(Icons.calendar_today, inquiry.reqistration),
              _buildSmallInfo(Icons.access_time_filled, "days_overdue".tr(namedArgs: {'count': inquiry.overdue.toString()}), color: Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInfo(IconData icon, String value, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color ?? grey),
        const SizedBox(width: 4),
        Text(value, style: getMediumStyle(color: color ?? grey, fontSize: FontSize.s12)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        "no_data_now".tr(),
        style: getMediumStyle(color: grey, fontSize: FontSize.s14),
      ),
    );
  }
}
