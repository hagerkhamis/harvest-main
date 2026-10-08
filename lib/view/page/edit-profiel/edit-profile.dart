import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/theme/app_colors.dart';
import 'package:hatvest/services/image_picker_service.dart';
import 'package:hatvest/shared/widgets/custom_buttons.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/home-viewmodel.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File? _profileImage;
  final ImagePickerService _imagePickerService = ImagePickerService();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final profile = Provider.of<HomeViewModel>(context, listen: false).profile;
      if (profile != null) {
        _firstNameController.text = profile.fName ?? '';
        _lastNameController.text = profile.lName ?? '';
        _emailController.text = profile.email ?? '';
        _mobileController.text = profile.mobile1 ?? '';
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _updateProfileImage() async {
    File? image = await _imagePickerService.pickImage(context);
    if (image != null && mounted) {
      setState(() => _profileImage = image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.bgColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "تعديل البيانات",
          style: getBoldStyle(color: primaryColor, fontSize: FontSize.s20),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_forward, color: primaryColor, size: 28),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            // Profile image
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20)],
                    ),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey[100],
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage("assets/images/person.png") as ImageProvider,
                    ),
                  ),
                  GestureDetector(
                    onTap: _updateProfileImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Fields
            _buildField(
              controller: _firstNameController,
              label: "first_name".tr(),
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _lastNameController,
              label: "last_name".tr(),
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _emailController,
              label: "email".tr(),
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _mobileController,
              label: "mobile_1".tr(),
              icon: Icons.phone_android,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),

            CustomButtons(
              width: double.infinity,
              text: "حفظ التعديلات",
              onTap: () async {
                final vm = Provider.of<HomeViewModel>(context, listen: false);
                final profile = vm.profile;
                final success = await vm.updateProfile(
                  fName: _firstNameController.text.trim(),
                  lName: _lastNameController.text.trim(),
                  mName: profile?.mName ?? '',
                  email: _emailController.text.trim(),
                  mobile1: _mobileController.text.trim(),
                  mobile2: profile?.mobile2 ?? '',
                  gender: profile?.gender ?? '',
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? "تم حفظ التعديلات" : "حدث خطأ، حاول مرة أخرى",
                      style: getMediumStyle(color: Colors.white),
                    ),
                    backgroundColor: success ? primaryColor : Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
                if (success) Navigator.pop(context);
              },
              color: primaryColor,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textAlign: TextAlign.right,
        style: getMediumStyle(color: context.textPrimary, fontSize: FontSize.s15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: getRegularStyle(color: Colors.grey, fontSize: FontSize.s13),
          prefixIcon: Icon(icon, color: primaryColor, size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
