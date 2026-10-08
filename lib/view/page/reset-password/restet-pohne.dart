import 'package:flutter/material.dart';
import 'package:hatvest/proveider/locale_provider.dart';
import 'package:hatvest/shared/widgets/custom_buttons.dart';
import 'package:hatvest/shared/widgets/custom_textform_filed.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class ResetPassPhone extends StatefulWidget {
  const ResetPassPhone({super.key});

  @override
  State<ResetPassPhone> createState() => _ResetPassPhoneState();
}

class _ResetPassPhoneState extends State<ResetPassPhone> {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final localeProvider = Provider.of<LocaleProvider>(context);

    final TextEditingController _phoneController = TextEditingController();

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
                  height: 600,
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
                                  "دعنا نساعدك",
                                  style: getRegularStyle(
                                      color: grey, fontSize: FontSize.s22),
                                ),
                                Text(
                                  "أدخل رقم هاتفك المحمول المسجل",
                                  style: getRegularStyle(
                                      color: grey, fontSize: FontSize.s22),
                                ),
                                SizedBox(
                                  height: screenHeight * 0.02,
                                ),
                                Center(
                                  child: CustomTextFormField(
                                    controller: _phoneController,
                                    hintText: "الموبايل",
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        return 'برجاء ادخل الموبايل';
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
                                                authVM.sendOtp(
                                                  context,
                                                  _phoneController.text.trim(),
                                                );
                                              }
                                            },
                                          );
                                  },
                                ),

                                // CustomButtons(
                                //   text: "إرسال الرمز",
                                //   onTap: () {
                                //     if (_formKey.currentState!.validate()) {
                                //       Provider.of<AuthViewModel>(context,
                                //               listen: false)
                                //           .sendOtp(context,
                                //               _phoneController.text.trim());
                                //     }
                                //   },
                                // ),
                                CustomButtons(
                                  text: "جرب طريقة أخرى",
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushReplacementNamed('/resetEmail');
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
                        //resetEmail
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
