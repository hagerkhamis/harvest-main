import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/utils/placement_test_helper.dart';
import 'package:hatvest/view/page/adult-result/adult-result.dart'
    show AdultRuselt;
import 'package:hatvest/view/page/kids-pt-result/kids-pt-result.dart'
    show kidsPtRuselt;
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart' show ProfileViewModel;
import 'package:hatvest/services/placement_test_service.dart';
import 'package:provider/provider.dart' show Provider;

class SelectLevel extends StatefulWidget {
  const SelectLevel({super.key});

  @override
  State<SelectLevel> createState() => _SelectLevelState();
}

class _SelectLevelState extends State<SelectLevel> {
  bool _checkedAccess = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final response = await PlacementTestService()
            .fetchPlacementTestAction()
            .timeout(const Duration(seconds: 15));
        if (!mounted) return;
        await PlacementTestHelper.handlePlacementTestAction(
          context,
          response,
          replaceCurrentRoute: true,
        );
      } catch (_) {
        // Stay on select-level UI so the user can still choose adult/kids.
      } finally {
        if (mounted) {
          setState(() => _checkedAccess = true);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_checkedAccess) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screenHeight = MediaQuery.sizeOf(context).height;
    final viewModel = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: dividerColor,
        title: Text(
          "placement_test_title".tr(),
          style: getBoldStyle(
            color: blackColors,
            fontSize: FontSize.s20,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_forward))
        ],
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: screenHeight * 0.08,
                  ),
                  Text(
                    "placement_select_test_type".tr(),
                    style: getBoldStyle(
                      color: blackColors,
                      fontSize: FontSize.s22,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.03,
                  ),
                  // get_adult_question.png
                  GestureDetector(
                      onTap: () {
                        final application =
                            viewModel.profile?.adultPtApplication;

                        if (application == null ||
                            (int.tryParse(application.finish) ?? 0) == 0) {
                          Navigator.pushNamed(context, '/adult-exam');
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdultRuselt(
                                applicationId: application.id,
                              ),
                            ),
                          );
                        }
                      },
                      child:
                          Image.asset("assets/images/get_adult_question.png")),

                  SizedBox(
                    height: screenHeight * 0.04,
                  ),
                  GestureDetector(
                      onTap: () {
                        final application =
                            viewModel.profile?.kidsPtApplication;

                        if (application == null ||
                            (int.tryParse(application.finish) ?? 0) == 0) {
                          Navigator.pushNamed(context, '/kids-pt');
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => kidsPtRuselt(
                                applicationId: application.id,
                              ),
                            ),
                          );
                        }
                      },
                      child:
                          Image.asset("assets/images/get_kids_questions.png")),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
