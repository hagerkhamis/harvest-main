/// Helpers for parsing and normalizing exam / placement-test scores.
///
/// API payloads sometimes mix number/string types, leave `*grade` empty,
/// or send an overall max that is a per-skill ceiling (e.g. total 13 / max 10).
class ExamScoreHelper {
  ExamScoreHelper._();

  static double parse(dynamic raw, [double fallback = 0]) {
    if (raw == null) return fallback;
    if (raw is num) return raw.toDouble();
    final text = raw.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return fallback;
    return double.tryParse(text) ?? fallback;
  }

  /// Caps [value] so it never exceeds a positive [max].
  static double capped(double value, double max) {
    if (max <= 0) return value < 0 ? 0 : value;
    if (value < 0) return 0;
    return value > max ? max : value;
  }

  static double ratio(double value, double max) {
    if (max <= 0) return 0;
    return (value / max).clamp(0.0, 1.0);
  }

  static String format(double value, double max) {
    final safeMax = max > 0 ? max : 0.0;
    final safeValue = capped(value, safeMax > 0 ? safeMax : value);
    return '${_fmt(safeValue)} / ${_fmt(safeMax > 0 ? safeMax : safeValue)}';
  }

  static String _fmt(double n) {
    if (n == n.roundToDouble()) return n.toInt().toString();
    return n.toStringAsFixed(1);
  }

  /// Prefer API [total]/ if missing or clearly inconsistent with [max],
  /// fall back to the sum of skill scores (already capped).
  static double resolveTotal({
    required double apiTotal,
    required double max,
    required List<double> skillScores,
  }) {
    final skillsSum = skillScores.fold<double>(0, (a, b) => a + b);
    var total = apiTotal > 0 ? apiTotal : skillsSum;
    if (max > 0 && total > max) {
      // Prefer skill sum when it fits under the max; otherwise cap.
      if (skillsSum > 0 && skillsSum <= max) {
        total = skillsSum;
      } else {
        total = max;
      }
    }
    return total < 0 ? 0 : total;
  }

  /// Prefer API overall max; if missing or smaller than [total], use sum of
  /// per-skill maxima (fixes overall "13 / 10" when 10 is a per-skill ceiling).
  static double resolveMax({
    required double apiMax,
    required double total,
    required List<double> skillMaxima,
  }) {
    final skillsMaxSum = skillMaxima.fold<double>(0, (a, b) => a + b);
    if (apiMax > 0 && total <= apiMax) return apiMax;
    if (skillsMaxSum > 0 && (apiMax <= 0 || total > apiMax)) {
      return skillsMaxSum;
    }
    if (apiMax > 0) return apiMax;
    return total > 0 ? total : 0;
  }
}
