import 'package:flutter/material.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';

class CustomButtons extends StatelessWidget {
  final double? width;
  final String? text;
  final Color? color;
  final double? borderRadius;
  final double? height;
  final Widget? svgBefore;
  final Widget? svgAfter;
  final Function()? onTap;
  final bool isLoading;
  final double? fontSize; // ✅ Added to allow customization

  const CustomButtons({
    super.key,
    this.width,
    this.text,
    this.onTap,
    this.color,
    this.borderRadius,
    this.svgBefore,
    this.svgAfter,
    this.height,
    this.fontSize,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Container(
          width: width ?? double.infinity,
          height: height ?? 55.0, // ✅ Reduced height for a more modern look
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? 15.0), // ✅ Softer corners
            color: color ?? primaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // ✅ Softer, transparent shadow
                blurRadius: 10.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (svgBefore != null) ...[
                        svgBefore!,
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '$text',
                        style: getBoldStyle(
                          color: whiteColor,
                          fontSize: fontSize ?? FontSize.s16, // ✅ Smaller default font size
                        ),
                      ),
                      if (svgAfter != null) ...[
                        const SizedBox(width: 8),
                        svgAfter!,
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
