class CertificateImageHelper {
  static const _cdnBase = 'https://harvestcollege.co.uk/';

  /// Known certificate hero images from the public website when API omits `image`.
  static const Map<int, String> _idFallbacks = {
    2: 'https://harvestcollege.co.uk/uploads/extraItems/295932.webp',
    3: 'https://harvestcollege.co.uk/uploads/extraItems/986327.webp',
  };

  static String resolve(String? raw) {
    var value = (raw ?? '').trim();
    if (value.isEmpty || value.toLowerCase() == 'null') return '';

    if (value.startsWith('http://') || value.startsWith('https://')) {
      final uri = Uri.tryParse(value);
      if (uri != null &&
          uri.host == 'sys.harvestcollege.co.uk' &&
          uri.path.contains('/uploads/')) {
        return uri.replace(host: 'harvestcollege.co.uk').toString();
      }
      return value;
    }

    if (value.startsWith('/')) value = value.substring(1);

    if (!value.contains('/') && !value.startsWith('uploads')) {
      value = 'uploads/extraItems/$value';
    }

    return '$_cdnBase$value';
  }

  static String fallbackForId(int id) => _idFallbacks[id] ?? '';

  static String resolveForItem({
    required int id,
    required String imageFromApi,
  }) {
    final resolved = resolve(imageFromApi);
    if (resolved.isNotEmpty) return resolved;
    return fallbackForId(id);
  }

  static String fromJson(Map<String, dynamic> json) {
    for (final key in const [
      'image',
      'Image',
      'img',
      'photo',
      'image_url',
      'imageUrl',
      'diploma_img',
      'bk_image',
      'cover',
      'cover_image',
    ]) {
      final value = json[key]?.toString().trim() ?? '';
      if (value.isNotEmpty && value.toLowerCase() != 'null') {
        return resolve(value);
      }
    }

    final images = json['images'] ?? json['Images'];
    if (images is List) {
      for (final entry in images) {
        if (entry is String && entry.trim().isNotEmpty) {
          return resolve(entry);
        }
        if (entry is Map) {
          final nested = fromJson(Map<String, dynamic>.from(entry));
          if (nested.isNotEmpty) return nested;
        }
      }
    }

    final id = int.tryParse(json['id']?.toString() ?? '') ?? 0;
    return fallbackForId(id);
  }
}
