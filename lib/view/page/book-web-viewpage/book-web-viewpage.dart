import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/utils/book_url_helper.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BookWebViewPage extends StatefulWidget {
  final String url;
  final String? title;

  const BookWebViewPage({
    Key? key,
    required this.url,
    this.title,
  }) : super(key: key);

  @override
  State<BookWebViewPage> createState() => _BookWebViewPageState();
}

class _BookWebViewPageState extends State<BookWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/91.0.4472.120 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(BookUrlHelper.normalize(widget.url)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title ?? "view_book".tr(),
          style: getBoldStyle(color: primaryColor, fontSize: FontSize.s18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        automaticallyImplyLeading: false,
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
}
