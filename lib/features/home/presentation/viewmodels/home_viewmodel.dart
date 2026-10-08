import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/model/home-model.dart' show ResultResponse;
import 'package:hatvest/model/profile-model.dart' show LeadModel;
import 'package:hatvest/model/slide_model.dart' show SlideModel;
import 'package:hatvest/services/home-service.dart' show HomeService;

class HomeViewModel extends ChangeNotifier {
  final HomeService _service = HomeService();

  List<SlideModel> _slides = [];
  bool _isLoading = false;
  bool _hasLoaded = false; // ✅ new flag
  int _currentIndex = 0;
  String? _error;
  String? get error => _error;

  List<SlideModel> get slides => _slides;
  bool get isLoading => _isLoading;
  int get currentIndex => _currentIndex;
  String? errorMessage;

  LeadModel? profile;
  ResultResponse? result;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Future<void> fetchSlides() async {
    if (_hasLoaded) return;

    _isLoading = true;
    notifyListeners();

    try {
      _slides = await _service.fetchSlides();
      _hasLoaded = true;
    } catch (e) {
      print('Error loading slides: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  //>>>
  Future<void> getProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      profile = await _service.fetchProfile();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getResultData() async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    final response = await _service.fetchResults();

    if (response != null) {
      result = response;
    } else {
      errorMessage = 'Failed to fetch results.';
    }

    _isLoading = false;
    notifyListeners();
  }
}
