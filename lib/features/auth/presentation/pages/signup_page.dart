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
import 'package:hatvest/viewmodel/app-viewmodel.dart' show ProfileViewModel;
import 'package:hatvest/viewmodel/auth_viewmodel.dart';
import 'package:hatvest/viewmodel/branches_viewmodel.dart';
import 'package:hatvest/view/page/onboarding-survey/onboarding_survey_page.dart';
import 'package:provider/provider.dart';

class SingupPage extends StatefulWidget {
  const SingupPage({super.key});

  @override
  State<SingupPage> createState() => _SingupPageState();
}

class _SingupPageState extends State<SingupPage> {
  int _currentStep = 0;
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
    final branchesVM = Provider.of<BranchesViewModel>(context, listen: false);
    if (branchesVM.selectedCountry == null) {
      showAwesomeSnackBar(title: "Error", message: 'Please select a country', type: SnackbarType.error);
      return;
    }
    setState(() => _currentStep = 1);
  }

  void _submitForm() async {
    if (!_formKey2.currentState!.validate()) return;
    if (!conditions) {
      showAwesomeSnackBar(title: "Warning", message: 'You must agree to the terms and conditions', type: SnackbarType.error);
      return;
    }
    final branchesVM = Provider.of<BranchesViewModel>(context, listen: false);
    if (branchesVM.selectedBranch == null || _genderValue == null) {
      showAwesomeSnackBar(title: "Error", message: 'Please complete all required selections', type: SnackbarType.error);
      return;
    }

    final signupData = SignupModel(
      fName: _firstNameController.text,
      lName: _lastNameController.text,
      email: _emailController.text,
      gender: _genderValue!,
      mobile1: _phoneController.text,
      branchId: branchesVM.selectedBranch!.id,
      password: _passwordController.text,
      country: branchesVM.selectedCountry!.id,
      track: "2",
    );

    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      await authViewModel.signUp(signupData);
      if (!mounted) return;
      showAwesomeSnackBar(title: "Success!", message: "Your account has been created successfully.", type: SnackbarType.success);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const OnboardingSurveyPage()));
    } catch (e) {
      if (!mounted) return;
      showAwesomeSnackBar(title: "Error", message: e.toString(), type: SnackbarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Center(
            child: Card(
              elevation: 10,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35.0)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_currentStep == 1) {
                              setState(() => _currentStep = 0);
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          icon: const Icon(Icons.arrow_back_ios, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Row(
                          children: [
                            Text("welcome_harvest".tr(), style: getBoldStyle(color: context.textPrimary, fontSize: FontSize.s18)),
                            const SizedBox(width: 10),
                            Image.asset("assets/images/logo.png", height: 35),
                          ],
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Divider(color: Colors.black12, thickness: 1),
                    ),
                    Text("create_new_account".tr(), style: getBoldStyle(color: context.textPrimary, fontSize: FontSize.s22)),
                    const SizedBox(height: 12),
                    // Step indicator
                    _buildStepIndicator(),
                    const SizedBox(height: 20),
                    // Step content
                    _currentStep == 0 ? _buildStep1() : _buildStep2(),
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
        _stepDot(1, true),
        Expanded(child: Divider(color: _currentStep >= 1 ? primaryColor : Colors.grey.shade300, thickness: 2)),
        _stepDot(2, _currentStep >= 1),
      ],
    );
  }

  Widget _stepDot(int step, bool active) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(shape: BoxShape.circle, color: active ? primaryColor : Colors.grey.shade300),
      child: Center(
        child: Text('$step', style: TextStyle(color: active ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStep1() {
    final countriesVM = Provider.of<BranchesViewModel>(context);
    return Form(
      key: _formKey1,
      child: Column(
        children: [
          _buildTextField(_firstNameController, "first_name".tr()),
          _buildTextField(_lastNameController, "last_name".tr()),
          _buildTextField(_emailController, "email".tr(), isEmail: true),
          const SizedBox(height: 12),
          if (countriesVM.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomDropdownButtonFormField<Country>(
                hintText: 'select_country'.tr(),
                items: countriesVM.countries,
                itemToString: (country) => country.name,
                onChanged: (country) => countriesVM.selectCountry(country),
                value: countriesVM.selectedCountry,
              ),
            ),
          _buildTextField(_phoneController, "mobile_number".tr(), isPhone: true),
          const SizedBox(height: 20),
          CustomButtons(text: "next".tr(), onTap: _goToStep2),
          const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider(color: Colors.black12, thickness: 1)),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
              child: Text("already_have_account".tr(), style: getBoldStyle(color: primaryColor, fontSize: FontSize.s14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    final viewModel = Provider.of<BranchesViewModel>(context);
    return Form(
      key: _formKey2,
      child: Column(
        children: [
          _buildTextField(_passwordController, "new_password".tr(), isPassword: true),
          _buildTextField(_confirmPasswordController, "confirm_password".tr(), isPassword: true, isConfirm: true),
          const SizedBox(height: 12),
          if (!viewModel.isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomDropdownButtonFormField<Branch>(
                hintText: 'select_branch'.tr(),
                items: viewModel.branches,
                itemToString: (branch) => branch.name.isNotEmpty ? branch.name : 'Branch ${branch.id}',
                onChanged: (branch) => viewModel.selectBranch(branch),
                value: viewModel.selectedBranch,
              ),
            ),
          const SizedBox(height: 12),
          _buildGenderDropdown(),
          const SizedBox(height: 20),
          _buildTermsSection(),
          const SizedBox(height: 25),
          CustomButtons(text: "create_account".tr(), onTap: _submitForm),
          const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider(color: Colors.black12, thickness: 1)),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
              child: Text("already_have_account".tr(), style: getBoldStyle(color: primaryColor, fontSize: FontSize.s14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool isEmail = false, bool isPhone = false, bool isPassword = false, bool isConfirm = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomTextFormField(
        controller: controller,
        hintText: hint,
        isObscure: isPassword,
        validator: (text) {
          if (text == null || text.isEmpty) return 'Please enter $hint';
          if (isEmail && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(text)) return 'Please enter a valid email';
          if (isPhone && !RegExp(r'^[0-9]+$').hasMatch(text)) return 'Please enter a valid number';
          if (isPassword && !isConfirm && text.length < 6) return 'Password must be at least 6 characters';
          if (isConfirm && text != _passwordController.text) return 'Passwords do not match';
          return null;
        },
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return CustomDropdownButtonFormField<String>(
      hintText: 'select_gender'.tr(),
      items: const ["male", "female"],
      itemToString: (value) => value == "male" ? "male_label".tr() : "female_label".tr(),
      value: _genderValue,
      onChanged: (value) => setState(() => _genderValue = value),
    );
  }

  Future<void> _showAppTermsDialog(BuildContext context, ProfileViewModel profileVM, String title) async {
    final content = await profileVM.loadAppTermsById(4);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(child: content.isNotEmpty ? Html(data: content) : const Center(child: Text('No content available'))),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildTermsSection() {
    return Consumer<ProfileViewModel>(
      builder: (context, profileVM, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Wrap(
                  children: [
                    Text("terms_agree".tr(), style: getMediumStyle(color: Colors.black87, fontSize: FontSize.s12)),
                    GestureDetector(
                      onTap: () => _showAppTermsDialog(context, profileVM, 'user_agreement'.tr()),
                      child: Text("user_agreement".tr(), style: getMediumStyle(color: Colors.blue, fontSize: FontSize.s12).copyWith(decoration: TextDecoration.underline)),
                    ),
                    Text("terms_and".tr(), style: getMediumStyle(color: Colors.black87, fontSize: FontSize.s12)),
                    GestureDetector(
                      onTap: () => _showAppTermsDialog(context, profileVM, 'privacy_policy'.tr()),
                      child: Text("privacy_policy".tr(), style: getMediumStyle(color: Colors.blue, fontSize: FontSize.s12).copyWith(decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ),
              Radio<bool>(
                value: true,
                groupValue: conditions ? true : null,
                activeColor: Colors.blue,
                onChanged: (v) {
                  setState(() => conditions = true);
                  profileVM.approve();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
