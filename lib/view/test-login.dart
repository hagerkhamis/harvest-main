import 'package:flutter/material.dart';
import 'package:hatvest/shared/widgets/custom_buttons.dart';
import 'package:hatvest/shared/widgets/custom_textform_filed.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';

class TestLoin extends StatelessWidget {
  const TestLoin({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: Stack(
        children: [
          //
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
              ),
              child: Container(
                height: 550,
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'أهلًا بك في هارفست',
                            style: getBoldStyle(
                              color: blackColors,
                              fontSize: FontSize.s22,
                            ),
                          ),
                          Image.asset("assets/images/logo.png")
                        ],
                      ),
                      SizedBox(
                        height: screenHeight * 0.01,
                      ),
                      Divider(
                        color: blue,
                      ),
                      SizedBox(
                        height: screenHeight * 0.01,
                      ),
                      Text(
                        "سجل دخولك الآن!",
                        style: getBoldStyle(
                          color: blackColors,
                          fontSize: FontSize.s18,
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.01,
                      ),
                      CustomTextFormField(
                        hintText: "الموبايل",
                        // controller: _mobileController,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'برجاء ادخل رقم الموبايل';
                          }
                          return null;
                        },
                      ),
                      CustomTextFormField(
                        hintText: "كلمة المرور",
                        // controller: _mobileController,
                        isObscure: true,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'برجاء ادخل رقم الموبايل';
                          }
                          return null;
                        },
                      ),
                      CustomButtons(
                        onTap: () {},
                        text: "ds",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}



