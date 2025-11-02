import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../../injection_imports.dart';

class TaskDetails extends Equatable {
  final String id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String endTime;
  final String priority;
  final String category;
  final String status;
  final String? updatedTime;
  final String? planId;
  final bool hasNotification; // 👈 جديد
  final DateTime? notifyAt;

  const TaskDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.endTime,
    required this.priority,
    required this.category,
    required this.status,
    this.updatedTime,
    this.planId,
    this.hasNotification = false,
    this.notifyAt,
  });

  /// Default empty task
  factory TaskDetails.empty() {
    return TaskDetails(
      id: '',
      title: '',
      description: '',
      date: '',
      time: '',
      endTime: '',
      priority: TaskPriority.medium.toTaskPriorityString(),
      // store canonical key for the default category so UI can localize display
      category: 'general',
      status: TaskStatus.toDo.toTaskStatusString(),
      updatedTime: null,
      planId: null,
      hasNotification: false,
      notifyAt: null,
    );
  }

  factory TaskDetails.fromFormData({
    required String title,
    required String description,
    required DateTime? date,
    required TimeOfDay? startTime,
    required TimeOfDay? endTime,
    required TaskPriority priority,
    required String? category,
    required String? planId,
    required bool notification,
    TaskDetails? existingTask,
    BuildContext? context,
  }) {
    final formattedDate =
        date != null ? DateFormatUtil.formatDate(date) : '';

    final formattedStart = TimeFormatUtil.formatTime(startTime, context) ?? '';
    final formattedEnd = TimeFormatUtil.formatTime(endTime, context) ?? '';

    // compute notifyAt if notification is enabled and date/startTime available
    DateTime? notifyAt;
    if (notification) {
      try {
        if (date != null && startTime != null) {
          notifyAt = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
          if (notifyAt.isBefore(DateTime.now())) {
            // fallback: schedule shortly in future if date/time are in the past
            notifyAt = DateTime.now().add(const Duration(seconds: 5));
          }
        } else if (date != null) {
          // default to 09:00 local time on the given date
          notifyAt = DateTime(date.year, date.month, date.day, 9, 0);
          if (notifyAt.isBefore(DateTime.now())) notifyAt = DateTime.now().add(const Duration(seconds: 5));
        }
      } catch (_) {
        notifyAt = null;
      }
    }

    return (existingTask ?? TaskDetails.empty()).copyWith(
      id: existingTask?.id ?? const Uuid().v4(),
      title: title.trim(),
      description: description.trim(),
      date: formattedDate,
      time: formattedStart,
      endTime: formattedEnd,
      priority: priority.toTaskPriorityString(),
      category: category ?? 'general',
      status: existingTask?.status ?? TaskStatus.toDo.toTaskStatusString(),
      planId: planId,
      hasNotification: notification,
      notifyAt: notifyAt,
    );
  }

  /// Pure `copyWith`
  TaskDetails copyWith({
    String? id,
    String? title,
    String? description,
    String? date,
    String? time,
    String? endTime,
    String? priority,
    String? category,
    String? status,
    String? updatedTime,
    String? planId,
    bool? hasNotification,
    DateTime? notifyAt,
  }) {
    return TaskDetails(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      endTime: endTime ?? this.endTime,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      status: status ?? this.status,
      updatedTime: updatedTime ?? this.updatedTime,
      planId: planId ?? this.planId,
      hasNotification: hasNotification ?? this.hasNotification,
      notifyAt: notifyAt ?? this.notifyAt,
    );
  }

  /// Convert entity to model
  TaskModel toModel() => TaskModel.fromEntity(this);

  /// Returns the end time as a DateTime combining `date` and `endTime` (or null if parsing fails).
  DateTime? get endTimeDateTime {
    try {
      final dateDt = DateFormatUtil.tryParseFlexible(date);
      final tod = TimeFormatUtil.parseFlexibleTime(endTime);
      if (dateDt != null && tod != null) {
        return DateTime(dateDt.year, dateDt.month, dateDt.day, tod.hour, tod.minute);
      }
    } catch (_) {}
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    date,
    time,
    endTime,
    priority,
    category,
    status,
    updatedTime,
    planId,
    hasNotification,
    notifyAt,
  ];
}
