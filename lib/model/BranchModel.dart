import 'package:hatvest/core/utils/branch_location_helper.dart';

class MainBranch {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String latitude;
  final String longitude;
  final String googleLink;
  final String nameAr;
  final String addressAr;
  final bool googleLinkIsShared;

  MainBranch({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.googleLink,
    this.nameAr = '',
    this.addressAr = '',
    this.googleLinkIsShared = false,
  });

  factory MainBranch.fromJson(
    Map<String, dynamic> json, {
    bool googleLinkIsShared = false,
  }) {
    return MainBranch(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      googleLink: json['google_link']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      addressAr: json['address_ar']?.toString() ?? '',
      googleLinkIsShared: googleLinkIsShared,
    );
  }

  String localizedName(String languageCode) {
    return BranchLocationHelper.displayName(
      name: name,
      nameAr: nameAr,
      languageCode: languageCode,
    );
  }

  String localizedAddress(String languageCode) {
    return BranchLocationHelper.displayAddress(
      address: address,
      addressAr: addressAr,
      languageCode: languageCode,
    );
  }

  String mapsUrl(String languageCode) {
    return BranchLocationHelper.buildMapsUrl(
      latitude: latitude,
      longitude: longitude,
      googleLink: googleLink,
      address: localizedAddress(languageCode),
      googleLinkIsShared: googleLinkIsShared,
    );
  }

  BranchCoordinates? get coordinates {
    return BranchLocationHelper.resolveCoordinates(
      latitude: latitude,
      longitude: longitude,
      googleLink: googleLink,
      googleLinkIsShared: googleLinkIsShared,
    );
  }
}
