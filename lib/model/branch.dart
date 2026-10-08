// models/branch.dart
import 'dart:convert';

class Branch {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String latitude;
  final String longitude;
  final String nameAr;
  final String addressAr;

  Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.nameAr,
    required this.addressAr,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      addressAr: json['address_ar']?.toString() ?? '',
    );
  }
}

class BranchesResponse {
  final List<Branch> branches;
  final String message;

  BranchesResponse({
    required this.branches,
    required this.message,
  });

  factory BranchesResponse.fromJson(dynamic json) {
    final Map<String, dynamic> map;

    if (json is String) {
      map = jsonDecode(json) as Map<String, dynamic>;
    } else if (json is Map<String, dynamic>) {
      map = json;
    } else {
      throw Exception('Invalid BranchesResponse JSON: ${json.runtimeType}');
    }

    var branchesJson = map['Branches'] ?? map['branches'] ?? [];

    if (branchesJson is String) {
      branchesJson = jsonDecode(branchesJson);
    }

    if (branchesJson is! List) {
      throw Exception('Invalid branches list type: ${branchesJson.runtimeType}');
    }

    List<Branch> branches = (branchesJson as List)
        .map((branch) {
          if (branch is String) {
            return Branch.fromJson(jsonDecode(branch) as Map<String, dynamic>);
          }
          return Branch.fromJson(branch as Map<String, dynamic>);
        })
        .toList();
    
    return BranchesResponse(
      branches: branches,
      message: map['message']?.toString() ?? '',
    );
  }
}