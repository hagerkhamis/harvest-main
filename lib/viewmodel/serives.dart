import 'package:flutter/material.dart';
import 'package:hatvest/model/offer_model.dart';
import 'package:hatvest/model/serives-corse-model.dart'
    show Service, ServicesCourse;
import 'package:hatvest/model/home-model.dart' show ResultResponse;
import 'package:hatvest/core/utils/offers_parser.dart';
import 'package:hatvest/services/app-service.dart';

class CourseViewModel extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  List<Course> _onlineCourses = [];
  List<Course> _offlineCourses = [];
  List<ServicesCourse> _servicesCourse = [];
  String? _servicesError;
  bool get isLoading => _isLoading;
  bool _isLoading = false;
  String? get servicesError => _servicesError;

  bool _isOnline = true;
  String? _selectedTitle;
  String? _selectedSerivesTitle;

  // Getters
  bool get isOnline => _isOnline;

  List<Course> get courses => _isOnline ? _onlineCourses : _offlineCourses;
  List<Course> get allOfflineCourses => _offlineCourses;
  List<Course> get allOnlineCourses => _onlineCourses;

  String? get selectedTitle => _selectedTitle;

  List<Offer> get selectedOffers {
    final course = courses.firstWhere(
      (c) => c.title == _selectedTitle,
      orElse: () => Course(id: '', title: '', offers: []),
    );
    return course.offers;
  }

  //
  List<ServicesCourse> get serives => _servicesCourse;

  String? get selectedSerivesTitle => _selectedSerivesTitle;

  List<Service> get selectedSerives {
    final selected = _selectedSerivesTitle ?? _selectedTitle;
    if (selected == null || selected.isEmpty) return const [];

    final service = serives.firstWhere(
      (c) => c.title == selected || c.titleAr == selected || c.titleEn == selected,
      orElse: () => ServicesCourse(
        id: '',
        title: '',
        titleEn: '',
        titleAr: '',
        services: const [],
      ),
    );
    return service.services;
  }

  // Toggle Online / Offline
  void toggleOnline(bool value) {
    _isOnline = value;
    _syncSelectedTitle();
    notifyListeners();
  }

  // Set selected course title
  void selectTitle(String? title) {
    _selectedTitle = title;
    _selectedSerivesTitle = title;
    notifyListeners();
  }

  Future<void> loadOffers({ResultResponse? homeResult}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.fetchCoursesOnline(),
        _service.fetchCoursesOfline(),
      ]);
      _onlineCourses = results[0];
      _offlineCourses = results[1];
      hydrateFromHomeIfEmpty(homeResult);
      _syncSelectedTitle(autoSwitchTab: true);
    } catch (e) {
      debugPrint('Error loading offers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void hydrateFromHomeIfEmpty(ResultResponse? homeResult) {
    if (homeResult == null) return;

    if (!_hasOffers(_onlineCourses) && homeResult.onlineOffers.isNotEmpty) {
      _onlineCourses =
          OffersParser.coursesFromHomeOffers(homeResult.onlineOffers);
    }
    if (!_hasOffers(_offlineCourses) && homeResult.offlineOffers.isNotEmpty) {
      _offlineCourses =
          OffersParser.coursesFromHomeOffers(homeResult.offlineOffers);
    }
  }

  bool _hasOffers(List<Course> courses) =>
      courses.any((course) => course.offers.isNotEmpty);

  void _syncSelectedTitle({bool autoSwitchTab = false}) {
    if (_isOnline) {
      if (_hasOffers(_onlineCourses)) {
        _pickTitle(_onlineCourses);
        return;
      }
      if (autoSwitchTab && _hasOffers(_offlineCourses)) {
        _isOnline = false;
        _pickTitle(_offlineCourses);
        return;
      }
    } else {
      if (_hasOffers(_offlineCourses)) {
        _pickTitle(_offlineCourses);
        return;
      }
      if (autoSwitchTab && _hasOffers(_onlineCourses)) {
        _isOnline = true;
        _pickTitle(_onlineCourses);
        return;
      }
    }

    if (_hasOffers(_onlineCourses)) {
      _isOnline = true;
      _pickTitle(_onlineCourses);
      return;
    }
    if (_hasOffers(_offlineCourses)) {
      _isOnline = false;
      _pickTitle(_offlineCourses);
      return;
    }

    _selectedTitle = null;
  }

  void _pickTitle(List<Course> courses) {
    final withOffers =
        courses.where((course) => course.offers.isNotEmpty).toList();
    if (withOffers.isEmpty) {
      _selectedTitle = null;
      return;
    }

    if (_selectedTitle == null ||
        !withOffers.any((course) => course.title == _selectedTitle)) {
      _selectedTitle = withOffers.first.title;
    }
  }

  // Fetch Online Courses
  Future<void> fetchCoursesOnlien() async {
    _isLoading = true;
    notifyListeners();
    try {
      _onlineCourses = await _service.fetchCoursesOnline();
      _syncSelectedTitle();
    } catch (e) {
      debugPrint("Error fetching online courses: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch Offline Courses
  Future<void> fetchCoursesOflien() async {
    _isLoading = true;
    notifyListeners();
    try {
      _offlineCourses = await _service.fetchCoursesOfline();
      _syncSelectedTitle();
    } catch (e) {
      debugPrint("Error fetching offline courses: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //
  Future<void> fetchServices() async {
    _isLoading = true;
    _servicesError = null;
    notifyListeners();
    try {
      _servicesCourse = await _service.fetchServices();
      final hasCatalogItems =
          _servicesCourse.any((c) => c.services.isNotEmpty);
      if (_servicesCourse.isNotEmpty && hasCatalogItems) {
        final firstWithServices = _servicesCourse.firstWhere(
          (c) => c.services.isNotEmpty,
        );
        _selectedTitle = firstWithServices.title;
        _selectedSerivesTitle = firstWithServices.title;
        _servicesError = null;
      } else if (_servicesCourse.isNotEmpty && !hasCatalogItems) {
        // Backend returned course tabs but nested rows lack title/fees/image.
        _selectedTitle = null;
        _selectedSerivesTitle = null;
        _servicesCourse = [];
        _servicesError = 'incomplete';
      } else {
        _selectedTitle = null;
        _selectedSerivesTitle = null;
        _servicesError = 'empty';
      }
    } catch (e) {
      _servicesCourse = [];
      _selectedTitle = null;
      _selectedSerivesTitle = null;
      _servicesError = e.toString().contains('500') ||
              e.toString().toLowerCase().contains('server')
          ? 'server'
          : 'failed';
      debugPrint("Error fetching services: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
