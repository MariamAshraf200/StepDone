import 'package:flutter_bloc/flutter_bloc.dart';
// Notification repository calls removed: keep task notification state but do not interact with local notifications.
import 'state.dart' as taskState;
import '../../../../../injection_imports.dart';


class TaskBloc extends Bloc<TaskEvent, taskState.TaskState> {
  final GetAllTasksUseCase getAllTasksUseCase;
  final GetTasksByStatusUseCase getTasksByStatusUseCase;
  final GetTasksByPriorityUseCase getTasksByPriorityUseCase;
  final GetTasksByDateUseCase getTasksByDateUseCase;
  final GetTasksByPlanIdUseCase getTasksByPlanIdUseCase;
  final FilterTasksUseCase filterTasksUseCase;
  final AddTaskUseCase addTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final UpdateTaskStatusUseCase updateTaskStatusUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;

  TaskPriority? selectedPriority;
  TaskStatus? selectedStatus;
  String? selectedDate;

  TaskBloc({
    required this.getAllTasksUseCase,
    required this.getTasksByStatusUseCase,
    required this.getTasksByPriorityUseCase,
    required this.getTasksByDateUseCase,
    required this.getTasksByPlanIdUseCase,
    required this.filterTasksUseCase,
    required this.addTaskUseCase,
    required this.updateTaskUseCase,
    required this.updateTaskStatusUseCase,
    required this.deleteTaskUseCase,
  }) : super(taskState.TaskInitial()) {
    on<GetAllTasksEvent>(_handleGetAllTasks);
    on<GetTasksByStatusEvent>(_handleGetTasksByStatus);
    on<GetTasksByPriorityEvent>(_handleGetTasksByPriority);
    on<GetTasksByDateEvent>(_handleGetTasksByDate);
    on<FilterTasksEvent>(_handleFilterTasks);
    on<AddTaskEvent>(_handleAddTask);
    on<UpdateTaskEvent>(_handleUpdateTask);
    on<UpdateTaskStatusEvent>(_handleUpdateTaskStatus);
    on<DeleteTaskEvent>(_handleDeleteTask);
  }

  /// Common executor for async task operations
  Future<void> _execute(
    Emitter<taskState.TaskState> emit,
    Future<List<TaskDetails>> Function() taskOperation, {
    TaskFilters? filters,
  }) async {
    emit(taskState.TaskLoading());
    try {
      final tasks = await taskOperation();
      emit(taskState.TaskLoaded(tasks, filters: filters ?? TaskFilters()));
    } catch (e) {
      emit(taskState.TaskError("Error: $e"));
    }
  }

  // ---------------- Event Handlers ----------------


  void _refreshWithFilters() {
    if (selectedDate != null || selectedPriority != null || selectedStatus != null) {
      add(FilterTasksEvent(
        date: selectedDate,
        priority: selectedPriority,
        status: selectedStatus,
      ));
    } else {
      add(GetAllTasksEvent());
    }
  }


  Future<void> _handleGetAllTasks(
    GetAllTasksEvent event,
    Emitter<taskState.TaskState> emit,
  ) async {
    await _execute(emit, () => getAllTasksUseCase());
  }

  Future<void> _handleGetTasksByStatus(
    GetTasksByStatusEvent event,
    Emitter<taskState.TaskState> emit,
  ) async {
    await _execute(
      emit,
      () => getTasksByStatusUseCase(event.status),
      filters: TaskFilters(status: event.status),
    );
  }

  Future<void> _handleGetTasksByPriority(
    GetTasksByPriorityEvent event,
    Emitter<taskState.TaskState> emit,
  ) async {
    await _execute(
      emit,
      () => getTasksByPriorityUseCase(event.priority),
      filters: TaskFilters(priority: event.priority),
    );
  }

  Future<void> _handleGetTasksByDate(
    GetTasksByDateEvent event,
    Emitter<taskState.TaskState> emit,
  ) async {
    await _execute(
      emit,
      () => getTasksByDateUseCase(event.date),
      filters: TaskFilters(date: event.date),
    );
  }

  Future<void> _handleFilterTasks(
      FilterTasksEvent event,
      Emitter<taskState.TaskState> emit,
      ) async {
    selectedPriority = event.priority;
    selectedStatus = event.status;
    selectedDate = event.date; // keep track

    final filters = TaskFilters(
      date: event.date,
      priority: event.priority,
      status: event.status,
    );

    await _execute(
      emit,
          () => filterTasksUseCase(
        date: filters.date ?? '',
        priority: filters.priority?.toTaskPriorityString(),
        status: filters.status?.toTaskStatusString(),
      ),
      filters: filters,
    );
  }

  Future<void> _handleAddTask(
      AddTaskEvent event,
      Emitter<taskState.TaskState> emit,
      ) async {
    await addTaskUseCase(event.task);
    _refreshWithFilters();
  }

  Future<void> _handleUpdateTask(
      UpdateTaskEvent event,
      Emitter<taskState.TaskState> emit,
      ) async {
    // If update turns notifications off, we intentionally do NOT cancel any local
    // scheduled notifications here because local notifications have been disabled.
    // The task's `hasNotification` flag is still stored on the task entity.

    await updateTaskUseCase(event.task);
    await updateTaskStatusUseCase(
      event.task.id,
      TaskStatus.toDo.toTaskStatusString(),
    );
    _refreshWithFilters();
  }

  Future<void> _handleUpdateTaskStatus(
      UpdateTaskStatusEvent event,
      Emitter<taskState.TaskState> emit,
      ) async {
    await updateTaskStatusUseCase(
      event.taskId,
      event.newStatus?.toTaskStatusString() ?? '',
    );
    _refreshWithFilters();
  }

  Future<void> _handleDeleteTask(
      DeleteTaskEvent event,
      Emitter<taskState.TaskState> emit,
      ) async {
    // Local notifications are disabled; do not attempt to cancel any scheduled notifications here.
    await deleteTaskUseCase(event.taskId);
    _refreshWithFilters();
  }

}
