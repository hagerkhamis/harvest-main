import 'package:hatvest/core/utils/book_url_helper.dart';

class SlideLinkHelper {
  static const String _siteBase = 'https://harvestcollege.co.uk';

  static String resolve(String link) {
    final trimmed = link.trim();
    if (trimmed.isEmpty || trimmed == '#') return '';

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return BookUrlHelper.normalize(trimmed);
    }

    if (trimmed.startsWith('/')) {
      return '$_siteBase$trimmed';
    }

    return '$_siteBase/$trimmed';
  }

  static bool isOpenable(String link) => resolve(link).isNotEmpty;
}
