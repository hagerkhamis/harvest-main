import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/theme/app_colors.dart';
import 'package:hatvest/proveider/locale_provider.dart';
import 'package:hatvest/shared/widgets/custom_buttons.dart';
import 'package:hatvest/shared/widgets/custom_textform_filed.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class ResetPassEmail extends StatefulWidget {
  const ResetPassEmail({super.key});

  @override
  State<ResetPassEmail> createState() => _ResetPassEmailState();
}

class _ResetPassEmailState extends State<ResetPassEmail> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background remains as requested
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Card(
                        elevation: 10,
                        shadowColor: Colors.black.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35.0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // Compact design
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              /// 🔹 Logo & Welcome Section
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset("assets/images/logo.png", height: 45),
                                  const SizedBox(width: 12),
                                  Text(
                                    "welcome_harvest".tr(),
                                    style: getBoldStyle(color: context.textPrimary, fontSize: FontSize.s20),
                                  ),
                                ],
                              ),
        
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Divider(color: Colors.black12, thickness: 1),
                              ),
        
                              /// 🔹 Title & Instructions
                              Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "forgot_password".tr(),
                                      style: getBoldStyle(color: context.textPrimary, fontSize: FontSize.s20),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "reset_email_help".tr(),
                                      style: getMediumStyle(color: context.textSecondary, fontSize: FontSize.s16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "reset_email_instructions".tr(),
                                      style: getRegularStyle(color: context.textSecondary, fontSize: FontSize.s14),
                                    ),
        
                                    const SizedBox(height: 25),
        
                                    /// 🔹 Input Field
                                    CustomTextFormField(
                                      controller: _emailController,
                                      hintText: "email".tr(),
                                      validator: (text) {
                                        if (text == null || text.isEmpty) {
                                          return 'برجاء إدخال البريد الإلكتروني';
                                        }
                                        if (!RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$").hasMatch(text)) {
                                          return 'برجاء إدخال بريد إلكتروني صحيح';
                                        }
                                        return null;
                                      },
                                    ),
        
                                    const SizedBox(height: 25),
        
                                    /// 🔹 Actions
                                    Consumer<AuthViewModel>(
                                      builder: (context, authVM, _) {
                                        return authVM.isLoading
                                            ? const Center(child: CircularProgressIndicator())
                                            : CustomButtons(
                                                text: "send_link".tr(),
                                                onTap: () {
                                                  if (_formKey.currentState!.validate()) {
                                                    authVM.sendEmailOtp(
                                                      context,
                                                      _emailController.text.trim(),
                                                    );
                                                  }
                                                },
                                              );
                                      },
                                    ),
                                  ],
                                ),
                              ),
        
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Divider(color: Colors.black12, thickness: 1),
                              ),
        
                              /// 🔹 Navigation Links
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildLink(context, "login_btn".tr(),
                                    () => Navigator.of(context).pushReplacementNamed('/login')
                                  ),
                                  _buildLink(context, "register_new_account".tr(),
                                    () => Navigator.of(context).pushReplacementNamed('/singUp')
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLink(BuildContext context, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: getBoldStyle(color: primaryColor, fontSize: FontSize.s14),
      ),
    );
  }
}
