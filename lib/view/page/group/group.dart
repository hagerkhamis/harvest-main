import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/utils/display_localization.dart';
import 'package:hatvest/shared/widgets/snackbar_helper.dart';
import 'package:hatvest/view/page/book-web-viewpage/book-web-viewpage.dart';
import 'package:hatvest/view/page/exam-result/exam-result.dart' show ExamRuselt;
import 'package:hatvest/view/page/grammer-exam/grammer-exam.dart';
import 'package:hatvest/view/page/listening-exam/listening-exam.dart' show ListeningExamPage;
import 'package:hatvest/view/page/reading-exam/reading-exam.dart';
import 'package:hatvest/view/page/speaking-exam/speaking-exam.dart';
import 'package:hatvest/view/page/vocab-exam/vocab-exam.dart';
import 'package:hatvest/view/page/writing-exam/writing-exam.dart';
import 'package:hatvest/core/theme/app_colors.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/features/cart/presentation/pages/cart_page.dart' as hatvest_cart;
import 'package:hatvest/viewmodel/app-viewmodel.dart';
import 'package:provider/provider.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  int _selectedIndex = 0; // Default to Running groups

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileViewModel>(context, listen: false).loadGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "my_groups".tr(),
          style: getBoldStyle(color: primaryColor, fontSize: FontSize.s20),
        ),
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
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/picc8.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        
                        // Professional Segmented Tab Bar
                        Container(
                          height: 55,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: context.cardBg,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
                            ],
                          ),
                          child: Row(
                            children: [
                              _buildTabItem(0, "tab_running".tr()),
                              _buildTabItem(1, "tab_completed".tr()),
                              _buildTabItem(2, "tab_upcoming".tr()),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        _buildSelectedWidget(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.group_off_outlined, size: 70, color: primaryColor.withOpacity(0.4)),
          ),
          const SizedBox(height: 20),
          Text(
            "no_data".tr(),
            style: getBoldStyle(color: blackColors.withOpacity(0.7), fontSize: FontSize.s18),
          ),
          const SizedBox(height: 8),
          Text(
            "group_empty_subtitle".tr(),
            style: getRegularStyle(color: grey, fontSize: FontSize.s14),
          ),
        ],
      ),
    );
  }



  Widget _buildTabItem(int index, String text) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
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

  Widget _buildSelectedWidget() {
    if (_selectedIndex == 0) return _buildContinuous();
    if (_selectedIndex == 1) return _buildEnded();
    if (_selectedIndex == 2) return _buildNext();
    return const SizedBox();
  }

  Widget _buildContinuous() {
    final groupVM = Provider.of<ProfileViewModel>(context);
    if (groupVM.isLoading) return const Center(child: CircularProgressIndicator());
    if (groupVM.runningGroups.isEmpty) return _buildEmptyState();
    
    return ListView.builder(
      itemCount: groupVM.runningGroups.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, index) {
        final group = groupVM.runningGroups[index];
        return _buildGroupCard(group, groupVM);
      },
    );
  }

  Widget _buildEnded() {
    final groupVM = Provider.of<ProfileViewModel>(context);
    if (groupVM.isLoading) return const Center(child: CircularProgressIndicator());
    if (groupVM.completeGroups.isEmpty) return _buildEmptyState();
    
    return ListView.builder(
      itemCount: groupVM.completeGroups.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, index) {
        final group = groupVM.completeGroups[index];
        return _buildGroupCard(group, groupVM);
      },
    );
  }

  Widget _buildNext() {
    final groupVM = Provider.of<ProfileViewModel>(context);
    if (groupVM.isLoading) return const Center(child: CircularProgressIndicator());
    if (groupVM.upcomingGroups.isEmpty) return _buildEmptyState();
    
    return ListView.builder(
      itemCount: groupVM.upcomingGroups.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, index) {
        final group = groupVM.upcomingGroups[index];
        return _buildGroupCard(group, groupVM);
      },
    );
  }

  Widget _buildGroupCard(dynamic group, ProfileViewModel groupVM) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Icon(Icons.code, color: primaryColor, size: 18),
                const SizedBox(width: 10),
                Text("group_code".tr(), style: getBoldStyle(color: primaryColor, fontSize: FontSize.s14)),
                const Spacer(),
                Text(group.code, style: getBoldStyle(color: blackColors, fontSize: FontSize.s14)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                _buildInfoRow(Icons.calendar_today_outlined, "group_days".tr(), DisplayLocalization.days(group.days ?? '')),
                _buildInfoRow(Icons.meeting_room_outlined, "group_room".tr(), DisplayLocalization.room(group.room)),
                _buildInfoRow(Icons.location_on_outlined, "group_branch".tr(), DisplayLocalization.branch(group.branch)),
                _buildInfoRow(Icons.person_outline, "group_teacher".tr(), group.instructor),
                _buildInfoRow(Icons.access_time, "group_time".tr(), DisplayLocalization.time(group.time)),
                _buildInfoRow(Icons.layers_outlined, "group_level".tr(), DisplayLocalization.level(group.levels)),
                const Divider(height: 25),
                
                // Action Buttons Row (Exams, Books, Confirmation)
                _buildActionButtons(group, groupVM),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(dynamic group, ProfileViewModel groupVM) {
    return Column(
      children: [
        if (group.confirmation == 0 || group.confirmation.toString() == '0')
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("group_confirm".tr(), style: getBoldStyle(color: grey, fontSize: FontSize.s14)),
                Row(
                  children: [
                    _buildActionButton("group_confirm_yes".tr(), Colors.green, () => groupVM.sendConfirmation(confirmation: 1, groupId: group.id.toString())),
                    const SizedBox(width: 10),
                    _buildActionButton("group_confirm_no".tr(), Colors.red, () => groupVM.sendConfirmation(confirmation: 2, groupId: group.id.toString())),
                  ],
                ),
              ],
            ),
          )
        else if (group.confirmation != null)
           Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("group_confirm".tr(), style: getBoldStyle(color: grey, fontSize: FontSize.s14)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: group.confirmation == 1 || group.confirmation.toString() == '1'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    group.confirmation == 1 || group.confirmation.toString() == '1'
                        ? "group_confirmed".tr()
                        : "group_rejected".tr(),
                    style: getBoldStyle(
                      color: group.confirmation == 1 || group.confirmation.toString() == '1'
                          ? Colors.green
                          : Colors.red,
                      fontSize: FontSize.s12,
                    ),
                  ),
                ),
              ],
            ),
          ),

        Row(
          children: [
            // Exam Button
            if (group.examStatus != null && group.examStatus.toString().isNotEmpty)
              Expanded(
                child: _buildActionButton(
                  DisplayLocalization.groupExamStatus(
                    code: group.examStatusCode?.toString(),
                    label: group.examStatus?.toString(),
                  ),
                  primaryColor,
                  () => _handleExamNavigation(group),
                ),
              ),
            const SizedBox(width: 10),
            // Book Button
            if (group.book != null && group.book.isNotEmpty)
              Expanded(
                child: _buildActionButton(
                  "view_book".tr(),
                  Colors.blueGrey,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookWebViewPage(url: group.book))),
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _handleExamNavigation(dynamic group) {
    if (group.examStatusCode == "show_result") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ExamRuselt(applicationId: int.parse(group.studentExamId))));
    } else if (group.examStatusCode == "start_exam" || group.examStatusCode == "complete_exam") {
      final step = group.step?.toString() ?? "";
      if (step == "" || step == "2") {
        Navigator.push(context, MaterialPageRoute(builder: (context) => VocabExamPage(studentId: group.studentId, groupLevel: group.levels)));
      } else {
        switch (step) {
          case "3":
            Navigator.push(context, MaterialPageRoute(builder: (context) => GrammarExamPage(studentId: int.parse(group.studentExamId))));
            break;
          case "4":
            Navigator.push(context, MaterialPageRoute(builder: (context) => ReadingExamPage(applicationId: group.studentExamId)));
            break;
          case "5":
            Navigator.push(context, MaterialPageRoute(builder: (context) => ListeningExamPage(applicationId: group.studentExamId)));
            break;
          case "6":
            Navigator.push(context, MaterialPageRoute(builder: (context) => WritingExamPage(applicationId: group.studentExamId)));
            break;
          case "7":
            Navigator.push(context, MaterialPageRoute(builder: (context) => SpeakingQuestionPage(applicationId: int.parse(group.studentExamId))));
            break;
          default:
            Navigator.push(context, MaterialPageRoute(builder: (context) => ExamRuselt(applicationId: int.parse(group.studentExamId))));
        }
      }
    } else {
      showAwesomeSnackBar(
        title: "group_exam".tr(),
        message: DisplayLocalization.groupExamStatus(
          code: group.examStatusCode?.toString(),
          label: group.examStatus?.toString(),
        ),
        type: SnackbarType.info,
      );
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: primaryColor.withOpacity(0.6)),
          const SizedBox(width: 10),
          Text(label, style: getMediumStyle(color: context.textSecondary, fontSize: FontSize.s14)),
          const Spacer(),
          Text(
            value.isNotEmpty ? value : 'N/A',
            style: getBoldStyle(color: context.textPrimary, fontSize: FontSize.s14),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: getBoldStyle(color: color, fontSize: FontSize.s12), textAlign: TextAlign.center),
      ),
    );
  }
}
