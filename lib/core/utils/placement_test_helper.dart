import 'dart:async';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/utils/display_localization.dart';
import 'package:hatvest/main.dart' show navigatorKey;
import 'package:hatvest/model/home-model.dart';
import 'package:hatvest/model/placement_test_action_model.dart';
import 'package:hatvest/model/profile-model.dart';
import 'package:hatvest/services/placement_test_service.dart';
import 'package:hatvest/view/page/adult-result/adult-result.dart';
import 'package:hatvest/view/page/kids-pt-result/kids-pt-result.dart';
import 'package:hatvest/view/page/placement-level/placement_level_status_page.dart';
import 'package:hatvest/view/page/select-level/select-level.dart';
import 'package:hatvest/viewmodel/app-viewmodel.dart';
import 'package:hatvest/viewmodel/home-viewmodel.dart';
import 'package:provider/provider.dart';

class PlacementTestHelper {
  static final PlacementTestService _service = PlacementTestService();
  static bool _isHandlingTap = false;
  static OverlayEntry? _loadingEntry;

  static const Duration _requestTimeout = Duration(seconds: 15);

  static bool isLimitedAccessUser(String? type) {
    if (type == null || type.isEmpty) return false;
    final normalized = type.toLowerCase().trim();
    return normalized.contains('limited access') ||
        normalized == 'placement test' ||
        normalized == 'placement test / limited access';
  }

  static bool isApplicationFinished(AdultPtApplication? application) {
    if (application == null) return false;
    return (int.tryParse(application.finish) ?? 0) != 0;
  }

  static Future<void> handlePlacementTestTap(BuildContext context) async {
    if (_isHandlingTap) return;
    _isHandlingTap = true;

    try {
      _showLoadingOverlay();

      final response = await _service
          .fetchPlacementTestAction()
          .timeout(_requestTimeout);

      _hideLoadingOverlay();

      final navContext = navigatorKey.currentContext ?? context;
      if (!navContext.mounted) return;
      await handlePlacementTestAction(navContext, response);
    } on TimeoutException {
      _hideLoadingOverlay();
      await _failSafeOpen(context);
    } on DioException {
      _hideLoadingOverlay();
      await _failSafeOpen(context);
    } catch (_) {
      _hideLoadingOverlay();
      await _failSafeOpen(context);
    } finally {
      _hideLoadingOverlay();
      _isHandlingTap = false;
    }
  }

  static Future<void> _failSafeOpen(BuildContext context) async {
    final navContext = navigatorKey.currentContext ?? context;
    if (!navContext.mounted) return;
    try {
      await _handlePlacementTestFallback(navContext)
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      if (!navContext.mounted) return;
      _openSelectLevel(navContext);
    }
  }

  static Future<void> handlePlacementTestAction(
    BuildContext context,
    PlacementTestActionResponse data, {
    bool replaceCurrentRoute = false,
  }) async {
    final action = data.action.toLowerCase().trim();
    final appId = data.resolvedApplicationId;

    if (action == 'show_adult_result' && appId != null) {
      _navigateTo(
        context,
        AdultRuselt(applicationId: appId),
        replace: replaceCurrentRoute,
      );
      return;
    }

    if (action == 'show_kids_result' && appId != null) {
      _navigateTo(
        context,
        kidsPtRuselt(applicationId: appId),
        replace: replaceCurrentRoute,
      );
      return;
    }

    if (action == 'show_current_level' ||
        action == 'current_level' ||
        action == 'show_level') {
      _openCurrentLevelPage(
        context,
        _localizedLevel(data.levelLabel),
        replace: replaceCurrentRoute,
      );
      return;
    }

    if (action == 'show_last_passed_level' ||
        action == 'show_last_level' ||
        action == 'last_passed_level') {
      _openLastPassedFromApi(context, data, replace: replaceCurrentRoute);
      return;
    }

    if (action.contains('adult_result') && appId != null) {
      _navigateTo(
        context,
        AdultRuselt(applicationId: appId),
        replace: replaceCurrentRoute,
      );
      return;
    }

    if (action.contains('kids_result') && appId != null) {
      _navigateTo(
        context,
        kidsPtRuselt(applicationId: appId),
        replace: replaceCurrentRoute,
      );
      return;
    }

    if (action == 'select_level' ||
        action == 'start_placement_test' ||
        action == 'start_exam' ||
        action.isEmpty) {
      if (!replaceCurrentRoute) {
        _openSelectLevel(context, replace: replaceCurrentRoute);
      }
      return;
    }

    if (data.adultPtApplication?.isFinished == true && appId != null) {
      _navigateTo(
        context,
        AdultRuselt(applicationId: appId),
        replace: replaceCurrentRoute,
      );
      return;
    }

    if (data.kidsPtApplication?.isFinished == true && appId != null) {
      _navigateTo(
        context,
        kidsPtRuselt(applicationId: appId),
        replace: replaceCurrentRoute,
      );
      return;
    }

    if (data.levelLabel.isNotEmpty) {
      _openCurrentLevelPage(
        context,
        _localizedLevel(data.levelLabel),
        replace: replaceCurrentRoute,
      );
      return;
    }

    if (!context.mounted) return;
    await _handlePlacementTestFallback(
      context,
      replaceCurrentRoute: replaceCurrentRoute,
    );
  }

