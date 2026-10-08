import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:hatvest/model/BranchModel.dart';

class BranchSelectionPage extends StatefulWidget {
  const BranchSelectionPage({super.key});

  @override
  State<BranchSelectionPage> createState() => _BranchSelectionPageState();
}

class _BranchSelectionPageState extends State<BranchSelectionPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ProfileViewModel>(context, listen: false).fetchBranches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF0D243D), size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Progress indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Step 2 of 4',
                            style: getRegularStyle(color: Colors.grey, fontSize: FontSize.s12),
                          ),
                          Text(
                            'الخطوة ٢ من ٤',
                            style: getRegularStyle(color: Colors.grey, fontSize: FontSize.s12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildProgressSegment(true)),
                          const SizedBox(width: 4),
                          Expanded(child: _buildProgressSegment(true)),
                          const SizedBox(width: 4),
                          Expanded(child: _buildProgressSegment(false)),
                          const SizedBox(width: 4),
                          Expanded(child: _buildProgressSegment(false)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Title
                Text(
                  'Choose Your Branch',
                  style: getBoldStyle(color: const Color(0xFF0D243D), fontSize: FontSize.s24),
                ),
                Text(
                  'اختر فرعك',
                  style: getBoldStyle(color: const Color(0xFF0D243D), fontSize: FontSize.s24),
                ),
                const SizedBox(height: 40),
                // Branch List
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: viewModel.branches.length,
                          itemBuilder: (context, index) {
                            final branch = viewModel.branches[index];
                            final isSelected = viewModel.selectedBranch?.id == branch.id;
                            return _buildBranchCard(branch, isSelected, viewModel);
                          },
                        ),
                ),
                // Bottom Button and Support
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: viewModel.selectedBranch == null
                              ? null
                              : () {
                                  // Navigate to signup or next step
                                  Navigator.pushNamed(context, '/singUp');
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D243D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continue متابعة',
                                style: getBoldStyle(color: Colors.white, fontSize: FontSize.s16),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressSegment(bool active) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF4A90E2) : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildBranchCard(MainBranch branch, bool isSelected, ProfileViewModel viewModel) {
    final locale = EasyLocalization.of(context)?.locale.languageCode ?? 'ar';
    return GestureDetector(
      onTap: () => viewModel.selectBranch(branch),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A90E2) : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.location_on_outlined, color: Color(0xFF0D243D)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    branch.localizedName(locale),
                    style: getBoldStyle(color: const Color(0xFF0D243D), fontSize: FontSize.s16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    branch.localizedAddress(locale),
                    style: getRegularStyle(color: Colors.grey, fontSize: FontSize.s12),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF4A90E2) : const Color(0xFFE5E7EB),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF4A90E2) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
