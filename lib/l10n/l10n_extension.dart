import 'package:flutter/widgets.dart';
import 'app_localizations.dart';
import 'app_localizations_en.dart';

/// Convenience extension to access generated localizations from a BuildContext.
///
/// Usage: `context.l10n.someKey`
///
/// This returns a non-null `AppLocalizations` instance. If the
/// localization delegate hasn't been loaded into the context yet,
/// it falls back to English (`AppLocalizationsEn`) to avoid
/// runtime null-check exceptions.
extension L10nBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this) ?? AppLocalizationsEn();
}

/// Small safe helpers that expose a few additional localized strings
/// while remaining robust if the generated `AppLocalizations` class
/// doesn't yet contain them (uses `dynamic` access with fallbacks).
extension L10nFallbackHelpers on BuildContext {
  String get notificationSent {
    final dynamic loc = l10n;
    try {
      return loc.notificationSent as String;
    } catch (_) {
      return 'Notification sent';
    }
  }

  String get notificationFailed {
    final dynamic loc = l10n;
    try {
      return loc.notificationFailed as String;
    } catch (_) {
      return 'Failed to send notification';
    }
  }

  String get sendNotification {
    final dynamic loc = l10n;
    try {
      return loc.sendNotification as String;
    } catch (_) {
      return 'Send notification';
    }
  }
}
