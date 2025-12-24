import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Small helper to initialize and extract the local timezone.
class TimezoneHelper {
  /// Initialize timezone database and set the local timezone.
  static Future<void> initLocalTimeZone() async {
    tz.initializeTimeZones();

    try {
      final dynamic tzResult = await FlutterTimezone.getLocalTimezone();
      final String zoneName = _extractTzName(tzResult);
      tz.setLocalLocation(tz.getLocation(zoneName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  /// Try multiple common property names on the returned object/string.
  static String _extractTzName(dynamic tzResult) {
    if (tzResult is String) return tzResult;

    try {
      return tzResult.identifier ??
          tzResult.name ??
          tzResult.value ??
          tzResult.timezone ??
          tzResult.tz ??
          tzResult.toString();
    } catch (_) {
      return 'UTC';
    }
  }
}

