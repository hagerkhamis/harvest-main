import 'dart:convert';

import 'package:hatvest/model/home-model.dart' as home;
import 'package:hatvest/model/offer_model.dart';

class OffersParser {
  static List<Course> coursesFromResponse(
    dynamic rawData, {
    required bool online,
  }) {
    dynamic data = rawData;
    while (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {
        break;
      }
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final primaryKey = online ? 'online_offers' : 'offline_offers';
      if (map[primaryKey] is List) {
        return groupFlatOffers(map[primaryKey] as List);
      }

      for (final key in ['courses', 'data', 'items', 'offers']) {
        if (map[key] is List && (map[key] as List).isNotEmpty) {
          return groupFlatOffers(map[key] as List);
        }
      }

      for (final value in map.values) {
        if (value is List && value.isNotEmpty) {
          final parsed = groupFlatOffers(value);
          if (parsed.any((c) => c.offers.isNotEmpty)) return parsed;
        }
      }
    }

    if (data is List) {
      return groupFlatOffers(data);
    }

    return [];
  }

  static List<Course> groupFlatOffers(List<dynamic> list) {
    if (list.isEmpty) return [];

    final first = list.first;
    if (first is Map && first.containsKey('offers')) {
      return list
          .whereType<Map>()
          .map((json) => Course.fromJson(Map<String, dynamic>.from(json)))
          .where((course) => course.offers.isNotEmpty)
          .toList();
    }

    final offers = list
        .whereType<Map>()
        .map((json) => Offer.fromJson(Map<String, dynamic>.from(json)))
        .toList();

    if (offers.isEmpty) return [];

    final grouped = <String, List<Offer>>{};
    for (final offer in offers) {
      final key = _courseKey(offer);
      grouped.putIfAbsent(key, () => []).add(offer);
    }

    return grouped.entries
        .map(
          (entry) => Course(
            id: entry.key.hashCode.toString(),
            title: entry.key,
            offers: entry.value,
          ),
        )
        .toList();
  }

  static List<Course> coursesFromHomeOffers(List<home.Offer> offers) {
    if (offers.isEmpty) return [];

    final grouped = <String, List<Offer>>{};
    for (final homeOffer in offers) {
      final offer = Offer(
        id: homeOffer.id,
        image: homeOffer.image,
        courseTitle: homeOffer.courseTitle,
        title: homeOffer.title,
        titleEn: homeOffer.titleEn,
        titleAr: homeOffer.titleAr,
        itemType: homeOffer.itemType.isNotEmpty ? homeOffer.itemType : 'course',
        fees: homeOffer.fees,
        oldFees: homeOffer.oldFees,
        desc: '',
      );
      final key = _courseKey(offer);
      grouped.putIfAbsent(key, () => []).add(offer);
    }

    return grouped.entries
        .map(
          (entry) => Course(
            id: entry.key.hashCode.toString(),
            title: entry.key,
            offers: entry.value,
          ),
        )
        .toList();
  }

  static String _courseKey(Offer offer) {
    if (offer.courseTitle.trim().isNotEmpty) return offer.courseTitle.trim();
    if (offer.track.trim().isNotEmpty) return offer.track.trim();
    if (offer.title.trim().isNotEmpty) return offer.title.trim();
    return 'Offers';
  }
}
