import 'package:hatvest/core/utils/book_url_helper.dart';
import 'package:hatvest/model/digita-book-model.dart';
import 'package:hatvest/model/group-model.dart';
import 'package:hatvest/model/home-model.dart';

class DigitalBooksHelper {
  static String resolveLevelNumber({
    String ptLabel = '',
    String profilePtLevel = '',
    Iterable<String> groupLevels = const [],
    Iterable<String> examLevels = const [],
  }) {
    for (final source in [
      ptLabel,
      profilePtLevel,
      ...groupLevels,
      ...examLevels,
    ]) {
      if (source.isEmpty) continue;
      final match = RegExp(r'(\d+)').firstMatch(source);
      if (match != null) return match.group(1)!;
    }
    return '';
  }

  static List<DigitalBook> mergeBooks({
    Book? resultBook,
    Iterable<GroupModel> runningGroups = const [],
    Iterable<DigitalBook> apiBooks = const [],
  }) {
    final seen = <String>{};
    final merged = <DigitalBook>[];

    void add(String title, String link) {
      final normalized = BookUrlHelper.normalize(link);
      if (normalized.isEmpty || seen.contains(normalized)) return;
      seen.add(normalized);
      merged.add(DigitalBook(title: title.trim(), link: normalized));
    }

    if (resultBook != null &&
        resultBook.link.isNotEmpty &&
        resultBook.title.isNotEmpty) {
      add(resultBook.title, resultBook.link);
    }

    for (final group in runningGroups) {
      if (group.book.isEmpty) continue;
      final title = group.levels.isNotEmpty
          ? group.levels
          : (group.title.isNotEmpty ? group.title : 'view_book');
      add(title, group.book);
    }

    for (final book in apiBooks) {
      add(book.title, book.link);
    }

    return merged;
  }

  static List<DigitalBook> filterForUserLevel(
    List<DigitalBook> books, {
    required String levelNum,
  }) {
    if (books.isEmpty) return books;

    final nonDemo =
        books.where((b) => !BookUrlHelper.isDemoTitle(b.title)).toList();

    if (levelNum.isEmpty) {
      return nonDemo.isNotEmpty ? nonDemo : books;
    }

    final levelBooks = nonDemo.where((book) {
      final title = book.title.toLowerCase();
      return title.contains('level $levelNum') ||
          title.contains('level$levelNum') ||
          (title.contains(levelNum) && !BookUrlHelper.isDemoTitle(book.title));
    }).toList();

    if (levelBooks.isNotEmpty) return levelBooks;
    if (nonDemo.isNotEmpty) return nonDemo;
    return books;
  }
}
