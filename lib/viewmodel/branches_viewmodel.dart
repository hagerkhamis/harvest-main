// viewmodels/branches_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:hatvest/model/branch.dart';
import 'package:hatvest/model/country.dart';
import '../services/api_service.dart';

// viewmodels/branches_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class BranchesViewModel with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Branch> _branches = [];
  Branch? _selectedBranch;
  bool _isLoading = false;
  String _errorMessage = '';

  List<Branch> get branches => _branches;
  Branch? get selectedBranch => _selectedBranch;
  String? get selectedBranchId => _selectedBranch?.id;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchBranches() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _apiService.getBranches();
      _branches = response.branches;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void selectBranch(Branch? branch) {
    _selectedBranch = branch;
    notifyListeners();
  }

  List<Country> _countries = [];
  Country? _selectedCountry;

  List<Country> get countries => _countries;
  Country? get selectedCountry => _selectedCountry;
  String? get selectedCountryId => _selectedCountry?.id;

  Future<void> fetchCountries() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _apiService.getCountries();
      _countries = response.countries;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void selectCountry(Country? country) {
    _selectedCountry = country;
    notifyListeners();
  }
}
// class BranchesViewModel with ChangeNotifier {
//   final ApiService _apiService = ApiService();
  
//   List<Branch> _branches = [];
//   Branch? _selectedBranch;
//   bool _isLoading = false;
//   String _errorMessage = '';

//   List<Branch> get branches => _branches;
//   Branch? get selectedBranch => _selectedBranch;
//   bool get isLoading => _isLoading;
//   String get errorMessage => _errorMessage;

//   Future<void> fetchBranches() async {
//     _isLoading = true;
//     _errorMessage = '';
//     notifyListeners();

//     try {
//       final response = await _apiService.getBranches();
//       _branches = response.branches;
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       _errorMessage = e.toString();
//       notifyListeners();
//     }
//   }

//   void selectBranch(Branch? branch) {
//     _selectedBranch = branch;
//     notifyListeners();
//   }
// }