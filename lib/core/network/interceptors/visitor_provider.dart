import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
class VisitorProvider extends ChangeNotifier {
  bool _isVisitor = true;

  bool get isVisitor => _isVisitor;

  void login() {
    _isVisitor = true;
    notifyListeners();
  }

  void logout() {
    _isVisitor = true;
    notifyListeners();
  }

  void showVisitorAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("visitor_restricted_title".tr()),
          content: Text("visitor_restricted_message".tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("cancel".tr()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login');
              },
              child: Text("login_btn".tr()),
            ),
          ],
        );
      },
    );
  }
}

