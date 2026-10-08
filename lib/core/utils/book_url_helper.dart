class BookUrlHelper {
  /// Digital book HTML files are hosted on harvestcollege.co.uk, not sys.
  static String normalize(String link) {
    if (link.isEmpty) return link;

    final uri = Uri.tryParse(link);
    if (uri == null) return link;

    if (uri.host == 'sys.harvestcollege.co.uk' &&
        !uri.path.contains('/api/')) {
      return uri.replace(host: 'harvestcollege.co.uk').toString();
    }

    return link;
  }

  static bool isDemoTitle(String title) {
    final normalized = title.toLowerCase();
    return normalized.contains('demo') || normalized.contains('تجربة');
  }
}
