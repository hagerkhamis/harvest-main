import 'package:flutter/material.dart';
import 'package:hatvest/core/theme/app_colors.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final Color? iconColor;
  final Color? fillColor;
  final String? value;
  final String? hintText;
  final double? width;
  final double? height;
  final IconData? icon;
  final IconButton? suffixIcon;
  final List<Widget>? prefixRowIcons;
  final String? Function(String?)? validator;
  final void Function(String?)? onChange;
  final void Function(String?)? onSubmit;
  final bool isObscure;
  final EdgeInsets padding;
  final TextInputType inputType;
  final int? maxLines;
  final Color? enabledBorderColor;
  final bool enabled;

  const CustomTextFormField({
    super.key,
    this.icon,
    this.iconColor,
    this.fillColor,
    this.controller,
    this.value,
    this.validator,
    this.onChange,
    this.onSubmit,
    this.enabledBorderColor,
    this.isObscure = false,
    this.enabled = true,
    this.inputType = TextInputType.text,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0), // Reduced vertical padding
    this.maxLines = 1,
    this.hintText,
    this.suffixIcon,
    this.prefixRowIcons,
    this.width,
    this.height,
  });

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isObscure;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      constraints: BoxConstraints(
        minHeight: widget.height ?? 50, // Reduced from 60
      ),
      padding: widget.padding,
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.inputType,
        maxLines: widget.maxLines,
        obscureText: _obscureText,
        style: getMediumStyle(color: context.textPrimary, fontSize: FontSize.s14),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: getRegularStyle(
            color: grey.withOpacity(0.6),
            fontSize: FontSize.s14,
          ),
          filled: true,
          fillColor: widget.fillColor ?? Colors.white.withOpacity(0.05),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12, // Reduced from 20
            horizontal: 16,
          ),
          errorStyle: getRegularStyle(color: Colors.red, fontSize: FontSize.s12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: widget.enabledBorderColor ?? Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: primaryColor, width: 1.5), // Use theme primary color
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          suffixIcon: widget.isObscure
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                )
              : widget.suffixIcon,
        ),
        validator: widget.validator,
        onChanged: widget.onChange,
        onFieldSubmitted: widget.onSubmit,
      ),
    );
  }
}
