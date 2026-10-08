import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/theme/app_colors.dart';
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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart' as g_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  bool isLoading = false;
  bool isEmailLogin = false;
  bool _googleSignInInitialized = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<String?> _askForPhoneNumber() async {
    final phoneController = TextEditingController();
    String? errorText;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Enter Phone Number'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Mobile Number',
                      errorText: errorText,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final phone = phoneController.text.trim();
                    if (phone.isEmpty) {
                      setState(() {
                        errorText = 'Please enter your mobile number';
                      });
                      return;
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
                      setState(() {
                        errorText = 'Please enter a valid number';
                      });
                      return;
                    }
                    Navigator.of(dialogContext).pop(phone);
                  },
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 10.0,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Container(
                          // Removed fixed height to let it wrap content
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "welcome_harvest".tr(),
                                        style: getBoldStyle(
                                            color: context.textPrimary,
                                            fontSize: FontSize.s20),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Image.asset(
                                      "assets/images/logo.png",
                                      height: 40,
                                    )
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Divider(color: dividerColor, thickness: 1.0),
                                const SizedBox(height: 15),
                                Text(
                                  "login_now".tr(),
                                  style: getBoldStyle(
                                      color: context.textPrimary,
                                      fontSize: FontSize.s18),
                                ),
                                const SizedBox(height: 15),
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      isEmailLogin
                                          ? CustomTextFormField(
                                              hintText: "Email",
                                              controller: _emailController,
                                              validator: (text) {
                                                if (text == null ||
                                                    text.isEmpty) {
                                                  return 'Please enter your email';
                                                }
                                                if (!RegExp(
                                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                                    .hasMatch(text)) {
                                                  return 'Please enter a valid email';
                                                }
                                                return null;
                                              },
                                            )
                                          : CustomTextFormField(
                                              hintText: "mobile_number".tr(),
                                              controller: _mobileController,
                                              validator: (text) {
                                                if (text == null ||
                                                    text.isEmpty) {
                                                  return 'Please enter your mobile number';
                                                }
                                                return null;
                                              },
                                            ),
                                      const SizedBox(height: 10),
                                      CustomTextFormField(
                                        hintText: "new_password".tr(),
                                        controller: _passwordController,
                                        isObscure: true,
                                        validator: (text) {
                                          if (text == null || text.isEmpty) {
                                            return 'Please enter your password';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                CustomButtons(
                                  text: "login_btn".tr(),
                                  onTap: () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      try {
                                        final viewModel =
                                            Provider.of<AuthViewModel>(context,
                                                listen: false);
                                        final result = await viewModel.signIn(
                                          isEmailLogin
                                              ? _emailController.text.trim()
                                              : _mobileController.text.trim(),
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
                                                builder: (context) =>
                                                    BottomNav()),
                                          );
                                        }
                                      } catch (e) {
                                        if (e == "un_auth_error") {
                                          showAwesomeSnackBar(
                                            title: "Error!",
                                            message:
                                                "Wrong mobile number or password",
                                            type: SnackbarType.error,
                                          );
                                        } else {
                                          showAwesomeSnackBar(
                                            title: "Error!",
                                            message: e.toString(),
                                            type: SnackbarType.error,
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
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        setState(() {
                                          isLoading = true;
                                        });

                                        try {
                                          if (!_googleSignInInitialized) {
                                            await g_auth.GoogleSignIn.instance
                                                .initialize();
                                            _googleSignInInitialized = true;
                                          }

                                          final g_auth.GoogleSignInAccount
                                              googleUser = await g_auth
                                                  .GoogleSignIn.instance
                                                  .authenticate();

                                          final googleAuth =
                                              googleUser.authentication;
                                          final idToken = googleAuth.idToken;

                                          if (idToken == null ||
                                              idToken.isEmpty) {
                                            throw Exception(
                                                'No Google ID token');
                                          }

                                          final phone =
                                              await _askForPhoneNumber();
                                          if (phone == null) return;

                                          final viewModel =
                                              Provider.of<AuthViewModel>(
                                                  context,
                                                  listen: false);
                                          final result =
                                              await viewModel.signInWithGoogle(
                                            email: googleUser.email,
                                            name: googleUser.displayName ??
                                                googleUser.email,
                                            phone: phone,
                                            idToken: idToken,
                                          );

                                          if (result != null) {
                                            if (!mounted) return;
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const BottomNav()),
                                            );
                                          }
                                        } catch (error, stackTrace) {
                                          debugPrint(
                                              'Google sign in error: $error');
                                          debugPrint(stackTrace.toString());
                                          if (!mounted) return;
                                          showAwesomeSnackBar(
                                            title: "Error!",
                                            message: error.toString(),
                                            type: SnackbarType.error,
                                          );
                                        } finally {
                                          setState(() {
                                            isLoading = false;
                                          });
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(50),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                        ),
                                        child: const FaIcon(
                                            FontAwesomeIcons.google,
                                            color: Colors.red,
                                            size: 24),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    InkWell(
                                      onTap: () async {
                                        try {
                                          final credential = await SignInWithApple
                                              .getAppleIDCredential(
                                            scopes: [
                                              AppleIDAuthorizationScopes.email,
                                              AppleIDAuthorizationScopes.fullName,
                                            ],
                                          );
                                          
                                          final identityToken = credential.identityToken;
                                          if (identityToken == null || identityToken.isEmpty) {
                                            throw Exception("No Apple Identity Token");
                                          }

                                          final viewModel = Provider.of<AuthViewModel>(context, listen: false);
                                          final result = await viewModel.signInWithApple(
                                            identityToken: identityToken,
                                            fName: credential.givenName,
                                            lName: credential.familyName,
                                          );

                                          if (result != null) {
                                            if (!mounted) return;
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const BottomNav()),
                                            );
                                          }
                                        } catch (error) {
                                          if (!mounted) return;
                                          showAwesomeSnackBar(
                                            title: "Error!",
                                            message: error.toString(),
                                            type: SnackbarType.error,
                                          );
                                        } finally {
                                          setState(() {
                                            isLoading = false;
                                          });
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(50),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                        ),
                                        child: const FaIcon(
                                            FontAwesomeIcons.apple,
                                            color: Colors.black,
                                            size: 24),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          isEmailLogin = !isEmailLogin;
                                          _formKey.currentState?.reset();
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(50),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: isEmailLogin
                                                  ? Colors.blue
                                                  : Colors.grey.shade300,
                                              width: isEmailLogin ? 2 : 1),
                                        ),
                                        child: const FaIcon(
                                            FontAwesomeIcons.envelope,
                                            color: Colors.blue,
                                            size: 24),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Divider(color: dividerColor, thickness: 1.0),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SingupPage()));
                                      },
                                      child: Text(
                                        "register_new_account".tr(),
                                        style: getRegularStyle(
                                            color: blue, fontSize: FontSize.s14),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context)
                                            .pushReplacementNamed('/resetPhone');
                                      },
                                      child: Text(
                                        "forgot_password".tr(),
                                        style: getRegularStyle(
                                            color: blue, fontSize: FontSize.s14),
                                      ),
                                    ),
                                  ],
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
          if (isLoading) ...[
            Container(
              color: Colors.black.withAlpha(128),
              child: Center(
                child: LoadingIndicator(
                  color: primaryColor,
                ),
              ),
            ),
          ],
          SafeArea(
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                  onPressed: () async {
                    // Unauthenticated users must return to the pre-login welcome
                    // screen — never leave BottomNav (home) under the login page.
                    final prefs = await SharedPreferences.getInstance();
                    final token = prefs.getString('auth_token');
                    final isLoggedIn =
                        token != null && token.trim().isNotEmpty;

                    if (!context.mounted) return;

                    if (!isLoggedIn) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/welcome',
                        (route) => false,
                      );
                      return;
                    }

                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context)
                          .pushReplacementNamed('/welcome');
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
