import 'dart:io';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/services/image_picker_service.dart';
import 'package:hatvest/shared/widgets/custom_buttons.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/home-viewmodel.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  final ImagePickerService _imagePickerService = ImagePickerService();

  Future<void> _updateProfileImage() async {
    File? image = await _imagePickerService.pickImage(context);
    if (image != null) {
      if (!mounted) return;
      setState(() {
        _profileImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "profile".tr(),
          style: getBoldStyle(color: primaryColor, fontSize: FontSize.s20),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/bottomNav'),
            icon: Icon(Icons.arrow_forward, color: primaryColor, size: 28),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
              child: Container(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Profile Image Header
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
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
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Single Content List with Dividers
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoItem(Icons.person_outline, "name".tr(), viewModel.profile?.name ?? 'N/A'),
                        _buildDivider(),
                        _buildInfoItem(Icons.transgender, "gender".tr(), viewModel.profile?.gender ?? 'N/A'),
                        _buildDivider(),
                        _buildInfoItem(Icons.phone_android, "mobile_1".tr(), viewModel.profile?.mobile1 ?? 'N/A'),
                        _buildDivider(),
                        _buildInfoItem(Icons.mail_outline, "email".tr(), viewModel.profile?.email ?? 'N/A'),
                        _buildDivider(),
                        _buildInfoItem(Icons.public, "country".tr(), viewModel.profile?.country.name ?? 'N/A', isLast: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pushNamed('/changePassword'),
                          icon: const Icon(Icons.lock_outline, size: 18),
                          label: Text(
                            "edit_password".tr(),
                            style: getBoldStyle(color: primaryColor, fontSize: FontSize.s14),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pushNamed('/editPrifile'),
                          icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.white),
                          label: Text(
                            "تعديل البيانات",
                            style: getBoldStyle(color: Colors.white, fontSize: FontSize.s14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: getRegularStyle(color: grey, fontSize: FontSize.s12)),
                const SizedBox(height: 2),
                Text(value, style: getBoldStyle(color: blackColors, fontSize: FontSize.s15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 55,
      endIndent: 20,
      color: grey.withOpacity(0.2),
    );
  }
}
