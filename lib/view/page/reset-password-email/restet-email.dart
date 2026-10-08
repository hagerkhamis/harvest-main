import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hatvest/proveider/locale_provider.dart';
import 'package:hatvest/shared/widgets/custom_buttons.dart';
import 'package:hatvest/shared/widgets/custom_textform_filed.dart';
import 'package:hatvest/core/theme/app_theme.dart';
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
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Container(
                  height: 550,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(25.0)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "أهلًا بك في هارفست",
                              style: getBoldStyle(
                                  color: blackColors, fontSize: FontSize.s24),
                            ),
                            // SvgPicture.asset("assets/icons/logo-icon.svg"),
                            SizedBox(
                              width: screenWidth * 0.08,
                            ),
                            Image.asset("assets/images/logo.png")
                          ],
                        ),
                        SizedBox(
                          height: screenHeight * 0.01,
                        ),
                        Divider(
                          color: dividerColor,
                          thickness: 4.0,
                        ),
                        SizedBox(
                          height: screenHeight * 0.01,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "هل نسيت كلمة السر",
                                  style: getBoldStyle(
                                      color: blackColors,
                                      fontSize: FontSize.s22),
                                ),
                                SizedBox(
                                  height: screenHeight * 0.02,
                                ),
                                Text(
                                  "اعد ضبط كلمه السر",
                                  style: getRegularStyle(
                                      color: grey, fontSize: FontSize.s22),
                                ),
                                Text(
                                  "أدخل البريد الإلكتروني لإعادة تعيين كلمة المرور",
                                  style: getRegularStyle(
                                      color: grey, fontSize: FontSize.s22),
                                ),
                                SizedBox(
                                  height: screenHeight * 0.02,
                                ),
                                Center(
                                  child: CustomTextFormField(
                                    controller: _emailController,
                                    hintText: "البريد الالكترونى",
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        return 'برجاء ادخل الالكترونى';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: screenHeight * 0.02,
                                ),
                                Consumer<AuthViewModel>(
                                  builder: (context, authVM, _) {
                                    return authVM.isLoading
                                        ? Center(
                                            child: CircularProgressIndicator())
                                        : CustomButtons(
                                            text: "إرسال الرمز",
                                            onTap: () {
                                              if (_formKey.currentState!
                                                  .validate()) {
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
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),
                        Divider(
                          color: dividerColor,
                          thickness: 4.0,
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .pushReplacementNamed('/login');
                                },
                                child: Text(
                                  "تسجيل الدخول",
                                  style: getRegularStyle(
                                      color: blue, fontSize: FontSize.s16),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .pushReplacementNamed('/singUp');
                                },
                                child: Text(
                                  "سجل حساب جديد",
                                  style: getRegularStyle(
                                      color: blue, fontSize: FontSize.s16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
