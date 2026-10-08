import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/theme/app_colors.dart';
import 'package:flutter_html/flutter_html.dart' show Html;
import 'package:hatvest/model/branch.dart';
import 'package:hatvest/model/country.dart';
import 'package:hatvest/model/signup_model.dart';
import 'package:hatvest/shared/widgets/custom%D9%80dropdown.dart';
import 'package:hatvest/shared/widgets/custom_buttons.dart';
import 'package:hatvest/shared/widgets/custom_textform_filed.dart';
import 'package:hatvest/shared/widgets/snackbar_helper.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/branches_viewmodel.dart';
import 'package:hatvest/view/page/onboarding-survey/onboarding_survey_page.dart';
import 'package:hatvest/viewmodel/auth_viewmodel.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart' show ProfileViewModel;
import 'package:provider/provider.dart';

class SingupPage extends StatefulWidget {
  const SingupPage({super.key});

  @override
  State<SingupPage> createState() => _SingupPageState();
}

class _SingupPageState extends State<SingupPage> {
  int _currentStep = 0; // 0 = step 1, 1 = step 2

  bool conditions = false;
  String? _genderValue;

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final branchesVM = Provider.of<BranchesViewModel>(context, listen: false);
      branchesVM.fetchBranches();
      branchesVM.fetchCountries();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _goToStep2() {
    if (!_formKey1.currentState!.validate()) return;
    final countriesViewModel = Provider.of<BranchesViewModel>(context, listen: false);
    if (countriesViewModel.selectedCountry == null) {
      showAwesomeSnackBar(
        title: "Error",
        message: 'Please select a country',
        type: SnackbarType.error,
      );
      return;
    }
    setState(() => _currentStep = 1);
  }

