import 'package:equatable/equatable.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/entities/plan_enums.dart';
import '../../domain/entities/taskPlan.dart';

abstract class PlanEvent extends Equatable {
  const PlanEvent();

  @override
  List<Object?> get props => [];
}

// 🔹 Plans Events
class GetAllPlansEvent extends PlanEvent {}

class GetPlansByCategoryEvent extends PlanEvent {
  final String category;
  const GetPlansByCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class GetPlansByPriorityEvent extends PlanEvent {
  final String priority;
  const GetPlansByPriorityEvent(this.priority);

  @override
  List<Object?> get props => [priority];
}

class AddPlanEvent extends PlanEvent {
  final PlanDetails plan;
  const AddPlanEvent(this.plan);

  @override
  List<Object?> get props => [plan];
}

class UpdatePlanEvent extends PlanEvent {
  final PlanDetails plan;
  const UpdatePlanEvent(this.plan);

  @override
  List<Object?> get props => [plan];
}

class DeletePlanEvent extends PlanEvent {
  final String planId;
  const DeletePlanEvent(this.planId);

  @override
  List<Object?> get props => [planId];
}

class UpdatePlanStatusEvent extends PlanEvent {
  final String planId;
  final String newStatus;
  const UpdatePlanStatusEvent(this.planId, this.newStatus);

  @override
  List<Object?> get props => [planId, newStatus];
}

class GetPlansByDateEvent extends PlanEvent {
  final String date;
  const GetPlansByDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

class FilterPlansEvent extends PlanEvent {
  final String date;
  final String? priority;
  final String? category;
  final String? status;

  const FilterPlansEvent({
    required this.date,
    this.priority,
    this.category,
    this.status,
  });

  @override
  List<Object?> get props => [date, priority, category, status];
}

class GetPlansByStatusEvent extends PlanEvent {
  final PlanStatus status;
  const GetPlansByStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}

// 🔹 Tasks Events
class GetAllTasksPlanEvent extends PlanEvent {
  final String planId;
  const GetAllTasksPlanEvent(this.planId);

  @override
  List<Object?> get props => [planId];
}

class AddTaskToPlanEvent extends PlanEvent {
  final String planId;
  final TaskPlan task;
  const AddTaskToPlanEvent({required this.planId, required this.task});

  @override
  List<Object?> get props => [planId, task];
}

class DeleteTaskFromPlanEvent extends PlanEvent {
  final String planId;
  final String taskId;
  const DeleteTaskFromPlanEvent({required this.planId, required this.taskId});

  @override
  List<Object?> get props => [planId, taskId];
}

class DeleteTaskAtIndexEvent extends PlanEvent {
  final String planId;
  final int index;
  const DeleteTaskAtIndexEvent({required this.planId, required this.index});

  @override
  List<Object?> get props => [planId, index];
}
class ToggleTaskStatusEvent extends PlanEvent {
  final String planId;
  final TaskPlan task;

  const ToggleTaskStatusEvent({required this.planId, required this.task});

  @override
  List<Object?> get props => [planId, task];
}
