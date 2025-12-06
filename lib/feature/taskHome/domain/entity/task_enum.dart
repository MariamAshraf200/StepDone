import 'package:StepDone/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../l10n/app_localizations.dart';

enum TaskFilterType { date, priority, status }
enum TaskPriority { low, medium, high }
enum TaskStatus { toDo, pending, done, missed }

extension TaskFilterTypeExtension on TaskFilterType {
  static TaskFilterType fromString(String? type) {
    switch (type?.toUpperCase()) {
      case 'DATE':
        return TaskFilterType.date;
      case 'PRIORITY':
        return TaskFilterType.priority;
      case 'STATUS':
        return TaskFilterType.status;
      default:
        throw ArgumentError('Invalid TaskFilterType: $type');
    }
  }

  String toTaskFilterTypeString() {
    switch (this) {
      case TaskFilterType.date:
        return 'DATE';
      case TaskFilterType.priority:
        return 'PRIORITY';
      case TaskFilterType.status:
        return 'STATUS';
    }
  }
}

extension TaskPriorityExtension on TaskPriority {
  static TaskPriority fromString(String? priority) {
    switch (priority?.toUpperCase()) {
      case 'LOW':
        return TaskPriority.low;
      case 'MEDIUM':
        return TaskPriority.medium;
      case 'HIGH':
        return TaskPriority.high;
      default:
        throw ArgumentError('Invalid TaskPriority: $priority');
    }
  }

  String toTaskPriorityString() {
    switch (this) {
      case TaskPriority.low:
        return 'LOW';
      case TaskPriority.medium:
        return 'MEDIUM';
      case TaskPriority.high:
        return 'HIGH';
    }
  }

  /// Returns a localized label for this priority using [AppLocalizations].
  /// Falls back to `toTaskPriorityString()` if localization is not available.
  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return toTaskPriorityString();

    switch (this) {
      case TaskPriority.low:
        return l10n.priorityLow;
      case TaskPriority.medium:
        return l10n.priorityMedium;
      case TaskPriority.high:
        return l10n.priorityHigh;
    }
  }

  String toPriorityLabel(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case TaskPriority.high:
        return l10n.priorityHigh;
      case TaskPriority.medium:
        return l10n.priorityMedium;
      case TaskPriority.low:
        return l10n.priorityLow;
    }
  }

  Color toPriorityColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (this) {
      case TaskPriority.high:
        return colorScheme.primary;
      case TaskPriority.medium:
        return colorScheme.secondary;
      case TaskPriority.low:
        return colorScheme.onSurface.withAlpha(120);
    }
  }
}

extension TaskStatusExtension on TaskStatus {
  static TaskStatus fromString(String? status) {
    switch (status?.toUpperCase()) {
      case 'TO DO':
        return TaskStatus.toDo;
      case 'PENDING':
        return TaskStatus.pending;
      case 'DONE':
        return TaskStatus.done;
      case 'MISSED':
        return TaskStatus.missed;
      default:
        throw ArgumentError('Invalid TaskStatus: $status');
    }
  }

  String toTaskStatusString() {
    switch (this) {
      case TaskStatus.toDo:
        return 'TO DO';
      case TaskStatus.pending:
        return 'PENDING';
      case TaskStatus.done:
        return 'DONE';
      case TaskStatus.missed:
        return 'MISSED';
    }
  }

  /// Returns a localized label for this status using [AppLocalizations].
  /// Falls back to `toTaskStatusString()` if localization is not available.
  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return toTaskStatusString();

    switch (this) {
      case TaskStatus.toDo:
        return l10n.statusToDo;
      case TaskStatus.pending:
        return l10n.statusPending;
      case TaskStatus.done:
        return l10n.statusDone;
      case TaskStatus.missed:
        return l10n.statusMissed;
    }
  }
}
