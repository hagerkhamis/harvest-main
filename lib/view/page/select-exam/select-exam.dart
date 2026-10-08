import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/utils/placement_test_helper.dart';
import 'package:hatvest/shared/widgets/custom_buttons.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart' show ProfileViewModel;
import 'package:provider/provider.dart';

class SelectExam extends StatelessWidget {
  const SelectExam({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.08),
              Text(
                "placement_select_language".tr(),
                style: getBoldStyle(color: blackColors, fontSize: FontSize.s22),
              ),
              SizedBox(height: screenHeight * 0.03),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  PlacementTestHelper.handlePlacementTestTap(context);
                },
                child: Card(
                  color: whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 8.0),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              "placement_english_language".tr(),
                              style: getBoldStyle(color: blackColors, fontSize: FontSize.s18),
                            ),
                            SizedBox(height: screenHeight * 0.04),
                            CustomButtons(
                              width: 140,
                              height: 50,
                              color: addCard,
                              text: "start_now".tr(),
                              onTap: () {
                                PlacementTestHelper.handlePlacementTestTap(context);
                              },
                            )
                          ],
                        ),
                        const Spacer(),
                        Image.asset("assets/images/en-lan.png"),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
