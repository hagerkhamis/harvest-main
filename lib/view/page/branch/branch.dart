import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BranchPage extends StatelessWidget {
  final bool showAppBar;
  const BranchPage({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: ChangeNotifierProvider(
        create: (_) => ProfileViewModel()..fetchBranches(),
        child: Consumer<ProfileViewModel>(
          builder: (context, viewModel, _) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/picc7.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: CustomScrollView(
                slivers: [
                _buildSliverAppBar(context),
                if (viewModel.isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: _buildBranchSelector(viewModel),
                  ),
                  if (viewModel.selectedBranch != null)
                    SliverToBoxAdapter(
                      child: _buildBranchDetails(viewModel, context),
                    ),
                ],
              ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 20, bottom: 16, end: 60),
        title: Text(
          "page_branches".tr(),
          style: getBoldStyle(color: primaryColor, fontSize: FontSize.s20),
        ),
      ),
      actions: showAppBar ? [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7FA),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward, color: primaryColor, size: 20),
            ),
          ),
        ),
      ] : [],
    );
  }

  Widget _buildBranchSelector(ProfileViewModel viewModel) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "select_branch".tr(),
            style: getMediumStyle(color: const Color(0xFF8A94A6), fontSize: FontSize.s13),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.branches.length,
              itemBuilder: (context, index) {
                final branch = viewModel.branches[index];
                final isSelected = viewModel.selectedBranch?.id == branch.id;

                return GestureDetector(
                  onTap: () => viewModel.selectBranch(branch),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isSelected ? primaryColor : const Color(0xFFDDE3EE),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Text(
                      branch.localizedName(context.locale.languageCode),
                      style: getMediumStyle(
                        color: isSelected ? Colors.white : const Color(0xFF4A5568),
                        fontSize: FontSize.s13,
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

  Widget _buildBranchDetails(ProfileViewModel viewModel, BuildContext context) {
    final branch = viewModel.selectedBranch!;
    final locale = context.locale.languageCode;
    final branchName = branch.localizedName(locale);
    final branchAddress = branch.localizedAddress(locale);
    final mapsUrl = branch.mapsUrl(locale);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Map Card
          GestureDetector(
            onTap: () async {
              if (mapsUrl.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("cannot_open_maps".tr())),
                );
                return;
              }

              final uri = Uri.parse(mapsUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("cannot_open_maps".tr())),
                );
              }
            },
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.08),
                    primaryColor.withOpacity(0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: primaryColor.withOpacity(0.15)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background pattern circles
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -10,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withOpacity(0.04),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.location_on_rounded, color: primaryColor, size: 30),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "open_map".tr(),
                        style: getMediumStyle(color: primaryColor, fontSize: FontSize.s13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Info Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Branch name header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.store_rounded, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        branchName,
                        style: getBoldStyle(color: Colors.white, fontSize: FontSize.s16),
                      ),
                    ],
                  ),
                ),

                // Address row
                _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  value: branchAddress,
                  isLast: false,
                ),

                // Phone row
                _buildInfoRow(
                  icon: Icons.phone_outlined,
                  label: "phone".tr(),
                  value: branch.phone,
                  isLast: true,
                  onTap: () async {
                    final url = 'tel:${branch.phone}';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    String? label,
    required String value,
    required bool isLast,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: Color(0xFFF0F2F5), width: 1),
                ),
          borderRadius: isLast
              ? const BorderRadius.vertical(bottom: Radius.circular(16))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: primaryColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label != null)
                    Text(
                      label,
                      style: getMediumStyle(
                        color: const Color(0xFF8A94A6),
                        fontSize: FontSize.s12,
                      ),
                    ),
                  Text(
                    value,
                    style: getMediumStyle(
                      color: const Color(0xFF2D3748),
                      fontSize: FontSize.s14,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_left, color: const Color(0xFF8A94A6), size: 20),
          ],
        ),
      ),
    );
  }
}
