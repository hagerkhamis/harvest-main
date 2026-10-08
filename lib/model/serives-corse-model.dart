class ServicesCourse {
  final String id;
  final String title;
  final String titleEn;
  final String titleAr;
  final List<Service> services;

  ServicesCourse({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.titleAr,
    required this.services,
  });

  factory ServicesCourse.fromJson(Map<String, dynamic> json) {
    final rawServices = _pickServicesList(json);
    final services = <Service>[];
    if (rawServices is List) {
      for (final item in rawServices) {
        if (item is! Map) continue;
        try {
          final service = Service.fromJson(Map<String, dynamic>.from(item));
          if (service.hasDisplayableContent) {
            services.add(service);
          }
        } catch (_) {}
      }
    }

    final titleAr = json['title_ar']?.toString() ?? '';
    final titleEn = json['title_en']?.toString() ?? '';
    final title = json['title']?.toString() ??
        (titleAr.isNotEmpty ? titleAr : titleEn);

    return ServicesCourse(
      id: json['id']?.toString() ?? '',
      title: title,
      titleEn: titleEn,
      titleAr: titleAr,
      services: services,
    );
  }

  static dynamic _pickServicesList(Map<String, dynamic> json) {
    for (final key in const [
      'services',
      'Services',
      'items',
      'offers',
      'Offers',
      'extra_items',
      'extraItems',
    ]) {
      final value = json[key];
      if (value is! List || value.isEmpty) continue;
      final first = value.first;
      if (first is! Map) continue;
      final map = Map<String, dynamic>.from(first);
      if (_looksLikeCatalogItem(map)) return value;
    }

    // Fall back to first non-empty list even if shape is unknown.
    for (final key in const [
      'services',
      'Services',
      'items',
      'offers',
      'Offers',
    ]) {
      final value = json[key];
      if (value is List && value.isNotEmpty) return value;
    }
    return null;
  }

  static bool _looksLikeCatalogItem(Map<String, dynamic> json) {
    final hasTitle = _hasAny(json, const [
      'title',
      'title_ar',
      'title_en',
      'name',
      'name_ar',
      'name_en',
      'service_name',
    ]);
    final hasPrice = _hasAny(json, const [
      'fees',
      'price',
      'cost',
      'amount',
      'old_fees',
    ]);
    final hasImage = _hasAny(json, const [
      'image',
      'img',
      'photo',
      'cover',
      'bk_image',
    ]);

    // Enrollment-like rows usually have student_id and lack catalog fields.
    final looksLikeEnrollment = _hasAny(json, const [
          'student_id',
          'instructor',
          'start_date',
          'end_date',
        ]) &&
        !hasTitle &&
        !hasPrice;

    if (looksLikeEnrollment) return false;
    return hasTitle || hasPrice || hasImage;
  }

  static bool _hasAny(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key]?.toString().trim() ?? '';
      if (value.isNotEmpty && value.toLowerCase() != 'null') return true;
    }
    return false;
  }
}

class Service {
  final int id;
  final String track;
  final String title;
  final String titleEn;
  final String titleAr;
  final String appleId;
  final String desc;
  final String fullDesc;
  final String fullDescAr;
  final String shortdesc;
  final String shortDesc;
  final String shortDescAr;
  final String image;
  final String itemType;
  final String course;
  final String paymentPlan;
  final String fees;
  final String offerTy;

  Service({
    required this.id,
    required this.track,
    required this.title,
    required this.titleEn,
    required this.titleAr,
    required this.appleId,
    required this.desc,
    required this.fullDesc,
    required this.fullDescAr,
    required this.shortdesc,
    required this.shortDesc,
    required this.shortDescAr,
    required this.image,
    required this.itemType,
    required this.course,
    required this.paymentPlan,
    required this.fees,
    required this.offerTy,
  });

  /// Catalog cards need a real name/price/image — not enrollment stubs.
  bool get hasDisplayableContent =>
      title.isNotEmpty ||
      titleAr.isNotEmpty ||
      titleEn.isNotEmpty ||
      fees.isNotEmpty ||
      image.isNotEmpty;

  String get displayTitle {
    if (titleAr.isNotEmpty) return titleAr;
    if (title.isNotEmpty) return title;
    if (titleEn.isNotEmpty) return titleEn;
    return '';
  }

  String displayTitleForLocale(String locale) {
    if (locale.toLowerCase().startsWith('ar')) {
      if (titleAr.isNotEmpty) return titleAr;
      if (title.isNotEmpty) return title;
      if (titleEn.isNotEmpty) return titleEn;
    } else {
      if (titleEn.isNotEmpty) return titleEn;
      if (title.isNotEmpty) return title;
      if (titleAr.isNotEmpty) return titleAr;
    }
    return '';
  }

  factory Service.fromJson(Map<String, dynamic> json) {
    // Do not treat `course` as the service title — enrollment rows often only
    // have course + student_id and would render as blank catalog cards.
    final titleAr = _firstNonEmpty(json, const [
      'title_ar',
      'name_ar',
      'service_name_ar',
    ]);
    final titleEn = _firstNonEmpty(json, const [
      'title_en',
      'name_en',
      'service_name_en',
    ]);
    final title = _firstNonEmpty(json, const [
      'title',
      'name',
      'service_name',
      'item_name',
    ]);
    final fees = _firstNonEmpty(json, const [
      'fees',
      'price',
      'cost',
      'amount',
      'service_fees',
      'final_price',
      'primary_price',
    ]);
    final image = _resolveImage(_firstNonEmpty(json, const [
      'image',
      'img',
      'photo',
      'cover',
      'cover_image',
      'bk_image',
      'thumbnail',
    ]));
    final itemTypeRaw = _firstNonEmpty(json, const ['item_type', 'type']);

    return Service(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      track: _firstNonEmpty(json, const ['track', 'Track']),
      title: title,
      titleEn: titleEn,
      titleAr: titleAr,
      appleId: _firstNonEmpty(json, const ['apple_id', 'appleId']),
      desc: _firstNonEmpty(json, const ['desc', 'description']),
      fullDesc: _firstNonEmpty(json, const ['full_desc', 'full_description']),
      fullDescAr: _firstNonEmpty(json, const ['full_desc_ar']),
      shortdesc: _firstNonEmpty(json, const ['shortdesc', 'short_desc']),
      shortDesc: _firstNonEmpty(json, const ['short_desc', 'shortdesc']),
      shortDescAr: _firstNonEmpty(json, const ['short_desc_ar']),
      image: image,
      itemType: itemTypeRaw.isEmpty ? 'service' : itemTypeRaw,
      course: _firstNonEmpty(json, const ['course', 'course_title']),
      paymentPlan: _firstNonEmpty(json, const ['payment_plan']),
      fees: fees,
      offerTy: _firstNonEmpty(json, const ['offer_ty', 'offer_type']),
    );
  }

  static String _firstNonEmpty(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key]?.toString().trim() ?? '';
      if (value.isNotEmpty && value.toLowerCase() != 'null') return value;
    }
    return '';
  }

  static String _resolveImage(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    final path = value.startsWith('/') ? value.substring(1) : value;
    return 'https://harvestcollege.co.uk/$path';
  }
}