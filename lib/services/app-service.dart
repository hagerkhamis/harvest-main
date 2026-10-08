import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/constants/api_constant.dart';
import 'package:hatvest/interceptors/dio_client.dart';
import 'package:hatvest/core/utils/branch_location_helper.dart';
import 'package:hatvest/model/BranchModel.dart' show MainBranch;
import 'package:hatvest/model/certificate-model.dart';
import 'package:hatvest/model/certificate_response.dart'
    show CertificateResponse, Certificate;
import 'package:hatvest/model/deal_model.dart';
import 'package:hatvest/model/exam-rusel.dart' show ExamRuseltModel;
import 'package:hatvest/model/get-technicaltracker-model.dart'
    show ExamSkill, PtSkills, PtSkillsTex;
import 'package:hatvest/core/utils/offers_parser.dart';
import 'package:hatvest/model/digita-book-model.dart';
import 'package:hatvest/model/group-model.dart';
import 'package:hatvest/model/home-model.dart';
import 'package:hatvest/model/offer-view-model.dart';
import 'package:hatvest/model/offer_model.dart';
import 'package:hatvest/model/profile-model.dart';
import 'package:hatvest/model/running-group.dart';
import 'package:hatvest/model/serives-corse-model.dart' show ServicesCourse;
import 'package:hatvest/model/serives-view-model.dart'
    show ServicesDetailsModel;
import 'package:hatvest/model/vocab-ruselt.dart' show AdultResult;

class ProfileService {
  final Dio _dio = dioClient;

  Future<LeadModel> fetchProfile() async {
    try {
      final response = await _dio.post(
        ApiConstants.myProfile,
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );

      dynamic rawData = response.data;
      while (rawData is String) {
        try {
          rawData = jsonDecode(rawData);
        } catch (_) {
          break;
        }
      }

      if (rawData is Map && rawData.containsKey('lead')) {
        return LeadModel.fromJson(Map<String, dynamic>.from(rawData['lead']));
      } else if (rawData is List && rawData.isNotEmpty && rawData[0] is Map && rawData[0].containsKey('lead')) {
        return LeadModel.fromJson(Map<String, dynamic>.from(rawData[0]['lead']));
      } else {
        throw Exception("Unexpected profile data format");
      }
    } on DioException catch (e) {
      throw Exception("Error: ${e.response?.data}");
    }
  }

//
  Future<ResultResponse?> fetchResults() async {
    try {
      final response = await _dio.get(
        ApiConstants.offers,
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );

      dynamic rawData = response.data;
      while (rawData is String) {
        try {
          rawData = jsonDecode(rawData);
        } catch (_) {
          break;
        }
      }

      if (rawData is Map) {
        return ResultResponse.fromJson(Map<String, dynamic>.from(rawData));
      } else if (rawData is List && rawData.isNotEmpty) {
        return ResultResponse.fromJson(Map<String, dynamic>.from(rawData[0]));
      } else {
        print('Unexpected results format: $rawData');
        return null;
      }
    } catch (e) {
      print('Error fetching results: $e');
      return null;
    }
  }
  //

