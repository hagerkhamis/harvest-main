import 'package:flutter/material.dart';
import 'package:hatvest/model/about-app.dart' show AboutResponse;
import 'package:hatvest/model/get_help_model.dart' show GetHelpResponse;
import 'package:hatvest/services/api_service.dart' show ApiService;

class AboutViewModel extends ChangeNotifier {
  final ApiService _service = ApiService();

  bool isLoading = false;
  AboutResponse? aboutData;

  Future<void> getAboutData() async {
    isLoading = true;
    notifyListeners();

    final data = await _service.fetchAboutData();

    if (data != null) {
      aboutData = data;
    }

    isLoading = false;
    notifyListeners();
  }

  // bool isLoading = false;
  GetHelpResponse? data;

  Future<void> getHelpData() async {
    isLoading = true;
    notifyListeners();

    final response = await _service.fetchGetHelp();
    if (response != null) {
      data = response;
    }

    isLoading = false;
    notifyListeners();
  }
}
