import 'package:intl/intl.dart';

import '../../../feature/PlanHome/data/model/planModel.dart';
import '../../../feature/PlanHome/domain/entities/plan_entity.dart';

/// Utilities to parse flexible date strings and sort plans by start date.
///
/// parseFlexibleDate accepts common formats like `dd/MM/yyyy`, `dd-MM-yyyy`,
/// `yyyy-MM-dd`, `MMM d, yyyy`, and falls back to `DateTime.tryParse`.
class DateSortUtil {
  static final List<String> _candidateFormats = [
    'dd/MM/yyyy',
    'd/M/yyyy',
    'dd-MM-yyyy',
    'd-M-yyyy',
    'yyyy-MM-dd',
    'MMM d, yyyy',
    'MMMM d, yyyy',
  ];

  /// Parse a date string in several common formats. Returns `null` for
  /// null/empty/'N/A' or if parsing fails.
  static DateTime? parseFlexibleDate(String? dateStr) {
    if (dateStr == null) return null;
    final s = dateStr.trim();
    if (s.isEmpty) return null;
    if (s.toLowerCase() == 'n/a') return null;

    // Try explicit formats first
    for (final fmt in _candidateFormats) {
      try {
        final dt = DateFormat(fmt).parseStrict(s);
        return dt;
      } catch (_) {
        // ignore and try next
      }
    }

    // Fallback to Dart's ISO parsing
    try {
      final dt = DateTime.tryParse(s);
      if (dt != null) return dt;
    } catch (_) {}

    return null;
  }

  static final DateTime _endOfTime = DateTime(9999, 12, 31);

  /// Returns parsed date or a far-future sentinel used for sorting.
  static DateTime _dateOrEnd(String? s) => parseFlexibleDate(s) ?? _endOfTime;

  /// Sorts a list of PlanModel by their `startDate` ascending and returns a new list.
  static List<PlanModel> sortPlanModelsByStartDate(List<PlanModel> models) {
    final sorted = List<PlanModel>.from(models);
    sorted.sort((a, b) => _dateOrEnd(a.startDate).compareTo(_dateOrEnd(b.startDate)));
    return sorted;
  }

  /// Converts a list of PlanModel to PlanDetails entities while sorting by start date.
  static List<PlanDetails> modelsToEntitiesSortedByStartDate(List<PlanModel> models) {
    final sorted = sortPlanModelsByStartDate(models);
    return sorted.map((m) => m.toEntity()).toList();
  }

  /// Sorts a list of PlanDetails by their `startDate` ascending and returns a new list.
  static List<PlanDetails> sortPlanDetailsByStartDate(List<PlanDetails> plans) {
    final sorted = List<PlanDetails>.from(plans);
    sorted.sort((a, b) => _dateOrEnd(a.startDate).compareTo(_dateOrEnd(b.startDate)));
    return sorted;
  }
}

