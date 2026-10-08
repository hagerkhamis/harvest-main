import 'package:flutter/material.dart';
import 'package:hatvest/shared/widgets/custom_buttons_row.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class StartDeplom extends StatefulWidget {
  const StartDeplom({super.key});

  @override
  State<StartDeplom> createState() => _StartDeplomState();
}

class _StartDeplomState extends State<StartDeplom> {
  double progress = 0.0;

  void _increaseProgress() {
    setState(() {
      progress += 0.1;
      if (progress > 1.0) progress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "دبلومة توفل",
          style: getBoldStyle(color: blackColors, fontSize: FontSize.s20),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: SizedBox.expand(
        child: Stack(
          children: [
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Other widgets here
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  Column(
                    children: [
                      Image.asset("assets/images/deplom-info.png"),
                      Container(
                        width: 322,
                        decoration: BoxDecoration(
                            color: whiteColor,
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(15),
                                bottomLeft: Radius.circular(15))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Center(
                                child: CircularPercentIndicator(
                                  radius: 25.0, // Smaller radius
                                  lineWidth: 6.0, // Thinner stroke
                                  animation: true,
                                  percent: progress,
                                  center: Text(
                                    "${(progress * 100).toInt()}%",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0, // Smaller text
                                    ),
                                  ),
                                  progressColor: primaryColor,
                                  backgroundColor: Colors.grey[300]!,
                                ),
                              ),
                              Text(
                                "Lesson 1",
                                style: getRegularStyle(
                                    color: blackColors, fontSize: FontSize.s18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  CustomButtonsRow(
                    width: 350,
                    height: 60,
                    text: "الذهاب للرئسية",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
