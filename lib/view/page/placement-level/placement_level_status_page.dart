import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

enum PlacementLevelStatusMode { currentLevel, lastPassedLevel }

class PlacementLevelStatusPage extends StatelessWidget {
  final PlacementLevelStatusMode mode;
  final String levelLabel;
  final double progress;
  final String? scoreText;

  const PlacementLevelStatusPage({
    super.key,
    required this.mode,
    required this.levelLabel,
    this.progress = 0,
    this.scoreText,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentLevel = mode == PlacementLevelStatusMode.currentLevel;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: dividerColor,
        title: Text(
          'placement_test_title'.tr(),
          style: getBoldStyle(color: blackColors, fontSize: FontSize.s20),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isCurrentLevel) ...[
                CircularPercentIndicator(
                  radius: 110,
                  lineWidth: 40,
                  animation: true,
                  percent: progress.clamp(0.0, 1.0),
                  center: Text(
                    scoreText ?? '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  progressColor: primaryColor,
                  backgroundColor: Colors.grey[300]!,
                ),
                const SizedBox(height: 24),
              ] else ...[
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.layers_outlined,
                    size: 56,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Text(
                isCurrentLevel
                    ? 'placement_current_level_title'.tr()
                    : 'placement_last_passed_title'.tr(),
                textAlign: TextAlign.center,
                style: getBoldStyle(color: blackColors, fontSize: FontSize.s22),
              ),
              const SizedBox(height: 12),
              Text(
                isCurrentLevel
                    ? 'placement_you_are_on_level'.tr(namedArgs: {'level': levelLabel})
                    : levelLabel,
                textAlign: TextAlign.center,
                style: getMediumStyle(color: primaryColor, fontSize: FontSize.s20),
              ),
              if (!isCurrentLevel && scoreText != null) ...[
                const SizedBox(height: 8),
                Text(
                  'placement_last_passed_score'.tr(namedArgs: {'score': scoreText!}),
                  textAlign: TextAlign.center,
                  style: getRegularStyle(color: grey, fontSize: FontSize.s16),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
