import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:hatvest/core/utils/display_localization.dart';
import 'package:hatvest/core/network/dio_client.dart';
import 'package:hatvest/core/theme/app_colors.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/model/exam_model.dart';
import 'package:hatvest/viewmodel/exam_list_viewmodel.dart';
import 'package:dio/dio.dart';

class ExamsPage extends StatefulWidget {
  const ExamsPage({super.key});

  @override
  State<ExamsPage> createState() => _ExamsPageState();
}

class _ExamsPageState extends State<ExamsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamListViewModel>().fetchExams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: Stack(
        children: [
          // خلفية الصفحة
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/picc5.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // محتوى الصفحة
          Consumer<ExamListViewModel>(
        builder: (context, vm, _) {
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, vm),
              if (vm.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (vm.error != null)
                SliverFillRemaining(child: _buildError(context, vm))
              else if (vm.exams.isEmpty)
                SliverFillRemaining(child: _buildEmpty(context))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _ExamCard(exam: vm.exams[index]),
                      childCount: vm.exams.length,
                    ),
                  ),
                ),
            ],
          );
        },
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ExamListViewModel vm) {
    final completedCount =
        vm.exams.where((e) => e.status.toLowerCase() == 'completed').length;

    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, const Color(0xFF1E3A5F)],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button row
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_forward_ios,
                          color: Colors.white, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'exams_title'.tr(),
                  style: getBoldStyle(color: Colors.white, fontSize: FontSize.s24),
                ),
                if (vm.exams.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _StatChip(
                        icon: Icons.quiz_outlined,
                        label: '${vm.exams.length}',
                        sublabel: 'exams_total'.tr(),
                      ),
                      const SizedBox(width: 12),
                      _StatChip(
                        icon: Icons.check_circle_outline,
                        label: '$completedCount',
                        sublabel: 'exams_completed_count'.tr(),
                        color: const Color(0xFF4ADE80),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, ExamListViewModel vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, color: Colors.red[400], size: 48),
          ),
          const SizedBox(height: 16),
          Text('exams_error'.tr(),
              style: getBoldStyle(color: context.textPrimary, fontSize: FontSize.s16)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => vm.fetchExams(),
            icon: const Icon(Icons.refresh, size: 18),
            label: Text('exams_retry'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.quiz_outlined, color: primaryColor.withOpacity(0.5), size: 56),
          ),
          const SizedBox(height: 20),
          Text('exams_empty'.tr(),
              style: getBoldStyle(color: context.textSecondary, fontSize: FontSize.s16)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color? color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.sublabel,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: c, size: 18),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: getBoldStyle(color: c, fontSize: FontSize.s16)),
              Text(sublabel,
                  style: getRegularStyle(
                      color: Colors.white70, fontSize: FontSize.s12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExamCard extends StatefulWidget {
  final ExamItem exam;
  const _ExamCard({required this.exam});

  @override
  State<_ExamCard> createState() => _ExamCardState();
}

class _ExamCardState extends State<_ExamCard> {
  bool _isDownloading = false;

  Color get _statusColor {
    switch (widget.exam.status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF16A34A);
      case 'upcoming':
        return const Color(0xFF2563EB);
      case 'pending':
        return const Color(0xFFD97706);
      default:
        return Colors.grey;
    }
  }

  IconData get _statusIcon {
    switch (widget.exam.status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'upcoming':
        return Icons.schedule_rounded;
      case 'pending':
        return Icons.hourglass_empty_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  String _statusLabel() {
    switch (widget.exam.status.toLowerCase()) {
      case 'completed':
        return 'exam_status_completed'.tr();
      case 'upcoming':
        return 'exam_status_upcoming'.tr();
      case 'pending':
        return 'exam_status_pending'.tr();
      default:
        return widget.exam.status;
    }
  }

  Future<void> _download() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/exam_${widget.exam.id}.pdf';

      await dioClient.download(
        'exams/${widget.exam.id}/download',
        filePath,
        options: Options(
          headers: {'requiresToken': true},
          responseType: ResponseType.bytes,
        ),
      );

      final file = File(filePath);
      if (await file.exists()) {
        await OpenFile.open(filePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('exam_download_error'.tr()),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.exam.status.toLowerCase() == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.shadow.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header strip ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.description_outlined,
                      color: primaryColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    DisplayLocalization.examTitle(widget.exam.title),
                    style: getBoldStyle(
                        color: context.textPrimary, fontSize: FontSize.s14),
                  ),
                ),
                const SizedBox(width: 8),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, color: _statusColor, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel(),
                        style: getBoldStyle(
                            color: _statusColor, fontSize: FontSize.s12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Body ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoTile(
                        icon: Icons.school_outlined,
                        label: DisplayLocalization.course(widget.exam.course),
                      ),
                      const SizedBox(height: 8),
                      _InfoTile(
                        icon: Icons.bar_chart_rounded,
                        label: DisplayLocalization.level(widget.exam.level),
                      ),
                      const SizedBox(height: 8),
                      _InfoTile(
                        icon: Icons.calendar_today_outlined,
                        label: DisplayLocalization.date(widget.exam.date),
                      ),
                    ],
                  ),
                ),
                // Score circle (only for completed)
                if (isCompleted) ...[
                  const SizedBox(width: 12),
                  _ScoreCircle(score: widget.exam.score),
                ],
              ],
            ),
          ),

          // ── Download button ───────────────────────────────────
          if (isCompleted)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isDownloading ? null : _download,
                  icon: _isDownloading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.download_rounded,
                          color: Colors.white, size: 20),
                  label: Text(
                    _isDownloading
                        ? 'exam_downloading'.tr()
                        : 'exam_download'.tr(),
                    style: getMediumStyle(
                        color: Colors.white, fontSize: FontSize.s14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: primaryColor.withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Score circle widget ────────────────────────────────────────────────────────
class _ScoreCircle extends StatelessWidget {
  final int score;
  const _ScoreCircle({required this.score});

  Color get _color {
    if (score >= 85) return const Color(0xFF16A34A);
    if (score >= 60) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _color, width: 3),
        color: _color.withOpacity(0.08),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$score',
            style: getBoldStyle(color: _color, fontSize: FontSize.s20),
          ),
          Text(
            'exam_score_label'.tr(),
            style: getRegularStyle(color: _color, fontSize: FontSize.s12),
          ),
        ],
      ),
    );
  }
}

// ── Info tile ─────────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.07),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: primaryColor),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: getRegularStyle(
                color: context.textSecondary, fontSize: FontSize.s12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
