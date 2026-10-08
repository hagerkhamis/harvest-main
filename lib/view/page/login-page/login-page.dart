import 'package:flutter/material.dart';
import 'package:hatvest/proveider/locale_provider.dart';
import 'package:hatvest/shared/widgets/custom_buttons.dart';
import 'package:hatvest/shared/widgets/custom_textform_filed.dart';
import 'package:hatvest/shared/widgets/loading_indicator.dart';
import 'package:hatvest/shared/widgets/snackbar_helper.dart';
import 'package:hatvest/view/page/bottom-nav/bottom-nav.dart';
import 'package:hatvest/view/page/singup-page/singup-page.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoading = false; // <<< Add loading state

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                child: Container(
                  height: 550,
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
                            SizedBox(width: screenWidth * 0.08),
                            Image.asset("assets/images/logo.png")
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Divider(color: dividerColor, thickness: 4.0),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          "سجل دخولك الآن!",
                          style: getBoldStyle(
                              color: blackColors, fontSize: FontSize.s22),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Form(
                          key: _formKey,
                          child: Center(
                            child: Column(
                              children: [
                                CustomTextFormField(
                                  hintText: "الموبايل",
                                  controller: _mobileController,
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return 'برجاء ادخل رقم الموبايل';
                                    }
                                    return null;
                                  },
                                ),
                                CustomTextFormField(
                                  hintText: "كلمة المرور",
                                  controller: _passwordController,
                                  isObscure: true,
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return 'برجاء ادخل كلمة المرور';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        CustomButtons(
                          text: "تسجيل الدخول",
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              try {
                                final viewModel = Provider.of<AuthViewModel>(
                                    context,
                                    listen: false);
                                final result = await viewModel.signIn(
                                  _mobileController.text.trim(),
                                  _passwordController.text,
                                );

                                if (result != null) {
                                  if (!mounted) return;

                                  showAwesomeSnackBar(
                                    title: "Success!",
                                    message:
                                        "Your data was saved successfully.",
                                    type: SnackbarType.success,
                                  );

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BottomNav()),
                                  );
                                  // showAwesomeSnackBar(
                                  //   // context: context,
                                  //   title: "Success!",
                                  //   message:
                                  //       "Your data was saved successfully.",
                                  //   type: SnackbarType.success,
                                  // );
                                  // Navigator.of(context)
                                  //     .pushReplacementNamed('/bottomNav');
                                }
                              } catch (e) {
                                if (e == "un_auth_error") {
                                  showAwesomeSnackBar(
                                    // context: context,
                                    title: "Success!",
                                    message:
                                        "رقم الهاتف أو كلمة المرور غير صحيحة",
                                    type: SnackbarType.success,
                                  );
                                } else {
                                  showAwesomeSnackBar(
                                    // context: context,
                                    title: "Success!",
                                    message:
                                        "رقم الهاتف أو كلمة المرور غير صحيحة",
                                    type: SnackbarType.success,
                                  );
                                }
                              } finally {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            }
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Divider(color: dividerColor, thickness: 4.0),
                        SizedBox(height: screenHeight * 0.01),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SingupPage()));
                                  // Navigator.of(context).pushNamed('/singUp');

                                  // Navigator.of(context)
                                  //     .pushReplacementNamed('/singUp');
                                },
                                child: Text(
                                  "سجل حساب جديد",
                                  style: getRegularStyle(
                                      color: blue, fontSize: FontSize.s16),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .pushReplacementNamed('/resetPhone');
                                },
                                child: Text(
                                  "نسيت كلمة السر؟",
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
          if (isLoading) ...[
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: LoadingIndicator(
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
