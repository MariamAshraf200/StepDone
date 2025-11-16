import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

String formatedDate(
    BuildContext context,
    DateTime date, {
      bool useRelativeDateLabels = true,
    }) {
  final l10n = AppLocalizations.of(context)!;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final tomorrow = today.add(const Duration(days: 1));

  if (useRelativeDateLabels) {
    if (DateTime(date.year, date.month, date.day).isAtSameMomentAs(today)) {
      return l10n.today; // localized "Today"
    } else if (DateTime(date.year, date.month, date.day).isAtSameMomentAs(yesterday)) {
      return l10n.yesterday; // localized "Yesterday"
    } else if (DateTime(date.year, date.month, date.day).isAtSameMomentAs(tomorrow)) {
      return l10n.tomorrow; // localized "Tomorrow"
    }
  }

  // Default date formatting if not Today/Yesterday/Tomorrow
  final pattern = l10n.dateFormat;
  return DateFormat(pattern).format(date);
}
