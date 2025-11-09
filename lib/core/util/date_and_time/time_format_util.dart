import 'package:flutter/material.dart';

class TimeFormatUtil {
  /// Formats a [TimeOfDay] to a string, optionally using [context] for locale-aware formatting.
  static String? formatTime(TimeOfDay? timeOfDay, [BuildContext? context]) {
    if (timeOfDay == null) return null;
    if (context != null) return timeOfDay.format(context);

    final hour = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Parses a time string in 'hh:mm a' format to a TimeOfDay object.
  static TimeOfDay parseTime(String timeStr) {
    final format = RegExp(r'^(\d{1,2}):(\d{2})\s*([AP]M)$', caseSensitive: false);
    final match = format.firstMatch(timeStr.trim());
    if (match != null) {
      int hour = int.parse(match.group(1)!);
      final int minute = int.parse(match.group(2)!);
      final String period = match.group(3)!.toUpperCase();
      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    throw FormatException('Invalid time format: $timeStr');
  }

  /// Parses a time string in either 'hh:mm a' (AM/PM) or 'HH:mm' (24-hour) formats.
  /// Returns a TimeOfDay on success, or null if parsing fails.
  static TimeOfDay? parseFlexibleTime(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    // Try AM/PM parser
    try {
      return parseTime(s);
    } catch (_) {}

    // Fallback: try HH:mm 24h format
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(s);
    if (match != null) {
      final hour = int.tryParse(match.group(1)!) ?? 0;
      final minute = int.tryParse(match.group(2)!) ?? 0;
      if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }
    return null;
  }

  /// Flexibly formats a time string in either 'hh:mm a' or 'HH:mm' format to a readable string.
  static String? formatFlexibleTime(String raw, [BuildContext? context]) {
    raw = raw.trim();
    if (raw.isEmpty) return null;
    // Try 'hh:mm a' format first
    try {
      final tod = parseTime(raw);
      return formatTime(tod, context);
    } catch (_) {}
    // Fallback: HH:mm 24h
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(raw);
    if (match != null) {
      final hour = int.tryParse(match.group(1)!) ?? 0;
      final minute = int.tryParse(match.group(2)!) ?? 0;
      if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
        final tod = TimeOfDay(hour: hour, minute: minute);
        return formatTime(tod, context);
      }
    }
    return null;
  }

  static TimeOfDay? tryParse(String raw) => parseFlexibleTime(raw);
}
