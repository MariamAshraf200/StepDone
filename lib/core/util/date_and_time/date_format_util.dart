import 'package:intl/intl.dart';

class DateFormatUtil {
  /// Returns the current date formatted as 'dd/MM/yyyy'.
  static String getCurrentDateFormatted() {
    return DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  /// Formats a given [date] as 'dd/MM/yyyy'.
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formats a given [date] as 'yyyy/MM/dd'.
  static String formatDateYearFirst(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }

  /// Parses a date string in 'dd/MM/yyyy' format to a DateTime object.
  static DateTime parseDate(String dateStr) {
    return DateFormat('dd/MM/yyyy').parse(dateStr);
  }

  /// Formats a given [dateStr] ('dd/MM/yyyy') into 'MMMM d, yyyy' (e.g. April 20, 2024), localized.
  static String formatFullDate(String dateStr, {String? locale}) {
    final date = parseDate(dateStr);
    return DateFormat("MMMM d, yyyy", locale).format(date);
  }

  /// Tries to parse a raw date string in multiple formats and returns a DateTime or null.
  static DateTime? tryParseFlexible(String raw) {
    if (raw.trim().isEmpty) return null;
    // Try the expected dd/MM/yyyy first
    try {
      return parseDate(raw);
    } catch (_) {}
    // Try common alternatives
    final formats = ['yyyy-MM-dd', 'yyyy/MM/dd', 'MM/dd/yyyy'];
    for (final f in formats) {
      try {
        return DateFormat(f).parseStrict(raw);
      } catch (_) {}
    }
    // Try ISO parse
    try {
      return DateTime.parse(raw);
    } catch (_) {}
    return null;
  }

  /// Formats a raw date string (flexible input) into 'MMMM d, yyyy', localized. If parsing fails returns the raw string.
  static String formatFullDateFromRaw(String raw, {String? locale}) {
    final dt = tryParseFlexible(raw);
    if (dt == null) return raw;
    return DateFormat("MMMM d, yyyy", locale).format(dt);
  }

  /// Formats a DateTime as 'dd/MM hh:mm a' (e.g. 05/11 02:30 PM).
  static String formatDateAndTimeShort(DateTime dt, {String? locale}) {
    return DateFormat('dd/MM hh:mm a', locale).format(dt);
  }

  /// Formats a DateTime as 'dd/MM HH:mm' using 24-hour clock (e.g. 26/11 14:30).
  ///
  /// Use this for compact, locale-independent displays where a 24-hour
  /// representation is desired.
  static String formatDateAndTimeCompact(DateTime dt) {
    return DateFormat('dd/MM HH:mm').format(dt);
  }
}
