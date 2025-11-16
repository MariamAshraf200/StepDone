import '../../../../core/extensions/error_messages.dart';
import '../../../../core/util/date_and_time/time_sort_util.dart';
import '../../domain/entity/taskEntity.dart';
import '../../domain/entity/task_enum.dart';
import '../../domain/repo_interface/repoTask.dart';
import '../dataSource/abstract_data_scource.dart';
import '../model/taskModel.dart';


class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource dataSource;

  TaskRepositoryImpl(this.dataSource);

  @override
  Future<List<TaskDetails>> getTasks() async {
    try {
      final taskModels = await dataSource.getAllTasks();
      return modelsToEntitiesSortedByTime(taskModels);
    } catch (e) {
      throw Exception(ErrorStrings.loadingTasks(e));
    }
  }

  @override
  Future<List<TaskDetails>> getTasksByStatus(TaskStatus? status) async {
    try {
      final taskModels = await dataSource.getTasksByStatus(status);
      return modelsToEntitiesSortedByTime(taskModels);
    } catch (e) {
      throw Exception(ErrorStrings.loadingTasksWithStatus(status, e));
    }
  }

  @override
  Future<List<TaskDetails>> getTasksByPriority(TaskPriority? priority) async {
    try {
      final taskModels = await dataSource.getTasksByPriority(priority);
      return modelsToEntitiesSortedByTime(taskModels);
    } catch (e) {
      throw Exception(ErrorStrings.loadingTasksWithPriority(priority, e));
    }
  }

  @override
  Future<List<TaskDetails>> getTasksByDate(String date) async {
    try {
      final taskModels = await dataSource.getTasksByDate(date);
      return modelsToEntitiesSortedByTime(taskModels);
    } catch (e) {
      throw Exception(ErrorStrings.loadingTasksWithDate(date, e));
    }
  }

  @override
  Future<List<TaskDetails>> getTasksByPlanId(String planId) async {
    try {
      final taskModels = await dataSource.getTasksByPlanId(planId);
      return taskModels.map((taskModel) => taskModel.toEntity()).toList();
    } catch (e) {
      throw Exception(ErrorStrings.loadingTasksByPlanId(planId, e));
    }
  }

  @override
  Future<List<TaskDetails>> filterTasks({
    required String date,
    String? priority,
    String? status,
  }) async {
    final taskModels = await dataSource.getTasksByDate(date);
    final filtered = taskModels.where((task) =>
        (priority == null || task.priority == priority) &&
        (status == null || task.status == status)).toList();
    return modelsToEntitiesSortedByTime(filtered);
  }

  @override
  Future<void> addTask(TaskDetails task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      await dataSource.addTask(taskModel);
    } catch (e) {
      throw Exception(ErrorStrings.addTaskError(e));
    }
  }

  @override
  Future<void> updateTask(TaskDetails task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      await dataSource.updateTask(taskModel);
    } catch (e) {
      throw Exception(ErrorStrings.updateTaskError(e));
    }
  }

  @override
  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    try {
      final task = (await dataSource.getAllTasks()).firstWhere((task) => task.id == taskId);

      final updatedTask = task.copyWith(
        status: newStatus,
      );

      // Update the task in the data source
      await dataSource.updateTask(updatedTask);
    } catch (e) {
      throw Exception(ErrorStrings.updateTaskStatusError(e));
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await dataSource.deleteTask(taskId);
    } catch (e) {
      throw Exception(ErrorStrings.deleteTaskError(e));
    }
  }
}