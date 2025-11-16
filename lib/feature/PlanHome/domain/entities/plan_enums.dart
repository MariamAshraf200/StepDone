import 'package:flutter/widgets.dart';

import '../../../../l10n/app_localizations.dart';

enum PlanStatus {
  all,
  completed,
  notCompleted,
}

extension PlanStatusExtension on PlanStatus {
  static PlanStatus fromPlanStatusString(String? type) {
    switch (type?.toUpperCase()) {
      case 'COMPLETED':
        return PlanStatus.completed;
      case 'NOT_COMPLETED':
        return PlanStatus.notCompleted;
      case 'ALL':
      default:
        return PlanStatus.all;
    }
  }

  String toPlanStatusString() {
    switch (this) {
      case PlanStatus.all:
        return 'ALL';
      case PlanStatus.completed:
        return 'Completed';
      case PlanStatus.notCompleted:
        return 'Not Completed';
    }
  }

  /// Returns a localized label for this PlanStatus using [AppLocalizations].
  /// Falls back to `toPlanStatusString()` if localization is not available.
  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return toPlanStatusString();

    switch (this) {
      case PlanStatus.all:
        return l10n.allStatuses;
      case PlanStatus.completed:
        return l10n.planCompleted;
      case PlanStatus.notCompleted:
        return l10n.planNotCompleted;
    }
  }
}
