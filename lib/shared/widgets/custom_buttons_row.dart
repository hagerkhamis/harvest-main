import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';

class CustomButtonsRow extends StatelessWidget {
  final double? width;
  final String? text;
  final Color? color;
  final double? borderRadius;
  final double? height;

  final Function()? onTap;
  const CustomButtonsRow(
      {super.key,
      this.width,
      this.text,
      this.onTap,
      this.color,
      this.borderRadius,
      this.height});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width ?? double.infinity,
          height: height ?? 65.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? 15.0),
            color: color ?? darkGreen,
          ),
          child: Center(
            child: Row(
              children: [
                Text(
                  '$text',
                  style: getBoldStyle(color: whiteColor, fontSize: FontSize.s20),
                ),
                SvgPicture.asset("assets/icons/back-hand.svg")
              ],
            ),
          ),
        ),
      ),
    );
  }
}
