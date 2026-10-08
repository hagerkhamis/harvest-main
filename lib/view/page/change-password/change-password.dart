import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/enums/request_status.dart';
import 'package:hatvest/shared/widgets/custom_buttons.dart';
import 'package:hatvest/shared/widgets/custom_textform_filed.dart';
import 'package:hatvest/shared/widgets/snackbar_helper.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/auth_viewmodel.dart' show AuthViewModel;
import 'package:provider/provider.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(AuthViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      final success = await viewModel.changePassword(
        mobile: _currentPasswordController.text.trim(),
        password: _newPasswordController.text.trim(),
        passwordConfirmation: _confirmPasswordController.text.trim(),
      );

      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/images/success_image.png",
                    width: 100, height: 100),
                const SizedBox(height: 10),
                Text("password_reset_success".tr(),
                    style: getBoldStyle(
                        color: blackColors, fontSize: FontSize.s18),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        );

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed('/profilePage');
          }
        });
      } else {
        showAwesomeSnackBar(
          title: "Error",
          message: (viewModel.errorMessage ?? "generic_error".tr()),
          type: SnackbarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: Consumer<AuthViewModel>(
        builder: (context, viewModel, _) {
          final screenHeight = MediaQuery.sizeOf(context).height;

          return Stack(
            children: [

              // Foreground content
              Scaffold(
                backgroundColor:
                    Colors.transparent, // So background image shows
                appBar: AppBar(
                  backgroundColor: whiteColor,
                  elevation: 0,
                  title: Text(
                    "edit_password".tr(),
                    style: getBoldStyle(
                      color: primaryColor,
                      fontSize: FontSize.s20,
                    ),
                  ),
                  centerTitle: false,
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_forward,
                          color: blackColors, size: 35),
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.04),
                        CustomTextFormField(
                          controller: _currentPasswordController,
                          fillColor: whiteColor,
                          hintText: "mobile_number".tr(),
                          isObscure: true,
                          // validator: (text) =>
                          //     text!.isEmpty ? "mobile_required".tr() : null,
                          validator: (text) => text == null || text.isEmpty
                              ? "mobile_required".tr()
                              : null,
                        ),
                        CustomTextFormField(
                          controller: _newPasswordController,
                          fillColor: whiteColor,
                          hintText: "new_password".tr(),
                          isObscure: true,
                          validator: (text) =>
                              text!.isEmpty ? "password_required".tr() : null,
                        ),
                        CustomTextFormField(
                          controller: _confirmPasswordController,
                          fillColor: whiteColor,
                          hintText: "confirm_new_password".tr(),
                          isObscure: true,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return "confirm_password_required".tr();
                            } else if (text != _newPasswordController.text) {
                              return "password_not_match".tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        viewModel.submitStatus == RequestStatus.loading
                            ? const CircularProgressIndicator()
                            : CustomButtons(
                                width: 320,
                                text: "confirm".tr(),
                                onTap: () => _handleSubmit(viewModel),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
