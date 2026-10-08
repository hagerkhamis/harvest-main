import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CertificatesPage extends StatefulWidget {
  const CertificatesPage({super.key});

  @override
  State<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends State<CertificatesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<ProfileViewModel>(context, listen: false)
        .fetchCertificates());
  }

  Future<void> _downloadPdf(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      debugPrint("❌ Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      body: Stack(
        children: [
          // خلفية الصفحة
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/picc3.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // محتوى الصفحة
          viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : viewModel.error != null
                  ? Center(child: Text(viewModel.error!))
                  : ListView.builder(
                  itemCount: viewModel.certificates.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final cert = viewModel.certificates[index];

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16), // ✅ space
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: boldWhite,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// ✅ Name
                          Text(
                            cert.displayName ?? "",
                            style: getMediumStyle(color: blackColors),
                          ),

                          const SizedBox(height: 8),

                          /// ✅ Image (if exists)
                          if (cert.image != null && cert.image!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                cert.image!,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),

                          /// ✅ PDF Button
                          if (cert.pdf != null && cert.pdf!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () => _downloadPdf(cert.pdf!),
                              icon: const Icon(Icons.file_download),
                              label: Text("download_pdf".tr()),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
