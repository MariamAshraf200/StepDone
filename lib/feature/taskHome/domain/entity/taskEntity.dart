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
  final bool notification; // whether notifications are enabled for this task
  final String notificationDate; // optional: date string for the notification (separate from task date)
  final String notificationTime; // optional: time string for the notification (separate from task time)

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
    this.notification = false,
    this.notificationDate = '',
    this.notificationTime = '',
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
      category: 'general',
      status: TaskStatus.toDo.toTaskStatusString(),
      updatedTime: null,
      planId: null,
      notification: false,
      notificationDate: '',
      notificationTime: '',
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
    bool? notification,
    String? notificationDate,
    String? notificationTime,
    TaskDetails? existingTask,
    BuildContext? context,
  }) {
    final formattedDate = date != null ? DateFormatUtil.formatDate(date) : '';

    final formattedStart = TimeFormatUtil.formatTime(startTime, context) ?? '';
    final formattedEnd = TimeFormatUtil.formatTime(endTime, context) ?? '';

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
      notification: notification ?? existingTask?.notification ?? false,
      notificationDate: notificationDate ?? existingTask?.notificationDate ?? '',
      notificationTime: notificationTime ?? existingTask?.notificationTime ?? '',
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
    bool? notification,
    String? notificationDate,
    String? notificationTime,
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
      notification: notification ?? this.notification,
      notificationDate: notificationDate ?? this.notificationDate,
      notificationTime: notificationTime ?? this.notificationTime,
    );
  }

  /// Convert entity to model
  TaskModel toModel() => TaskModel(
    id: id,
    title: title,
    description: description,
    date: date,
    time: time,
    endTime: endTime,
    priority: priority,
    category: category,
    status: status,
    updatedTime: updatedTime,
    planId: planId,
    notification: notification,
    notificationDate: notificationDate,
    notificationTime: notificationTime,
  );

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
    notification,
    notificationDate,
    notificationTime,
  ];
}
