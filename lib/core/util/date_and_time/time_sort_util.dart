
import '../../../feature/taskHome/data/model/taskModel.dart';
import '../../../feature/taskHome/domain/entity/taskEntity.dart';
import 'time_format_util.dart';

/// Utilities to parse time strings and sort task models/entities by start time.
///
/// These helpers use `TimeFormatUtil.parseFlexibleTime` and treat empty or
/// unparseable times as "end of day" so they are ordered after valid times.

/// Convert a time string (e.g. "8:30 AM" or "08:30") into minutes since midnight.
/// Returns 24*60 (end of day) for null/empty/invalid strings.
int minutesFromTimeString(String? timeStr) {
  if (timeStr == null || timeStr.trim().isEmpty) return 24 * 60;
  final s = timeStr.trim();
  final tod = TimeFormatUtil.parseFlexibleTime(s);
  if (tod != null) return tod.hour * 60 + tod.minute;
  return 24 * 60;
}

/// Sorts a list of [TaskModel] by their `time` field (ascending) and returns a
/// new list.
List<TaskModel> sortTaskModelsByTime(List<TaskModel> models) {
  final sorted = List<TaskModel>.from(models);
  sorted.sort((a, b) => minutesFromTimeString(a.time).compareTo(minutesFromTimeString(b.time)));
  return sorted;
}

/// Converts a list of [TaskModel] to [TaskDetails] entities while sorting them
/// by start time (ascending).
List<TaskDetails> modelsToEntitiesSortedByTime(List<TaskModel> models) {
  final sorted = sortTaskModelsByTime(models);
  return sorted.map((m) => m.toEntity()).toList();
}

