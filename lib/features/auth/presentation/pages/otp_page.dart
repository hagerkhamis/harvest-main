import 'package:flutter/material.dart';
import 'package:hatvest/shared/widgets/custom_buttons.dart';
import 'package:hatvest/shared/widgets/custom_textform_filed.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class OtpPge extends StatefulWidget {
  final String mobile;
  const OtpPge({
    super.key,
    required this.mobile,
  });

  @override
  State<OtpPge> createState() => _OtpPgeState();
}

class _OtpPgeState extends State<OtpPge> {
  String? _mobile;

  @override
  void initState() {
    super.initState();
    // If mobile was passed directly, use it
    _mobile = widget.mobile;
  }

  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    _mobile ??= ModalRoute.of(context)!.settings.arguments as String?;

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
                          // Removed fixed height to allow dynamic content
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
                                      "Welcome to Harvest",
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
                                          "Enter the Code",
                                          style: getBoldStyle(
                                              color: blackColors,
                                              fontSize: FontSize.s22),
                                        ),
                                        SizedBox(
                                          height: screenHeight * 0.02,
                                        ),
                                        Center(
                                          child: CustomTextFormField(
                                            controller: otpController,
                                            hintText: "Code",
                                            validator: (text) {
                                              if (text == null || text.isEmpty) {
                                                return 'Please enter the code';
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
                                                    text: "Send Code",
                                                    onTap: () {
                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        authVM.verifyCode(
                                                            context,
                                                            widget.mobile,
                                                            otpController.text.trim());
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
                                          "Log in",
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
