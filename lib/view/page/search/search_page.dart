import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/theme/app_colors.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/model/offer_model.dart';
import 'package:hatvest/view/page/deoplom-info/deoplom-info.dart';
import 'package:hatvest/viewmodel/serives.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Offer> _results = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<CourseViewModel>(context, listen: false);
      if (vm.courses.isEmpty) {
        vm.fetchCoursesOflien();
        vm.fetchCoursesOnlien();
      }
    });
  }

  void _onSearch(String query, List<Course> courses) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }

    final allOffers = courses.expand((c) => c.offers).toList();
    setState(() {
      _hasSearched = true;
      _results = allOffers.where((o) {
        return o.title.toLowerCase().contains(q) ||
            o.titleAr.toLowerCase().contains(q) ||
            o.titleEn.toLowerCase().contains(q) ||
            o.courseTitle.toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Consumer<CourseViewModel>(
          builder: (context, vm, _) {
            return TextField(
              controller: _searchController,
              autofocus: true,
              textAlign: TextAlign.right,
              style: getMediumStyle(color: context.textPrimary, fontSize: FontSize.s16),
              decoration: InputDecoration(
                hintText: 'ابحث عن كورس أو عرض...',
                hintStyle: getMediumStyle(color: Colors.grey, fontSize: FontSize.s15),
                border: InputBorder.none,
                suffixIcon: Icon(Icons.search, color: primaryColor),
              ),
              onChanged: (q) => _onSearch(q, vm.courses),
            );
          },
        ),
      ),
      body: Consumer<CourseViewModel>(
        builder: (context, vm, _) {
          if (!_hasSearched) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'ابحث عن كورس أو عرض',
                    style: getMediumStyle(color: Colors.grey, fontSize: FontSize.s16),
                  ),
                ],
              ),
            );
          }

          if (_results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد نتائج',
                    style: getMediumStyle(color: Colors.grey, fontSize: FontSize.s16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final offer = _results[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DeoplomInfo(offerId: int.tryParse(offer.id) ?? 0),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        child: offer.image.isNotEmpty
                            ? Image.network(
                                offer.image,
                                width: 90,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 90,
                                  height: 80,
                                  color: primaryColor.withOpacity(0.2),
                                  child: Icon(Icons.school, color: primaryColor),
                                ),
                              )
                            : Container(
                                width: 90,
                                height: 80,
                                color: primaryColor.withOpacity(0.2),
                                child: Icon(Icons.school, color: primaryColor),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                offer.courseTitle,
                                style: getBoldStyle(color: context.textPrimary, fontSize: FontSize.s15),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                offer.title,
                                style: getMediumStyle(color: Colors.grey, fontSize: FontSize.s13),
                                textAlign: TextAlign.right,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${offer.fees} ج.م",
                                style: getBoldStyle(color: primaryColor, fontSize: FontSize.s15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
