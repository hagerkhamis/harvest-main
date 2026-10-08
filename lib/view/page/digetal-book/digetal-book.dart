import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/utils/book_url_helper.dart';
import 'package:hatvest/core/utils/digital_books_helper.dart';
import 'package:hatvest/view/page/book-web-viewpage/book-web-viewpage.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/model/digita-book-model.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart';
import 'package:hatvest/viewmodel/home-viewmodel.dart';
import 'package:provider/provider.dart';

// Different card themes for each book
const List<_BookTheme> _bookThemes = [
  _BookTheme(
    gradient: [Color(0xFF1A6B3C), Color(0xFF2ECC71)],
    icon: Icons.menu_book_rounded,
    badge: 'Level 1',
  ),
  _BookTheme(
    gradient: [Color(0xFF1565C0), Color(0xFF42A5F5)],
    icon: Icons.auto_stories_rounded,
    badge: 'Level 2',
  ),
  _BookTheme(
    gradient: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
    icon: Icons.library_books_rounded,
    badge: 'Level 3',
  ),
  _BookTheme(
    gradient: [Color(0xFFE65100), Color(0xFFFF8A65)],
    icon: Icons.book_rounded,
    badge: 'Level 4',
  ),
  _BookTheme(
    gradient: [Color(0xFF00695C), Color(0xFF4DB6AC)],
    icon: Icons.bookmarks_rounded,
    badge: 'Level 5',
  ),
  _BookTheme(
    gradient: [Color(0xFFC62828), Color(0xFFEF5350)],
    icon: Icons.import_contacts_rounded,
    badge: 'Level 6',
  ),
  _BookTheme(
    gradient: [Color(0xFF37474F), Color(0xFF78909C)],
    icon: Icons.collections_bookmark_rounded,
    badge: 'Demo',
  ),
];

class _BookTheme {
  final List<Color> gradient;
  final IconData icon;
  final String badge;
  const _BookTheme({required this.gradient, required this.icon, required this.badge});
}

class DigetalBook extends StatefulWidget {
  const DigetalBook({super.key});

  @override
  State<DigetalBook> createState() => _DigetalBookState();
}

class _DigetalBookState extends State<DigetalBook> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadData);
  }

  Future<void> _loadData() async {
    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
    final homeVM = Provider.of<HomeViewModel>(context, listen: false);

    setState(() => _isLoading = true);

    final futures = <Future<void>>[
      profileVM.fetchBooks(),
      profileVM.loadGroups(),
    ];

    if (homeVM.result == null) {
      futures.add(homeVM.getResultData());
    }
    if (profileVM.profile == null) {
      futures.add(profileVM.getProfile());
    }

    await Future.wait(futures);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  _BookTheme _themeForBook(String title, int index) {
    // Try to match by level number or keyword
    for (final theme in _bookThemes) {
      if (title.toLowerCase().contains(theme.badge.toLowerCase())) {
        return theme;
      }
    }
    return _bookThemes[index % _bookThemes.length];
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = Provider.of<ProfileViewModel>(context);
    final homeVM = Provider.of<HomeViewModel>(context);
    final result = homeVM.result;

    final levelNum = DigitalBooksHelper.resolveLevelNumber(
      ptLabel: result?.allData.generalResult.ptResult.ptLabel ?? '',
      profilePtLevel: profileVM.profile?.ptLevel ?? '',
      groupLevels: profileVM.runningGroups.map((g) => g.levels),
      examLevels: result?.allData.generalResult.examResult
              .map((e) => e.level)
              .toList() ??
          const [],
    );

    final displayBooks = DigitalBooksHelper.filterForUserLevel(
      DigitalBooksHelper.mergeBooks(
        resultBook: result?.book,
        runningGroups: profileVM.runningGroups,
        apiBooks: profileVM.books,
      ),
      levelNum: levelNum,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          "page_digital_materials".tr(),
          style: getBoldStyle(color: primaryColor, fontSize: FontSize.s20),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_forward, color: blackColors, size: 30),
          ),
        ],
      ),
      body: Stack(
        children: [
          // خلفية الصفحة
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/picc4.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // محتوى الصفحة
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Builder(builder: (context) {
              if (displayBooks.isEmpty) {
                return Center(child: Text("no_data".tr()));
              }

              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: displayBooks.length,
                itemBuilder: (context, index) {
                  final book = displayBooks[index];
                  final theme = _themeForBook(book.title, index);
                  final isDemo = BookUrlHelper.isDemoTitle(book.title);
                  final subtitle =
                      isDemo ? "try_book".tr() : "view_book".tr();

                  return GestureDetector(
                    onTap: () => _openBook(context, book),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: theme.gradient.first.withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          children: [
                            // ── Colored Header ─────────────────────────
                            Container(
                              height: 130,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: theme.gradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // Background circles
                                  Positioned(
                                    right: -20,
                                    top: -20,
                                    child: Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            Colors.white.withOpacity(0.08),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: -10,
                                    bottom: -30,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            Colors.white.withOpacity(0.06),
                                      ),
                                    ),
                                  ),
                                  // Icon + badge
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          theme.icon,
                                          size: 50,
                                          color:
                                              Colors.white.withOpacity(0.9),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Level badge top-right
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                            color: Colors.white
                                                .withOpacity(0.5)),
                                      ),
                                      child: Text(
                                        book.title,
                                        style: getBoldStyle(
                                          color: Colors.white,
                                          fontSize: FontSize.s12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ── Footer ─────────────────────────────────
                            Container(
                              color: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        subtitle,
                                        style: getMediumStyle(
                                          color: theme.gradient.first,
                                          fontSize: FontSize.s13,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        book.title,
                                        style: getBoldStyle(
                                          color: blackColors,
                                          fontSize: FontSize.s16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _openBook(context, book),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.gradient.first,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      "start".tr(),
                                      style: getBoldStyle(
                                          color: Colors.white,
                                          fontSize: FontSize.s14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
        ],
      ),
    );
  }

  void _openBook(BuildContext context, DigitalBook book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookWebViewPage(url: book.link),
      ),
    );
  }
}
