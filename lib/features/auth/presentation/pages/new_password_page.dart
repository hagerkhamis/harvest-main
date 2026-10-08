import 'package:flutter/material.dart';
import 'package:hatvest/shared/widgets/custom_buttons.dart';
import 'package:hatvest/shared/widgets/custom_textform_filed.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class NewPasswordPage extends StatefulWidget {
  final String mobile;
  const NewPasswordPage({
    super.key,
    required this.mobile,
  });

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: Container(
                          // Removed fixed height
                          decoration:
                              BoxDecoration(borderRadius: BorderRadius.circular(25.0)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 10.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
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
                                          "تعين كلمة مرور جديدة ",
                                          style: getBoldStyle(
                                              color: blackColors,
                                              fontSize: FontSize.s22),
                                        ),
                                        SizedBox(
                                          height: screenHeight * 0.02,
                                        ),
                                        CustomTextFormField(
                                          controller: _passwordController,
                                          hintText: "كلمة المرور",
                                          isObscure: true,
                                          validator: (text) {
                                            if (text == null || text.isEmpty) {
                                              return 'برجاء ادخل كلمة المرور';
                                            }
                                            if (text.length < 6) {
                                              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                            }
                                            return null;
                                          },
                                        ),
                                        CustomTextFormField(
                                          controller: _confirmPasswordController,
                                          hintText: "تاكيد كلمة المرور",
                                          isObscure: true,
                                          validator: (text) {
                                            if (text == null || text.isEmpty) {
                                              return 'برجاء تاكيد كلمة المرور';
                                            }
                                            if (text != _passwordController.text) {
                                              return 'كلمة المرور غير متطابقة';
                                            }
                                            return null;
                                          },
                                        ),
                                        CustomTextFormField(
                                          controller: _codeController,
                                          hintText: "الكود",
                                          inputType: TextInputType.number,
                                          validator: (text) {
                                            if (text == null || text.isEmpty) {
                                              return 'برجاء ادخل الكود';
                                            }
                                            return null;
                                          },
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
                                                        authVM.resetPassword(
                                                          context,
                                                          widget.mobile,
                                                          _passwordController.text,
                                                          _confirmPasswordController.text,
                                                          _codeController.text,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
