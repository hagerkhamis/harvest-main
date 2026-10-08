// signup_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:hatvest/view/page/test-siup/%20branch_model.dart';
import 'signup_service.dart';

class SignUpViewModel extends ChangeNotifier {
  final SignUpService _service = SignUpService();

  List<Branch> branches = [];
  List<Country> countries = [];
  Branch? selectedBranch;
  Country? selectedCountry;
  bool isLoading = false;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();
    try {
      branches = await _service.getBranches();
      countries = await _service.getCountries();
    } catch (e) {
      // You can add logging or error handling here
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setBranch(Branch branch) {
    selectedBranch = branch;
    notifyListeners();
  }

  void setCountry(Country country) {
    selectedCountry = country;
    notifyListeners();
  }

  Future<void> signUp(String name, String email, String password) async {
    if (selectedBranch == null || selectedCountry == null) return;
    await _service.signUp({
      "f_name": name,
      "l_name": "name",
      "email": email,
      "gender": "male",
      "mobile_1": "01009786178",
      "password": password,
      "branch_id": selectedBranch!.id,
      "country": selectedCountry!.id,
      "prefered_track_id": "2"
    });
  }
}


// class SignUpViewModel extends ChangeNotifier {
//   final SignUpService _service = SignUpService();

//   List<Branch> branches = [];
//   List<Country> countries = [];
//   Branch? selectedBranch;
//   Country? selectedCountry;
//   bool isLoading = false;

//   Future<void> loadData() async {
//     isLoading = true;
//     notifyListeners();
//     try {
//       branches = await _service.getBranches();
//       countries = await _service.getCountries();
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   void setBranch(Branch branch) {
//     selectedBranch = branch;
//     notifyListeners();
//   }

//   void setCountry(Country country) {
//     selectedCountry = country;
//     notifyListeners();
//   }

//   Future<void> signUp(String name, String email, String password) async {
//     if (selectedBranch == null || selectedCountry == null) return;
//     await _service.signUp({
//       "f_name": name,
//       "l_name": "name",
//       "email": email,
//       "gender": "male",
//       "mobile_1": "01003786178",
//       "password": password,
//       "branch_id": selectedBranch!.id,
//       "country": selectedCountry!.id,
//       "prefered_track_id": "2"
//     });
//   }
// }

    // "f_name":"mostafa",
    // "l_name":"mohammed",
    // "email":"mostafazizooo6564669@yahoo.com",
    // "gender":"male",
    // "mobile_1":"01003786142",
    // "branch_id":"4",
    // "password":"Harvest@123",
    // "country":"1",
    // "prefered_track_id":"2"
