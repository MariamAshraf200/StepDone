import 'package:hive_flutter/hive_flutter.dart';
import '../../feature/PlanHome/data/model/planModel.dart';
import '../../feature/PlanHome/data/model/taskPlanAdapter.dart';
import '../../feature/taskHome/data/model/categoryModel.dart';
import '../../feature/taskHome/data/model/taskModel.dart';
import '../../feature/Notification/data/scheduled_reminder_adapter.dart';
import '../../feature/Notification/domain/scheduled_reminder.dart';

class HiveService {
  static const String _taskBoxName = 'tasks';
  static const String _categoryBoxName = 'categories';
  static const String _planBoxName = 'plans';
  static const String _reminderBoxName = 'reminders';

  Future<void> initHive() async {

    // Ensure Hive is initialized for Flutter before registering adapters or
    // opening any boxes. Initializing first avoids platform-specific issues
    // where adapters appear unregistered when a box is opened.
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskModelAdapter());
    }

    // CategoryModelAdapter uses typeId = 2 (generated file)
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }

    // Register PlanModelAdapter (typeId = 3)
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(PlanModelAdapter());
    }

    // Register TaskPlanAdapter (typeId = 4)
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(TaskPlanAdapter());
    }

    // Register ScheduledReminder adapter (typeId = 1)
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ScheduledReminderAdapter());
    }

    await Hive.openBox<TaskModel>(_taskBoxName);
    await Hive.openBox<CategoryModel>(_categoryBoxName);
    await Hive.openBox<PlanModel>(_planBoxName); // Open Plan Box
    // Open reminders box
    await Hive.openBox<ScheduledReminder>(_reminderBoxName);
  }

  Box<TaskModel> getTaskBox() => Hive.box<TaskModel>(_taskBoxName);
  Box<CategoryModel> getCategoryBox() => Hive.box<CategoryModel>(_categoryBoxName);
  Box<PlanModel> getPlanBox() => Hive.box<PlanModel>(_planBoxName); // Get Plan Box
  Box<ScheduledReminder> getReminderBox() => Hive.box<ScheduledReminder>(_reminderBoxName);

  Future<void> closeHive() async {
    if (Hive.isBoxOpen(_taskBoxName)) {
      await Hive.box<TaskModel>(_taskBoxName).close();
    }
    if (Hive.isBoxOpen(_categoryBoxName)) {
      await Hive.box<CategoryModel>(_categoryBoxName).close();
    }
    if (Hive.isBoxOpen(_planBoxName)) {
      await Hive.box<PlanModel>(_planBoxName).close();
    }
    if (Hive.isBoxOpen(_reminderBoxName)) {
      await Hive.box<ScheduledReminder>(_reminderBoxName).close();
    }
    await Hive.close();
  }
}
