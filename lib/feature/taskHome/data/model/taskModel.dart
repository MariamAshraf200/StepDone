import 'package:hive/hive.dart';
import '../../domain/entity/taskEntity.dart';

part 'taskModel.g.dart';

@HiveType(typeId: 0)
class TaskModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String date;

  @HiveField(4)
  final String time;

  @HiveField(5)
  final String endTime;

  @HiveField(6)
  final String priority;

  @HiveField(7)
  final String status;

  @HiveField(8)
  final String category;

  @HiveField(9)
  final String? updatedTime; // Added field to track last update time

  @HiveField(10)
  final String? planId; // New nullable field for plan ID

  @HiveField(11)
  final bool notification; // New field indicating whether notifications are enabled

  @HiveField(12)
  final String notificationDate; // optional notification date (separate from task date)

  @HiveField(13)
  final String notificationTime; // optional notification time (separate from task time)

  // Constructor
  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.endTime,
    required this.priority,
    required this.status,
    required this.category,
    this.updatedTime, // Optional, to ensure backward compatibility
    this.planId, // Optional, for backward compatibility
    this.notification = false, // Defaults to false for backward compatibility
    this.notificationDate = '',
    this.notificationTime = '',
  });

  /// Converts the `TaskModel` to a `TaskDetails` entity.
  TaskDetails toEntity() {
    return TaskDetails(
      id: id,
      title: title,
      description: description,
      date: date,
      time: time,
      endTime: endTime,
      priority: priority,
      status: status,
      category: category,
      updatedTime: updatedTime,
      planId: planId,
      notification: notification,
      notificationDate: notificationDate,
      notificationTime: notificationTime,
    );
  }

  /// Creates a `TaskModel` from a `TaskDetails` entity.
  factory TaskModel.fromEntity(TaskDetails entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      date: entity.date,
      time: entity.time,
      endTime: entity.endTime,
      priority: entity.priority,
      status: entity.status,
      category: entity.category,
      updatedTime: entity.updatedTime, // Mapping updatedTime from the entity
      planId: entity.planId, // Mapping planId from the entity
      notification: entity.notification, // Map notification from entity
      notificationDate: entity.notificationDate,
      notificationTime: entity.notificationTime,
    );
  }

  /// `copyWith` method for updating selected fields.
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? date,
    String? time,
    String? endTime,
    String? priority,
    String? status,
    String? category,
    String? updatedTime, // Added updatedTime to the copyWith method
    String? planId, // Added planId to the copyWith method
    bool? notification, // Added notification to the copyWith method
    String? notificationDate,
    String? notificationTime,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      endTime: endTime ?? this.endTime,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      category: category ?? this.category,
      updatedTime: updatedTime ?? this.updatedTime, // Copying updatedTime
      planId: planId ?? this.planId, // Copying planId
      notification: notification ?? this.notification, // Copying notification
      notificationDate: notificationDate ?? this.notificationDate,
      notificationTime: notificationTime ?? this.notificationTime,
    );
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, description: $description, date: $date, time: $time, endTime: $endTime, priority: $priority, status: $status, category: $category, updatedTime: $updatedTime, planId: $planId, notification: $notification, notificationDate: $notificationDate, notificationTime: $notificationTime)';
  }
}
