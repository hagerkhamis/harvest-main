class BranchCoordinates {
  final double latitude;
  final double longitude;

  const BranchCoordinates({
    required this.latitude,
    required this.longitude,
  });
}

class BranchLocationHelper {
  static const double _egyptMinLat = 22.0;
  static const double _egyptMaxLat = 32.0;
  static const double _egyptMinLng = 24.0;
  static const double _egyptMaxLng = 37.0;

  static BranchCoordinates? resolveCoordinates({
    required String latitude,
    required String longitude,
    required String googleLink,
    bool googleLinkIsShared = false,
  }) {
    final fromLink = _parseCoordinatesFromUrl(googleLink);
    if (fromLink != null) return fromLink;

    if (!googleLinkIsShared && googleLink.trim().isNotEmpty) {
      // Short goo.gl links have no embedded coords; keep API values below.
    }

    final apiCoords = _parsePair(latitude, longitude);
    if (apiCoords != null) return apiCoords;

    return null;
  }

  static String buildMapsUrl({
    required String latitude,
    required String longitude,
    required String googleLink,
    required String address,
    bool googleLinkIsShared = false,
  }) {
    final coords = resolveCoordinates(
      latitude: latitude,
      longitude: longitude,
      googleLink: googleLink,
      googleLinkIsShared: googleLinkIsShared,
    );

    if (coords != null) {
      return 'https://www.google.com/maps/search/?api=1&query=${coords.latitude},${coords.longitude}';
    }

    if (!googleLinkIsShared) {
      final link = googleLink.trim();
      if (_isMapsUrl(link)) return link;
    }

    final query = address.trim().isNotEmpty ? address.trim() : '';
    if (query.isNotEmpty) {
      return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}';
    }

    return '';
  }

  static String displayName({
    required String name,
    required String nameAr,
    required String languageCode,
  }) {
    if (languageCode == 'ar' && nameAr.trim().isNotEmpty) return nameAr.trim();
    if (name.trim().isNotEmpty) return name.trim();
    return nameAr.trim();
  }

  static String displayAddress({
    required String address,
    required String addressAr,
    required String languageCode,
  }) {
    if (languageCode == 'ar' && addressAr.trim().isNotEmpty) {
      return addressAr.trim();
    }
    if (address.trim().isNotEmpty) return address.trim();
    return addressAr.trim();
  }

  static bool isValidBranch({
    required String name,
    required String nameAr,
    required String phone,
  }) {
    return displayName(name: name, nameAr: nameAr, languageCode: 'ar').isNotEmpty ||
        phone.trim().isNotEmpty;
  }

  static Map<String, int> sharedGoogleLinkCounts(
    Iterable<String> googleLinks,
  ) {
    final counts = <String, int>{};
    for (final link in googleLinks) {
      final trimmed = link.trim();
      if (trimmed.isEmpty || _parseCoordinatesFromUrl(trimmed) != null) {
        continue;
      }
      counts[trimmed] = (counts[trimmed] ?? 0) + 1;
    }
    return counts;
  }

  static bool isSharedGoogleLink(String googleLink, Map<String, int> counts) {
    final trimmed = googleLink.trim();
    if (trimmed.isEmpty) return false;
    if (_parseCoordinatesFromUrl(trimmed) != null) return false;
    return (counts[trimmed] ?? 0) > 1;
  }

  static BranchCoordinates? _parsePair(String latitude, String longitude) {
    final lat = _parseCoord(latitude);
    final lng = _parseCoord(longitude);
    if (lat == null || lng == null) return null;

    if (_isValidEgyptCoord(lat, lng)) {
      return BranchCoordinates(latitude: lat, longitude: lng);
    }

    if (_isValidEgyptCoord(lng, lat)) {
      return BranchCoordinates(latitude: lng, longitude: lat);
    }

    if (lat.abs() <= 90 && lng.abs() <= 180) {
      return BranchCoordinates(latitude: lat, longitude: lng);
    }

    return null;
  }

  static BranchCoordinates? _parseCoordinatesFromUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;

    final patterns = [
      RegExp(r'[?&]q=(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)', caseSensitive: false),
      RegExp(r'@(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)', caseSensitive: false),
      RegExp(r'query=(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)', caseSensitive: false),
      RegExp(r'center=(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(trimmed);
      if (match == null) continue;

      final lat = double.tryParse(match.group(1)!);
      final lng = double.tryParse(match.group(2)!);
      if (lat == null || lng == null) continue;

      if (_isValidEgyptCoord(lat, lng)) {
        return BranchCoordinates(latitude: lat, longitude: lng);
      }
      if (_isValidEgyptCoord(lng, lat)) {
        return BranchCoordinates(latitude: lng, longitude: lat);
      }
    }

    return null;
  }

  static double? _parseCoord(String? value) {
    if (value == null) return null;
    final cleaned = value.trim().replaceAll(',', '.');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  static bool _isValidEgyptCoord(double lat, double lng) {
    return lat >= _egyptMinLat &&
        lat <= _egyptMaxLat &&
        lng >= _egyptMinLng &&
        lng <= _egyptMaxLng;
  }

  static bool _isMapsUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('google.com/maps') ||
        lower.contains('maps.app.goo.gl') ||
        lower.contains('goo.gl/maps') ||
        lower.contains('maps.google.com');
  }
}