  void _submitForm() async {
    if (!_formKey2.currentState!.validate()) return;

    if (!conditions) {
      showAwesomeSnackBar(
        title: "Error",
        message: 'You must agree to the terms and conditions',
        type: SnackbarType.error,
      );
      return;
    }

    final branchesViewModel = Provider.of<BranchesViewModel>(context, listen: false);

    if (branchesViewModel.selectedBranch == null) {
      showAwesomeSnackBar(
        title: "Error",
        message: 'Please select a branch',
        type: SnackbarType.error,
      );
      return;
    }

    if (_genderValue == null) {
      showAwesomeSnackBar(
        title: "Error",
        message: 'Please select gender',
        type: SnackbarType.error,
      );
      return;
    }

    final signupData = SignupModel(
      fName: _firstNameController.text,
      lName: _lastNameController.text,
      email: _emailController.text,
      gender: _genderValue!,
      mobile1: _phoneController.text,
      branchId: branchesViewModel.selectedBranch!.id,
      password: _passwordController.text,
      country: branchesViewModel.selectedCountry!.id,
      track: "2",
    );

    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      await authViewModel.signUp(signupData);

      if (!mounted) return;
      showAwesomeSnackBar(
        title: "Success!",
        message: "Your data was saved successfully.",
        type: SnackbarType.success,
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingSurveyPage()),
      );
    } catch (e) {
      if (!mounted) return;
      showAwesomeSnackBar(
        title: "Error",
        message: e.toString(),
        type: SnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 60.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          if (_currentStep == 1) {
                            setState(() => _currentStep = 0);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        icon: Icon(Icons.arrow_forward_ios, color: context.textPrimary),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "welcome_harvest".tr(),
                          style: getBoldStyle(color: context.textPrimary, fontSize: FontSize.s24),
                        ),
                        const Spacer(),
                        Image.asset("assets/images/logo.png"),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Divider(color: dividerColor, thickness: 4.0),
                    SizedBox(height: screenHeight * 0.01),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        "create_new_account".tr(),
                        style: getBoldStyle(color: context.textPrimary, fontSize: FontSize.s22),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    // Step indicator
                    _buildStepIndicator(),
                    SizedBox(height: screenHeight * 0.02),
                    // Step content
                    _currentStep == 0 ? _buildStep1(context) : _buildStep2(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _stepDot(1, _currentStep >= 0),
        Expanded(child: Divider(color: _currentStep >= 1 ? primaryColor : Colors.grey.shade300, thickness: 2)),
        _stepDot(2, _currentStep >= 1),
      ],
    );
  }

  Widget _stepDot(int step, bool active) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? primaryColor : Colors.grey.shade300,
      ),
      child: Center(
        child: Text(
          '$step',
          style: TextStyle(color: active ? Colors.white : Colors.grey, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStep1(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final countriesViewModel = Provider.of<BranchesViewModel>(context);

    return Form(
      key: _formKey1,
      child: Column(
        children: [
          CustomTextFormField(
            controller: _firstNameController,
            hintText: "first_name".tr(),
            validator: (text) => (text == null || text.isEmpty) ? 'Please enter first name' : null,
          ),
          CustomTextFormField(
            controller: _lastNameController,
            hintText: "last_name".tr(),
            validator: (text) => (text == null || text.isEmpty) ? 'Please enter last name' : null,
          ),
          CustomTextFormField(
            controller: _emailController,
            hintText: "email".tr(),
            validator: (text) {
              if (text == null || text.isEmpty) return 'Please enter email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(text)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: screenHeight * 0.014),
          if (countriesViewModel.isLoading)
            const CircularProgressIndicator()
          else
            CustomDropdownButtonFormField<Country>(
              hintText: 'select_country'.tr(),
              items: countriesViewModel.countries,
              itemToString: (country) => country.name,
              onChanged: (country) => countriesViewModel.selectCountry(country),
              value: countriesViewModel.selectedCountry,
            ),
          CustomTextFormField(
            controller: _phoneController,
            hintText: "mobile_number".tr(),
            validator: (text) {
              if (text == null || text.isEmpty) return 'Please enter mobile number';
              if (!RegExp(r'^[0-9]+$').hasMatch(text)) return 'Please enter a valid number';
              return null;
            },
          ),
          SizedBox(height: screenHeight * 0.02),
          CustomButtons(
            text: "next".tr(),
            onTap: _goToStep2,
          ),
          SizedBox(height: screenHeight * 0.02),
          Divider(color: dividerColor, thickness: 4.0),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
              child: Text("already_have_account".tr(), style: getRegularStyle(color: blue, fontSize: FontSize.s16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final viewModel = Provider.of<BranchesViewModel>(context);

    return Form(
      key: _formKey2,
      child: Column(
        children: [
          CustomTextFormField(
            controller: _passwordController,
            hintText: "new_password".tr(),
            isObscure: true,
            validator: (text) {
              if (text == null || text.isEmpty) return 'Please enter password';
              if (text.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          CustomTextFormField(
            controller: _confirmPasswordController,
            hintText: "confirm_password".tr(),
            isObscure: true,
            validator: (text) {
              if (text == null || text.isEmpty) return 'Please confirm password';
              if (text != _passwordController.text) return 'Passwords do not match';
              return null;
            },
          ),
          SizedBox(height: screenHeight * 0.014),
          if (viewModel.isLoading)
            const CircularProgressIndicator()
          else
            CustomDropdownButtonFormField<Branch>(
              hintText: 'select_branch'.tr(),
              items: viewModel.branches,
              itemToString: (branch) => branch.name.isNotEmpty ? branch.name : 'Branch ${branch.id}',
              onChanged: (branch) => viewModel.selectBranch(branch),
              value: viewModel.selectedBranch,
            ),
          SizedBox(height: screenHeight * 0.014),
          CustomDropdownButtonFormField<String>(
            hintText: 'select_gender'.tr(),
            items: const ["male", "female"],
            itemToString: (value) => value == "male" ? "male_label".tr() : "female_label".tr(),
            value: _genderValue,
            onChanged: (value) => setState(() => _genderValue = value),
          ),
          SizedBox(height: screenHeight * 0.014),
          Consumer<ProfileViewModel>(
            builder: (context, profileVM, child) {
              return GestureDetector(
                onTap: () => setState(() => conditions = !conditions),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: conditions ? primaryColor.withOpacity(0.05) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: conditions ? primaryColor : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: conditions ? primaryColor : Colors.grey.shade400,
                            width: 2,
                          ),
                          color: conditions ? primaryColor : Colors.transparent,
                        ),
                        child: conditions ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
                            children: [
                              TextSpan(text: "terms_agree".tr()),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () async {
                                    final content = await profileVM.loadAppTermsById(1);
                                    if (!context.mounted) return;
                                    await showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => _TermsBottomSheet(title: 'user_agreement'.tr(), content: content),
                                    );
                                  },
                                  child: Text("user_agreement".tr(), style: const TextStyle(fontSize: 13, color: Colors.blue, decoration: TextDecoration.underline)),
                                ),
                              ),
                              TextSpan(text: "terms_and".tr()),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () async {
                                    final content = await profileVM.loadAppTermsById(2);
                                    if (!context.mounted) return;
                                    await showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => _TermsBottomSheet(title: 'privacy_policy'.tr(), content: content),
                                    );
                                  },
                                  child: Text("privacy_policy".tr(), style: const TextStyle(fontSize: 13, color: Colors.blue, decoration: TextDecoration.underline)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: screenHeight * 0.02),
          CustomButtons(text: "register_btn".tr(), onTap: _submitForm),
          SizedBox(height: screenHeight * 0.02),
          Divider(color: dividerColor, thickness: 4.0),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
              child: Text("already_have_account".tr(), style: getRegularStyle(color: blue, fontSize: FontSize.s16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsBottomSheet extends StatelessWidget {
  final String title;
  final String content;

  const _TermsBottomSheet({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(child: SingleChildScrollView(child: Html(data: content))),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
