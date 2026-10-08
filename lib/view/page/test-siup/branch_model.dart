// branch_model.dart
class Branch {
  final String id;
  final String name;

  Branch({required this.id, required this.name});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}

// country_model.dart
class Country {
  final String id;
  final String name;

  Country({required this.id, required this.name});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}
