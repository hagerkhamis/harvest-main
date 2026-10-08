import 'package:flutter/material.dart';
import 'package:hatvest/model/exam_model.dart';
import 'package:hatvest/services/exam_list_service.dart';

class ExamListViewModel extends ChangeNotifier {
  final ExamListService _service = ExamListService();

  List<ExamItem> _exams = [];
  bool _isLoading = false;
  String? _error;

  List<ExamItem> get exams => _exams;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchExams() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _exams = await _service.fetchExams();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