  Future<OfferDetailsModel> fetchOfferDetailsById(int id) async {
    try {
      final response = await _dio.get(
        "${ApiConstants.baseUrl}${ApiConstants.showoffers}",
        queryParameters: {'id': id},
        options: Options(
          headers: {
            'requiresToken': true,
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        return OfferDetailsModel.fromJson(response.data);
      } else if (response.statusCode == 404) {
        throw Exception("لم يتم العثور على تفاصيل هذا العرض");
      } else {
        throw Exception("حدث خطأ أثناء تحميل العرض");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception("لم يتم العثور على تفاصيل هذا العرض");
      }
      throw Exception("حدث خطأ في الاتصال بالسيرفر");
    } catch (e) {
      rethrow;
    }
  }

  //getServiesDetails
  Future<ServicesDetailsModel> fetchServiesDetailsById(int id) async {
    final response = await _dio.get(
      ApiConstants.showservices,

      // 'https://testsys.harvestcollege.co.uk//showservices',
      queryParameters: {'id': id},
    );

    dynamic rawData = response.data;
    if (rawData is String) {
      rawData = jsonDecode(rawData);
    }

    if (rawData is Map) {
      return ServicesDetailsModel.fromJson(rawData as Map<String, dynamic>);
    } else if (rawData is List && rawData.isNotEmpty) {
      return ServicesDetailsModel.fromJson(rawData[0] as Map<String, dynamic>);
    } else {
      throw Exception("Unexpected service details format");
    }
  }

  //
  Future<Map<String, List<GroupModel>>> fetchGroups() async {
    try {
      final response = await _dio.get(
        ApiConstants.getgroups,
        options: Options(
          headers: {
            'requiresToken': true,
          },
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      dynamic rawData = response.data;
      while (rawData is String) {
        try {
          rawData = jsonDecode(rawData);
        } catch (_) {
          break;
        }
      }

      Map<String, dynamic> data;
      if (rawData is Map) {
        data = rawData as Map<String, dynamic>;
      } else if (rawData is List && rawData.isNotEmpty && rawData[0] is Map) {
        data = rawData[0] as Map<String, dynamic>;
      } else {
        return {'running': [], 'complete': [], 'upcoming': []};
      }

      return {
        'running': (data['groupsrunning'] as List? ?? [])
            .map((e) => GroupModel.fromJson(e))
            .toList(),
        'complete': (data['groupscomplete'] as List? ?? [])
            .map((e) => GroupModel.fromJson(e))
            .toList(),
        'upcoming': (data['groupsupcomming'] as List? ?? [])
            .map((e) => GroupModel.fromJson(e))
            .toList(),
      };
    } on DioException catch (e) {
      debugPrint("❌ Dio Error: ${e.type}");
      debugPrint("❌ Message: ${e.message}");

      if (e.response != null) {
        debugPrint("❌ Status: ${e.response?.statusCode}");
        debugPrint("❌ Data: ${e.response?.data}");
      }

      throw Exception("Failed to fetch groups");
    } catch (e) {
      debugPrint("❌ Unknown error: $e");
      throw Exception("Unexpected error occurred");
    }
  }

  // Future<Map<String, List<GroupModel>>> fetchGroups() async {
  //   final response = await _dio.get(
  //     "${ApiConstants.baseUrl}${ApiConstants.getgroups}",

  //     // 'https://testsys.harvestcollege.co.uk//getgroups',
  //     options: Options(
  //       headers: {
  //         'requiresToken': true,
  //       },
  //     ),
  //   );

  //   final data = response.data;

  //   List<GroupModel> running = (data['groupsrunning'] as List)
  //       .map((e) => GroupModel.fromJson(e))
  //       .toList();

  //   List<GroupModel> complete = (data['groupscomplete'] as List)
  //       .map((e) => GroupModel.fromJson(e))
  //       .toList();

  //   List<GroupModel> upcoming = (data['groupsupcomming'] as List)
  //       .map((e) => GroupModel.fromJson(e))
  //       .toList();

  //   return {
  //     'complete': complete,
  //     'running': running,
  //     'upcoming': upcoming,
  //   };
  // }

  //

  Future<List<Course>> fetchCoursesOnline() async {
    try {
      final response = await _dio.get(
        ApiConstants.offers,
        options: Options(
          headers: {
            'requiresToken': true,
            'sendType': 'online',
          },
        ),
      );

      return OffersParser.coursesFromResponse(response.data, online: true);
    } catch (e) {
      debugPrint('Failed to load online courses: $e');
      return [];
    }
  }

  //
  Future<List<Course>> fetchCoursesOfline() async {
    try {
      final response = await _dio.get(
        ApiConstants.offers,
        options: Options(
          headers: {
            'requiresToken': true,
            'sendType': 'offline',
          },
        ),
      );

      return OffersParser.coursesFromResponse(response.data, online: false);
    } catch (e) {
      debugPrint('Failed to load offline courses: $e');
      return [];
    }
  }

  //
  Future<List<ServicesCourse>> fetchServices() async {
    try {
      final response = await _dio.get(
        ApiConstants.services,
        options: Options(
          headers: {
            'requiresToken': true,
          },
          validateStatus: (status) => status != null && status < 600,
        ),
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 500) {
        debugPrint('Services API server error: $statusCode ${response.data}');
        throw Exception('Server Error $statusCode');
      }
      if (statusCode >= 400) {
        debugPrint('Services API failed: $statusCode');
        return [];
      }

      dynamic rawData = response.data;
      while (rawData is String) {
        try {
          rawData = jsonDecode(rawData);
        } catch (_) {
          break;
        }
      }

      final list = _extractServicesCourses(rawData);
      final courses = list
          .whereType<Map>()
          .map((e) => ServicesCourse.fromJson(Map<String, dynamic>.from(e)))
          .where((course) => course.title.isNotEmpty || course.services.isNotEmpty)
          .toList();

      if (list.isNotEmpty && list.first is Map) {
        final firstCourse = Map<String, dynamic>.from(list.first as Map);
        final nested = firstCourse['services'] ??
            firstCourse['Services'] ??
            firstCourse['items'] ??
            firstCourse['offers'];
        debugPrint('Services course keys: ${firstCourse.keys.toList()}');
        if (nested is List && nested.isNotEmpty && nested.first is Map) {
          final firstItem = Map<String, dynamic>.from(nested.first as Map);
          debugPrint('Services item keys: ${firstItem.keys.toList()}');
          debugPrint('Services first item sample: $firstItem');
        }
      }
      if (courses.isNotEmpty) {
        final sample = courses.first.services.isNotEmpty
            ? courses.first.services.first
            : null;
        debugPrint(
          'Services parsed: courses=${courses.length}, '
          'firstCourse=${courses.first.title}, '
          'services=${courses.first.services.length}, '
          'sampleTitle=${sample?.displayTitle}, '
          'sampleFees=${sample?.fees}, '
          'sampleImage=${sample?.image}',
        );
      }
      return courses;
    } catch (e) {
      debugPrint('Failed to load services: $e');
      rethrow;
    }
  }

  List _extractServicesCourses(dynamic rawData) {
    if (rawData is List) return rawData;
    if (rawData is! Map) return const [];

    final map = Map<String, dynamic>.from(rawData);
    for (final key in [
      'courses',
      'Courses',
      'services',
      'Services',
      'data',
      'items',
      'result',
    ]) {
      final value = map[key];
      if (value is List) return value;
    }

    for (final value in map.values) {
      if (value is List && value.isNotEmpty && value.first is Map) {
        return value;
      }
    }
    return const [];
  }

  //
  Future<void> sendConfirmation({
    required int confirmation,
    required String groupId,
  }) async {
    try {
      await _dio.post(
        "${ApiConstants.baseUrl}${ApiConstants.setconfirmation}",

        // "https://testsys.harvestcollege.co.uk//setconfirmation",
        data: {
          "Confirmation": confirmation,
          "group_id": groupId,
        },
      );
    } catch (e) {
      throw Exception("فشل في إرسال التأكيد");
    }
  }

  //
  Future<Response> joinGroup({
    required String groupId,
  }) async {
    try {
      final response = await _dio.post(
        "${ApiConstants.baseUrl}${ApiConstants.addStudents}",

        // "https://testsys.harvestcollege.co.uk//groups/add-students",
        data: {
          "group_id": groupId,
        },
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );
      return response;
    } catch (e) {
      throw Exception("فشل في إرسال التأكيد");
    }
  }

  //
  Future<List<DigitalBook>> fetchBooks() async {
    final response = await _dio.get(
      ApiConstants.getdigitalbook,
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );

    dynamic rawData = response.data;
    while (rawData is String) {
      try {
        rawData = jsonDecode(rawData);
      } catch (_) {
        break;
      }
    }

    if (rawData is Map && rawData['Book'] is List) {
      final List data = rawData['Book'];
      return data.where((e) => e is Map).map((e) => DigitalBook.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }
    return [];
  }

  //
  Future<Map<String, dynamic>> fetchTrackerData() async {
    final response = await _dio.get(
      ApiConstants.gettechnicaltracker,
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );

    dynamic rawData = response.data;
    while (rawData is String) {
      try {
        rawData = jsonDecode(rawData);
      } catch (_) {
        break;
      }
    }

    if (rawData is Map) {
      final allData = rawData['all-data'] ?? rawData['all_data'];
      if (allData is Map) {
        final skillsResult = allData['Skills_Result'] ?? allData['skills_result'];
        if (skillsResult is Map) {
          final ptSkillsRaw = skillsResult['PtSkills'] ?? skillsResult['pt_skills'];
          final ptSkills = ptSkillsRaw != null && ptSkillsRaw is Map
              ? PtSkillsTex.fromJson(Map<String, dynamic>.from(ptSkillsRaw))
              : null;

          final examSkillsRaw = skillsResult['ExamSkills'] ?? skillsResult['exam_skills'];
          final examSkills = (examSkillsRaw is List)
              ? (examSkillsRaw as List)
                  .where((e) => e is Map)
                  .map((e) => ExamSkill.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()
              : <ExamSkill>[];

          return {
            'ptSkills': ptSkills,
            'examSkills': examSkills,
          };
        }
      }
    }
    return {'ptSkills': null, 'examSkills': []};
  }

  //
  Future<AdultResult?> getAdultResult(int applicationId) async {
    try {
      final response = await _dio.get(
        ApiConstants.getAdultResult,
        queryParameters: {'applicationId': applicationId},
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );

      if (response.statusCode == 200) {
        dynamic rawData = response.data;
        while (rawData is String) {
          try {
            rawData = jsonDecode(rawData);
          } catch (_) {
            break;
          }
        }
        if (rawData is Map && rawData['result'] != null && rawData['result'] is Map) {
          return AdultResult.fromJson(Map<String, dynamic>.from(rawData['result']));
        }
      }
      return null;
    } catch (e) {
      print("Error fetching adult result: $e");
      return null;
    }
  }

  //

  Future<AdultResult?> getKidsPtResult(int applicationId) async {
    try {
      final response = await _dio.get(
        "${ApiConstants.baseUrl}${ApiConstants.getKidsResult}",

        // 'https://testsys.harvestcollege.co.uk//get_kids_result',
        queryParameters: {'applicationId': applicationId},
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );

      if (response.statusCode == 200) {
        return AdultResult.fromJson(response.data['result']);
      }
      return null;
    } catch (e) {
      print("Error fetching adult result: $e");
      return null;
    }
  }

  //
  Future<ExamRuseltModel?> getExamResult(int applicationId) async {
    try {
      final response = await _dio.get(
        "${ApiConstants.baseUrl}${ApiConstants.getExamResult}",

        // 'https://testsys.harvestcollege.co.uk//get_exam_result',
        queryParameters: {'applicationId': applicationId},
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );

      if (response.statusCode == 200 && response.data['Exam_result'] != null) {
        return ExamRuseltModel.fromJson(response.data['Exam_result']);
      }

      return null;
    } catch (e) {
      print("Error fetching exam result: $e");
      return null;
    }
  }

  // Future<ExamRuseltModel?> getExamResult(int applicationId) async {
  //   try {
  //     final response = await _dio.post(
  //       'https://testsys.harvestcollege.co.uk//get_exam_result',
  //       queryParameters: {'applicationId': applicationId},
  //       options: Options(
  //         headers: {
  //           'requiresToken': true,
  //         },
  //       ),
  //     );

  //     if (response.statusCode == 200) {
  //       return ExamRuseltModel.fromJson(response.data['result']);
  //     }
  //     return null;
  //   } catch (e) {
  //     print("Error fetching adult result: $e");
  //     return null;
  //   }
  // }

  //
  Future<CertificateModel?> fetchExtraItem(int id) async {
    try {
      final response = await _dio.get(
        ApiConstants.showitem,
        queryParameters: {'id': id},
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );

      dynamic rawData = response.data;
      while (rawData is String) {
        try {
          rawData = jsonDecode(rawData);
        } catch (_) {
          break;
        }
      }

      if (rawData is Map && rawData['extra_item'] != null && rawData['extra_item'] is Map) {
        return CertificateModel.fromJson(
          Map<String, dynamic>.from(rawData['extra_item']),
        );
      }
      return null;
    } catch (e) {
      print("Error fetching extra item: $e");
      return null;
    }
  }

  //
  Future<CertificateResponse?> fetchCertificates() async {
    try {
      final response = await _dio.get(
        ApiConstants.certificates,
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );

      dynamic rawData = response.data;
      while (rawData is String) {
        try {
          rawData = jsonDecode(rawData);
        } catch (_) {
          break;
        }
      }

      if (rawData is Map) {
        return CertificateResponse.fromJson(Map<String, dynamic>.from(rawData));
      }
      return null;
    } catch (e) {
      print("Error fetching certificates: $e");
      return null;
    }
  }

  //
  Future<Map<String, dynamic>> fetchInquiries() async {
    try {
      final response = await _dio.get(
        ApiConstants.getrequested,
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw Exception("Failed to fetch inquiries: $e");
    }
  }

  //
  Future<Map<String, dynamic>> fetchComplain() async {
    try {
      final response = await _dio.get(
        ApiConstants.getcomplain,
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw Exception("Failed to fetch inquiries: $e");
    }
  }

  //
  Future<Response> sendInquiry({
    required int labelId,
    required String message,
    File? file,
    String? fileName,
  }) async {
    final Map<String, dynamic> map = {
      'label_type_id': labelId,
      'customer_notes': message,
    };

    if (file != null && fileName != null) {
      map['image'] = await MultipartFile.fromFile(file.path, filename: fileName);
      map['display_name'] = fileName;
    }

    FormData formData = FormData.fromMap(map);

    try {
      final response = await _dio.post(
        ApiConstants.addrequest,

        // "https://testsys.harvestcollege.co.uk//addrequest",
        data: formData,
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );
      return response;
    } catch (e) {
      print('Send inquiry error: $e');
      rethrow;
    }
  }

  //
  Future<Response> sendComplain({
    required int labelId,
    required String message,
    File? file, // make nullable
    required String displayName,
  }) async {
    final formData = FormData.fromMap({
      'label_type_id': labelId,
      'customer_notes': message,
      'display_name': displayName,
      'image': "",
      // 'image': file != null
      //     ? await MultipartFile.fromFile(
      //         file.path,
      //         filename: file.path.split('/').last,
      //       )
      //     : "", // send empty string if no file
    });

    try {
      final response = await _dio.post(
        ApiConstants.addcomplain,

        // "https://testsys.harvestcollege.co.uk//addcomplain",
        data: formData,
        options: Options(
          headers: {
            'requiresToken': true,
            'Accept': 'application/json',
          },
        ),
      );
      return response;
    } catch (e) {
      print('Send inquiry error: $e');
      rethrow;
    }
  }

  // Future<Response> sendComplain({
  //   required int labelId,
  //   required String message,
  //   required File file,
  //   required String fileName,
  // }) async {
  //   FormData formData = FormData.fromMap({
  //     'label_type_id': labelId,
  //     'customer_notes': message,
  //     'image': await MultipartFile.fromFile(file.path, filename: fileName),
  //     'display_name': fileName,
  //   });

  //   try {
  //     final response = await _dio.post(
  //       "https://testsys.harvestcollege.co.uk//addcomplain",
  //       data: formData,
  //       options: Options(
  //         headers: {
  //           'requiresToken': true,
  //           'Accept': 'application/json',
  //           'Content-Type': 'application/json',
  //           'User-Agent': 'PostmanRuntime/7.32.2',
  //         },
  //       ),
  //     );
  //     return response;
  //   } catch (e) {
  //     print('Send inquiry error: $e');
  //     rethrow;
  //   }
  // }

//
  Future<List<MainBranch>> getBranches() async {
    try {
      final response = await _dio.get(
        ApiConstants.getBranches,
      );
      dynamic rawData = response.data;
      while (rawData is String) {
        try {
          rawData = jsonDecode(rawData);
        } catch (_) {
          break;
        }
      }
      if (rawData is Map && rawData['Branches'] is List) {
        final List branchesJson = rawData['Branches'];
        final parsed = branchesJson
            .where((e) => e is Map)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .where(
              (json) => BranchLocationHelper.isValidBranch(
                name: json['name']?.toString() ?? '',
                nameAr: json['name_ar']?.toString() ?? '',
                phone: json['phone']?.toString() ?? '',
              ),
            )
            .toList();

        final sharedLinks = BranchLocationHelper.sharedGoogleLinkCounts(
          parsed.map((json) => json['google_link']?.toString() ?? ''),
        );

        return parsed
            .map(
              (json) => MainBranch.fromJson(
                json,
                googleLinkIsShared: BranchLocationHelper.isSharedGoogleLink(
                  json['google_link']?.toString() ?? '',
                  sharedLinks,
                ),
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print("Error loading branches: $e");
      return [];
    }
  }

  //
  Future<bool> sendContactMessage(String name, String email, String phone, String message) async {
    try {
      final response = await _dio.post(
        ApiConstants.postcontact,
        data: {
          "name": name,
          "email": email,
          "phone": phone,
          "message": message,
        },
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error sending message: $e");
      return false;
    }
  }

  //
  Future<List<RunningGroup>> fetchRunningGroups(int trackId) async {
    try {
      final response = await _dio.get(
        ApiConstants.getRunningGroups,

        // 'https://testsys.harvestcollege.co.uk//getRunningGroups',
        queryParameters: {'track_id': trackId},
        options: Options(
          headers: {
            'requiresToken': true,
          },
        ),
      );

      final data = RunningGroupResponse.fromJson(response.data);
      return data.groups;
    } catch (e) {
      throw Exception("Failed to fetch running groups: $e");
    }
  }

  Future<Map<String, dynamic>> fetchAppSettings() async {
    final response = await _dio.get(
      ApiConstants.getAppVersion,
    );
    final dynamic rawData = response.data;
    return rawData is String ? jsonDecode(rawData) : rawData;
  }

  //
  Future<SlidesResponse> fetchDeals() async {
    final response = await _dio.get(
      ApiConstants.getslideshow,
    );
    if (response.statusCode == 200) {
      return SlidesResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to load slides');
    }
  }

  //...
  Future<Map<String, dynamic>> fetchTerms() async {
    final response = await _dio.get(
      ApiConstants.terms,
      options: Options(headers: {'requiresToken': true}),
    );
    dynamic rawData = response.data;
    while (rawData is String) {
      try { rawData = jsonDecode(rawData); } catch (_) { break; }
    }
    if (rawData is Map) return Map<String, dynamic>.from(rawData);
    if (rawData is List && rawData.isNotEmpty && rawData[0] is Map) {
      return Map<String, dynamic>.from(rawData[0] as Map);
    }
    return {};
  }

  Future<String> fetchAppTermsById(int id) async {
    try {
      final response = await _dio.get(
        ApiConstants.appTerms,
        queryParameters: {'id': id},
        options: Options(headers: {'requiresToken': true}),
      );
      dynamic rawData = response.data;
      while (rawData is String) {
        try { rawData = jsonDecode(rawData); } catch (_) { break; }
      }
      if (rawData is Map && rawData['page'] != null) {
        return rawData['page']['content']?.toString() ?? '';
      }
    } catch (e) {
      debugPrint('fetchAppTermsById error: $e');
    }
    return '';
  }

  Future<Map<String, dynamic>> fetchAboutApp() async {
    final response = await _dio.get(
      ApiConstants.aboutApp,
      options: Options(headers: {'requiresToken': true}),
    );
    dynamic rawData = response.data;
    while (rawData is String) {
      try { rawData = jsonDecode(rawData); } catch (_) { break; }
    }
    if (rawData is Map) return Map<String, dynamic>.from(rawData);
    return {};
  }

  Future<bool> approveTerms() async {
    final response = await _dio.post(
      ApiConstants.approve,
      // 'https://testsys.harvestcollege.co.uk/api/terms/approve',
      queryParameters: {'approve': 1},
      options: Options(
        headers: {
          'requiresToken': true,
        },
      ),
    );
    return response.statusCode == 200;
  }
}
