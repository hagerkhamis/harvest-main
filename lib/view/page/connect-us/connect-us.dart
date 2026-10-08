import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/shared/widgets/snackbar_helper.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart';
import 'package:provider/provider.dart';

class ConnectUs extends StatefulWidget {
  final bool showAppBar;
  const ConnectUs({super.key, this.showAppBar = true});

  @override
  State<ConnectUs> createState() => _ConnectUsState();
}

class _ConnectUsState extends State<ConnectUs> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.showAppBar ? AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "page_contact_us".tr(),
          style: getBoldStyle(color: primaryColor, fontSize: FontSize.s20),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_forward, color: blackColors, size: 28),
          ),
          const SizedBox(width: 8),
        ],
      ) : null,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/picc6.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
          children: [
            // Title
            Text(
              "page_contact_us".tr(),
              style: getBoldStyle(color: primaryColor, fontSize: FontSize.s24),
            ),
            const SizedBox(height: 30),
            
            // Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildInputField(
                    controller: _nameController,
                    label: "contact_name".tr(),
                    icon: Icons.person_outline,
                    hint: "contact_name_hint".tr(),
                    validator: (v) => v!.isEmpty ? "field_required".tr() : null,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _phoneController,
                    label: "contact_phone".tr(),
                    icon: Icons.phone_outlined,
                    hint: "010xxxxxxxx",
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? "field_required".tr() : null,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _emailController,
                    label: "contact_email".tr(),
                    icon: Icons.mail_outline,
                    hint: "example@domain.com",
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v!.isEmpty ? "field_required".tr() : null,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _messageController,
                    label: "contact_message".tr(),
                    icon: Icons.chat_bubble_outline,
                    hint: "contact_message_hint".tr(),
                    maxLines: 4,
                    validator: (v) => v!.isEmpty ? "field_required".tr() : null,
                  ),
                  const SizedBox(height: 24),
                  Consumer<ProfileViewModel>(
                    builder: (context, viewModel, _) {
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: viewModel.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    viewModel.sendMessage(
                                      _nameController.text.trim(),
                                      _emailController.text.trim(),
                                      _phoneController.text.trim(),
                                      _messageController.text.trim(),
                                      context,
                                    );
                                    _nameController.clear();
                                    _phoneController.clear();
                                    _emailController.clear();
                                    _messageController.clear();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  "send".tr(),
                                  style: getBoldStyle(color: Colors.white, fontSize: FontSize.s16),
                                ),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Contact Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContactInfoRow(Icons.location_on_outlined, "contact_address_label".tr(), "contact_address_value".tr()),
                  const SizedBox(height: 16),
                  _buildContactInfoRow(Icons.phone_outlined, "${"contact_phone".tr()}:", "01020034000"),
                  const SizedBox(height: 16),
                  _buildContactInfoRow(Icons.email_outlined, "${"contact_email".tr()}:", "info@harvestcollege.co.uk"),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getMediumStyle(color: blackColors, fontSize: FontSize.s14),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: getRegularStyle(color: Colors.grey.shade400, fontSize: FontSize.s13),
            prefixIcon: maxLines == 1 ? Icon(icon, color: primaryColor, size: 20) : null,
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildContactInfoRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "$title ",
                  style: getBoldStyle(color: blackColors, fontSize: FontSize.s13),
                ),
                TextSpan(
                  text: subtitle,
                  style: getRegularStyle(color: Colors.grey.shade700, fontSize: FontSize.s13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
