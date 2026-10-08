import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hatvest/enums/request_status.dart';
import 'package:hatvest/model/BranchModel.dart' show MainBranch;
import 'package:hatvest/model/app-settings-model.dart';
import 'package:hatvest/model/certificate-model.dart';
import 'package:hatvest/model/certificate_response.dart' show Certificate;
import 'package:hatvest/model/deal_model.dart';
import 'package:hatvest/model/digita-book-model.dart';
import 'package:hatvest/model/exam-rusel.dart' show ExamRuseltModel;
import 'package:hatvest/model/get-technicaltracker-model.dart'
    show ExamSkill, PtSkillsTex;
import 'package:hatvest/model/group-model.dart';
import 'package:hatvest/model/home-model.dart';
import 'package:hatvest/model/inquiry_viewmodel.dart';
import 'package:hatvest/model/offer-view-model.dart';
import 'package:hatvest/model/profile-model.dart';
import 'package:hatvest/model/running-group.dart';
import 'package:hatvest/model/serives-view-model.dart'
    show ServicesDetailsModel;
import 'package:hatvest/model/vocab-ruselt.dart'
    show AdultResult, VocabRuseltModel;
import 'package:hatvest/services/app-service.dart';
import 'package:hatvest/shared/widgets/snackbar_helper.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  LeadModel? profile;
  OfferDetailsModel? offerDetails;

  ServicesDetailsModel? serviesDetails;

  String? errorMessage;
  bool isLoading = false;

  List<DigitalBook> _books = [];
  List<DigitalBook> get books => _books;

  // ResultResponse? _result;
  bool _isLoading = false;
  String? _error;
  ResultResponse? result;
  List<Inquiry> openInquiries = [];
  List<Inquiry> closedInquiries = [];
  List<LabelType> labelTypes = [];

  // ResultResponse? get result => _result;
  String? get error => _error;

  Future<void> getProfile() async {
    isLoading = true;
    notifyListeners();
    try {
      profile = await _service.fetchProfile();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getResultData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final response = await _service.fetchResults();

    if (response != null) {
      result = response;
    } else {
      errorMessage = 'Failed to fetch results.';
    }

    isLoading = false;
    notifyListeners();
  }

  //
  Future<void> getOfferDetails(int id) async {
    try {
      isLoading = true;
      notifyListeners();

      offerDetails = await _service.fetchOfferDetailsById(id);
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //
  Future<void> getServiesDetails(int id) async {
    try {
      isLoading = true;
      notifyListeners();

      serviesDetails = await _service.fetchServiesDetailsById(id);
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //
  List<GroupModel> runningGroups = [];
  List<GroupModel> completeGroups = [];
  List<GroupModel> upcomingGroups = [];

  Future<void> loadGroups() async {
    isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.fetchGroups();
      runningGroups = result['running'] ?? [];
      completeGroups = result['complete'] ?? [];
      upcomingGroups = result['upcoming'] ?? [];
    } catch (e) {
      _error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  //
  Future<void> sendConfirmation({
    required int confirmation,
    required String groupId,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await _service.sendConfirmation(
          confirmation: confirmation, groupId: groupId);

      // await getRunningGroups();
    } catch (e) {
      _error = "حدث خطأ أثناء إرسال التأكيد";
      print(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  //

  Future<bool> joinGroup({
    required String groupId,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await _service.joinGroup(groupId: groupId);

      if (response.statusCode == 200 && response.data['message'] == 'done') {
        return true; // Success
      }
    } catch (e) {
      _error = "حدث خطأ أثناء إرسال التأكيد";
      print(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }

    return false; // Failed
  }

  //
  Future<void> fetchBooks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _books = await _service.fetchBooks();
    } catch (e) {
      _books = [];
      debugPrint('Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  //
  PtSkillsTex? ptSkills;
  List<ExamSkill> examSkills = [];

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    final data = await _service.fetchTrackerData();
    ptSkills = data['ptSkills'];
    examSkills = data['examSkills'];
    isLoading = false;
    notifyListeners();
  }
  //

  AdultResult? _adultResult;

  AdultResult? get adultResult => _adultResult;

  Future<void> fetchAdultResult(int applicationId) async {
    isLoading = true;
    notifyListeners();

    try {
      _adultResult = await _service.getAdultResult(applicationId);
    } catch (e) {
      _adultResult = null;
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //
  Future<void> fetchKidsPtResult(int applicationId) async {
    isLoading = true;
    notifyListeners();

    try {
      _adultResult = await _service.getKidsPtResult(applicationId);
    } catch (e) {
      _adultResult = null;
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //
  ExamRuseltModel? _examResult;

  ExamRuseltModel? get examResult => _examResult;

  Future<void> fetchExamResult(int applicationId) async {
    _isLoading = true;
    notifyListeners();

    _examResult = await _service.getExamResult(applicationId);

    _isLoading = false;
    notifyListeners();
  }

  //ExamRuseltModel
  CertificateModel? item;

  Future<void> getItem(int id) async {
    isLoading = true;
    notifyListeners();

    try {
      item = await _service.fetchExtraItem(id);
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  //

  List<Certificate> _certificates = [];

  List<Certificate> get certificates => _certificates;

  Future<void> fetchCertificates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _service.fetchCertificates();

    if (response != null) {
      _certificates = response.certificates;
    } else {
      _error = 'Failed to fetch data';
    }

    _isLoading = false;
    notifyListeners();
  }

  //
  bool hasError = false;
  Future<void> fetchData() async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      final data = await _service.fetchInquiries();

      openInquiries = List<Inquiry>.from(
        data['openinquiries']?.map((json) => Inquiry.fromJson(json)) ?? [],
      );

      closedInquiries = List<Inquiry>.from(
        data['closedinquiries']?.map((json) => Inquiry.fromJson(json)) ?? [],
      );

      labelTypes = List<LabelType>.from(
        data['Label_Types']?.map((json) => LabelType.fromJson(json)) ?? [],
      );
    } catch (e) {
      // If 404 or network issue → flag error
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //
  Future<void> fetchComplainData() async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      final data = await _service.fetchComplain();

      openInquiries = List<Inquiry>.from(
        data['opencomplain']?.map((json) => Inquiry.fromJson(json)) ?? [],
      );

      closedInquiries = List<Inquiry>.from(
        data['closedcomplain']?.map((json) => Inquiry.fromJson(json)) ?? [],
      );

      labelTypes = List<LabelType>.from(
        data['Label_Types']?.map((json) => LabelType.fromJson(json)) ?? [],
      );
    } catch (e) {
      // If 404 or network issue → flag error
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitInquiry({
    required int labelId,
    required String message,
    File? file,
    String? fileName,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _service.sendInquiry(
        labelId: labelId,
        message: message,
        file: file,
        fileName: fileName,
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitComplain({
    required int labelId,
    required String message,
    File? file, // make nullable
    required String displayName,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _service.sendComplain(
        labelId: labelId,
        message: message,
        file: file, // can be null
        displayName: displayName,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Submit complain error: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //
  List<MainBranch> _branches = [];
  MainBranch? _selectedBranch;

  List<MainBranch> get branches => _branches;
  MainBranch? get selectedBranch => _selectedBranch;

  Future<void> fetchBranches() async {
    _isLoading = true;
    notifyListeners();

    _branches = await _service.getBranches();
    if (_branches.isNotEmpty) _selectedBranch = _branches.first;

    _isLoading = false;
    notifyListeners();
  }

  void selectBranch(MainBranch branch) {
    _selectedBranch = branch;
    notifyListeners();
  }

  //
  Future<void> sendMessage(String name, String email, String phone, String message, BuildContext context) async {
    isLoading = true;
    notifyListeners();

    bool success = await _service.sendContactMessage(name, email, phone, message);

    isLoading = false;
    notifyListeners();

    if (success) {
      showAwesomeSnackBar(
        title: "Success!",
        message: "تم إرسال الاستفسار بنجاح",
        type: SnackbarType.success,
      );
    } else {
      showAwesomeSnackBar(
        title: "Error!",
        message: "حدث خطأ أثناء الإرسال",
        type: SnackbarType.error,
      );
    }
  }

  //
  List<RunningGroup> _groups = [];
  List<RunningGroup> get groups => _groups;

  Future<void> fetchGroups(int trackId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _groups = await _service.fetchRunningGroups(trackId);
    } catch (e) {
      debugPrint("Error: $e");
      _groups = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  AppSettings? _appSettings;
  AppSettings? get appSettings => _appSettings;

  Future<void> fetchAppSettings() async {
    try {
      final data = await _service.fetchAppSettings();
      _appSettings = AppSettings.fromJson(data);
      notifyListeners();
    } catch (e) {
      print('Failed to fetch app settings: $e');
    }
  }

  //>>>
  RequestStatus _loadStatus = RequestStatus.idle;

  void _updateStatus(RequestStatus status) {
    _loadStatus = status;
    notifyListeners();
  }

  SlidesResponse? _slidesResponse;
  List<Slide> get slides => _slidesResponse?.slidesShow ?? [];

  Future<void> fetchDeals() async {
    _updateStatus(RequestStatus.loading);
    try {
      _slidesResponse = await _service.fetchDeals();
      _updateStatus(RequestStatus.success);
    } catch (e) {
      print('Error fetching slides: $e');
      _updateStatus(RequestStatus.failed);
    }
  }
  //.....

  String termsContent = "";
  bool isApproved = false;
  // bool isLoading = true;

  // just fetch terms content
  Future<void> loadTerms() async {
    try {
      final data = await _service.fetchTerms();
      if (data != null && data['page'] != null && data['page']['content'] != null) {
        termsContent = data['page']['content'];
      } else {
        termsContent = "";
      }
    } catch (e) {
      print("Error loading terms: $e");
      termsContent = "";
    }
    notifyListeners();
  }

  Future<String> loadAppTermsById(int id) async {
    try {
      return await _service.fetchAppTermsById(id);
    } catch (e) {
      return '';
    }
  }

  Map<String, String> _socialLinks = {};
  Map<String, String> get socialLinks => _socialLinks;

  bool _socialLinksFetched = false;
  bool get socialLinksFetched => _socialLinksFetched;

  Future<void> fetchAboutApp() async {
    if (_socialLinksFetched) return;
    _socialLinksFetched = true;
    try {
      final data = await _service.fetchAboutApp();
      _socialLinks = {
        'facebook': data['facebook']?.toString() ?? '',
        'instagram': data['instagram']?.toString() ?? '',
        'twitter': data['twitter']?.toString() ?? '',
        'youtube': data['youtube']?.toString() ?? '',
        'tiktok': data['tiktok']?.toString() ?? '',
        'linkedin': data['linkedin']?.toString() ?? '',
      };
      notifyListeners();
    } catch (e) {
      _socialLinksFetched = false;
      print('Failed to fetch about app: $e');
    }
  }

  Future<void> approve() async {
    await _service.approveTerms();
    // you no longer need to update a local flag
    notifyListeners();
  }
}
