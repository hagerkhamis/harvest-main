// models/country.dart
import 'dart:convert';

class Country {
  final String id;
  final String name;
  final String code;
  final String nationality;

  Country({
    required this.id,
    required this.name,
    required this.code,
    required this.nationality,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      nationality: json['nationality'] ?? '',
    );
  }
}

class CountriesResponse {
  final List<Country> countries;
  final String? message;

  CountriesResponse({
    required this.countries,
    this.message,
  });

  factory CountriesResponse.fromJson(dynamic json) {
    final Map<String, dynamic> map;

    if (json is String) {
      map = jsonDecode(json) as Map<String, dynamic>;
    } else if (json is Map<String, dynamic>) {
      map = json;
    } else {
      throw Exception('Invalid CountriesResponse JSON: ${json.runtimeType}');
    }

    var countriesJson = map['Countries'] ?? map['countries'] ?? [];

    if (countriesJson is String) {
      countriesJson = jsonDecode(countriesJson);
    }

    if (countriesJson is! List) {
      throw Exception('Invalid countries list type: ${countriesJson.runtimeType}');
    }

    List<Country> countries = (countriesJson as List).map((country) {
      if (country is String) {
        return Country.fromJson(jsonDecode(country) as Map<String, dynamic>);
      }
      return Country.fromJson(country as Map<String, dynamic>);
    }).toList();

    return CountriesResponse(
      countries: countries,
      message: map['message']?.toString(),
    );
  }
}