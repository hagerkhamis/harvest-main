import 'package:flutter/material.dart';
import 'package:hatvest/core/theme/app_colors.dart';
import 'package:hatvest/core/theme/font_manager.dart' as fm;
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart' show ProfileViewModel;
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';

Future<void> showTermsDialog(BuildContext context) async {
  final viewModel = Provider.of<ProfileViewModel>(context, listen: false);

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (context) => _TermsSheet(viewModel: viewModel),
  );
}

class _TermsSheet extends StatelessWidget {
  final ProfileViewModel viewModel;
  const _TermsSheet({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: context.divider)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.description_outlined, color: primaryColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "الشروط والأحكام",
                        style: getBoldStyle(color: context.textPrimary, fontSize: fm.FontSize.s18),
                      ),
                      Text(
                        "يرجى القراءة والموافقة للمتابعة",
                        style: getRegularStyle(color: context.textSecondary, fontSize: fm.FontSize.s12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Html(
                data: viewModel.termsContent,
                style: {
                  "body": Style(
                    fontSize: FontSize(14),
                    color: context.textPrimary,
                    lineHeight: LineHeight(1.6),
                  ),
                  "p": Style(
                    color: context.textSecondary,
                  ),
                },
              ),
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: context.cardBg,
              border: Border(top: BorderSide(color: context.divider)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -4)),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () async {
                  await viewModel.approve();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(
                  "أوافق على الشروط والأحكام",
                  style: getBoldStyle(color: Colors.white, fontSize: fm.FontSize.s16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
