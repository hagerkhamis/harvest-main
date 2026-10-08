import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/features/cart/presentation/pages/my_payment_page.dart';
import 'package:hatvest/core/theme/app_colors.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/view/page/survey-page/survey-page.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final String? type;

  const PaymentWebView({
    required this.paymentUrl,
    this.type,
    Key? key,
  }) : super(key: key);

  @override
  _PaymentWebViewState createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late WebViewController _controller;
  bool _isLoading = true;
  PaymentResult? _result; // null = still in webview

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print("🔄 Loading URL: $url");
            _checkPaymentResult(url);
          },
          onPageFinished: (url) {
            print("✅ Finished Loading: $url");
            setState(() => _isLoading = false);
            _checkPaymentResult(url);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkPaymentResult(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('success') || lower.contains('paid') || lower.contains('completed')) {
      if (_result != PaymentResult.success) {
        setState(() => _result = PaymentResult.success);
      }
    } else if (lower.contains('fail') || lower.contains('error') || lower.contains('cancel') || lower.contains('declined')) {
      if (_result != PaymentResult.failure) {
        setState(() => _result = PaymentResult.failure);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_result == PaymentResult.success) {
      return _buildSuccessPage();
    } else if (_result == PaymentResult.failure) {
      return _buildFailurePage();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "إتمام الدفع",
          style: getBoldStyle(color: primaryColor, fontSize: FontSize.s18),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildSuccessPage() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 48),

                // ── Icon circle with gradient ──────────────────────────────
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1B4F72),
                        primaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.35),
                        blurRadius: 32,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 68,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 40),

                // ── Title ──────────────────────────────────────────────────
                Text(
                  "تهانينا!",
                  style: getBoldStyle(color: primaryColor, fontSize: FontSize.s28),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  "تم إتمام عملية الدفع بنجاح",
                  style: getSemiBoldStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
                      fontSize: FontSize.s16),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 6),

                Text(
                  "يمكنك الآن الاستمتاع بخدماتنا",
                  style: getRegularStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      fontSize: FontSize.s14),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // ── Info card ──────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.verified_rounded,
                            color: Color(0xFF2E7D32), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "عملية ناجحة",
                              style: getSemiBoldStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: FontSize.s14),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "تم تسجيل دفعتك بنجاح",
                              style: getRegularStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5),
                                  fontSize: FontSize.s13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // ── CTA button ─────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SurveyPage(applicationId: 0),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "تقييم التجربة",
                      style: getBoldStyle(color: Colors.white, fontSize: FontSize.s16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => MyPayment()),
                        (route) => route.isFirst,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "view_my_payments".tr(),
                      style: getBoldStyle(color: primaryColor, fontSize: FontSize.s16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Secondary link ─────────────────────────────────────────
                TextButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (r) => r.isFirst),
                  child: Text(
                    "العودة للرئيسية",
                    style: getMediumStyle(
                        color: primaryColor.withOpacity(0.7),
                        fontSize: FontSize.s14),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFailurePage() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 48),

                // ── Icon circle ────────────────────────────────────────────
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC0392B), Color(0xFFE74C3C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE74C3C).withOpacity(0.35),
                        blurRadius: 32,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 68,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 40),

                // ── Title ──────────────────────────────────────────────────
                Text(
                  "عذراً!",
                  style: getBoldStyle(
                      color: const Color(0xFFC0392B), fontSize: FontSize.s28),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  "لم تكتمل عملية الدفع",
                  style: getSemiBoldStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
                      fontSize: FontSize.s16),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 6),

                Text(
                  "يرجى المحاولة مرة أخرى أو اختيار طريقة دفع أخرى",
                  style: getRegularStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      fontSize: FontSize.s14),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // ── Info card ──────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.error_outline_rounded,
                            color: Color(0xFFC62828), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "فشلت العملية",
                              style: getSemiBoldStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: FontSize.s14),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "تأكد من بياناتك وحاول مرة أخرى",
                              style: getRegularStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5),
                                  fontSize: FontSize.s13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // ── Primary CTA ────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _result = null;
                        _isLoading = true;
                        _controller.loadRequest(Uri.parse(widget.paymentUrl));
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "حاول مرة أخرى",
                      style: getBoldStyle(
                          color: Colors.white, fontSize: FontSize.s16),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Secondary ─────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "العودة للرئيسية",
                      style: getMediumStyle(
                          color: primaryColor, fontSize: FontSize.s15),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum PaymentResult { success, failure }