  static Future<void> _handlePlacementTestFallback(
    BuildContext context, {
    bool replaceCurrentRoute = false,
  }) async {
    final profileVM = context.read<ProfileViewModel>();
    final homeVM = context.read<HomeViewModel>();

    if (profileVM.profile == null) {
      await profileVM.getProfile().timeout(const Duration(seconds: 8));
    }
    if (homeVM.result == null) {
      await homeVM.getResultData().timeout(const Duration(seconds: 8));
    }

    final profile = profileVM.profile;
    if (profile != null && isLimitedAccessUser(profile.type)) {
      if (!context.mounted) return;
      await handleLimitedAccessUser(
        context,
        profile,
        homeVM.result,
        replaceCurrentRoute: replaceCurrentRoute,
      );
      return;
    }

    if (!context.mounted) return;
    _openSelectLevel(context, replace: replaceCurrentRoute);
  }

  static Future<void> handleLimitedAccessUser(
    BuildContext context,
    LeadModel profile,
    ResultResponse? result, {
    bool replaceCurrentRoute = false,
  }) async {
    if (isApplicationFinished(profile.adultPtApplication)) {
      if (!context.mounted) return;
      _navigateTo(
        context,
        AdultRuselt(applicationId: profile.adultPtApplication!.id),
        replace: replaceCurrentRoute,
      );
      return;
    }

    if (isApplicationFinished(profile.kidsPtApplication)) {
      if (!context.mounted) return;
      _navigateTo(
        context,
        kidsPtRuselt(applicationId: profile.kidsPtApplication!.id),
        replace: replaceCurrentRoute,
      );
      return;
    }

    final ptLabel = result?.allData.generalResult.ptResult.ptLabel ?? '';
    if (profile.ptLevel.isNotEmpty) {
      _openCurrentLevelPage(
        context,
        _localizedLevel(profile.ptLevel),
        replace: replaceCurrentRoute,
      );
      return;
    }

    if (ptLabel.isNotEmpty) {
      _openCurrentLevelPage(
        context,
        _localizedLevel(ptLabel),
        replace: replaceCurrentRoute,
      );
      return;
    }

    final examResults = result?.allData.generalResult.examResult ?? [];
    if (examResults.isNotEmpty) {
      _openLastPassedLevelPage(
        context,
        examResults.last,
        replace: replaceCurrentRoute,
      );
      return;
    }

    if (!context.mounted) return;
    _openCurrentLevelPage(
      context,
      'placement_level_unknown'.tr(),
      replace: replaceCurrentRoute,
    );
  }

  static void _openLastPassedFromApi(
    BuildContext context,
    PlacementTestActionResponse data, {
    bool replace = false,
  }) {
    final result = data.result;
    final level = data.levelLabel.isNotEmpty
        ? _localizedLevel(data.levelLabel)
        : 'placement_level_unknown'.tr();
    final progress = result?.progress ?? 0;
    final scoreText = '${(progress * 100).toInt()}%';

    _navigateTo(
      context,
      PlacementLevelStatusPage(
        mode: PlacementLevelStatusMode.lastPassedLevel,
        levelLabel: level,
        progress: progress,
        scoreText: scoreText,
      ),
      replace: replace,
    );
  }

  static String _localizedLevel(String level) {
    final localized = DisplayLocalization.level(level);
    return localized.isNotEmpty ? localized : level;
  }

  static void _openSelectLevel(
    BuildContext context, {
    bool replace = false,
  }) {
    _navigateTo(
      context,
      const SelectLevel(),
      replace: replace,
    );
  }

  static void _openCurrentLevelPage(
    BuildContext context,
    String level, {
    bool replace = false,
  }) {
    _navigateTo(
      context,
      PlacementLevelStatusPage(
        mode: PlacementLevelStatusMode.currentLevel,
        levelLabel: level,
      ),
      replace: replace,
    );
  }

  static void _openLastPassedLevelPage(
    BuildContext context,
    ExamResult exam, {
    bool replace = false,
  }) {
    final resultValue = double.tryParse(exam.result) ?? 0.0;
    final allSkillsGrade = double.tryParse(exam.allSkillsGrade) ?? 1.0;
    final progress = allSkillsGrade != 0
        ? (resultValue / allSkillsGrade).clamp(0.0, 1.0)
        : 0.0;

    _navigateTo(
      context,
      PlacementLevelStatusPage(
        mode: PlacementLevelStatusMode.lastPassedLevel,
        levelLabel: _localizedLevel(exam.level),
        progress: progress,
        scoreText: '${(progress * 100).toInt()}%',
      ),
      replace: replace,
    );
  }

  static void _navigateTo(
    BuildContext context,
    Widget page, {
    bool replace = false,
  }) {
    final route = MaterialPageRoute(builder: (_) => page);
    final nav = navigatorKey.currentState;
    if (nav != null) {
      if (replace) {
        nav.pushReplacement(route);
      } else {
        nav.push(route);
      }
      return;
    }

    if (!context.mounted) return;
    if (replace) {
      Navigator.of(context).pushReplacement(route);
    } else {
      Navigator.of(context).push(route);
    }
  }

  /// Uses [OverlayEntry] instead of [showDialog] to avoid a race where a fast
  /// API response pops before the dialog route is pushed, leaving a stuck spinner.
  static void _showLoadingOverlay() {
    _hideLoadingOverlay();

    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    _loadingEntry = OverlayEntry(
      builder: (_) => const AbsorbPointer(
        child: ColoredBox(
          color: Color(0x8A000000),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
    overlay.insert(_loadingEntry!);
  }

  static void _hideLoadingOverlay() {
    final entry = _loadingEntry;
    _loadingEntry = null;
    if (entry == null) return;
    try {
      entry.remove();
    } catch (_) {}
  }
}
