import 'package:get_it/get_it.dart';
import 'feature/notification/domain/usecases/cancel_notification_usecase.dart';
import 'feature/notification/domain/usecases/request_permission_usecase.dart';
import 'feature/notification/domain/usecases/schedule_notification_usecase.dart';
import 'injection_imports.dart';
import 'feature/notification/data/datasource/local_notification_service.dart';
import 'feature/notification/data/repositories/notification_repository_impl.dart';
import 'feature/notification/domain/repositories/notification_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  try {
    ///////////////////////// Hive //////////////////////////////
    ////////////////////////////////////////////////////////////
    // Register HiveService
    sl.registerLazySingleton<HiveService>(() => HiveService());

    // Initialize Hive
    final hiveService = sl<HiveService>();
    await hiveService.initHive();

    ///////////////////////// Data sources (Hive-backed) /////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////

    // Register HiveTaskLocalDataSource
    sl.registerLazySingleton<TaskLocalDataSource>(
      () => HiveTaskLocalDataSource(sl<HiveService>()),
    );

    // Register HiveCategoryLocalDataSource
    sl.registerLazySingleton<CategoryLocalDataSource>(
      () => HiveCategoryLocalDataSource(sl<HiveService>()),
    );

    // Register HivePlanLocalDataSource
    sl.registerLazySingleton<HivePlanLocalDataSource>(
      () => HivePlanLocalDataSource(sl<HiveService>()),
    );

    // Register LocalNotificationService and NotificationRepository
    sl.registerLazySingleton<LocalNotificationService>(() => LocalNotificationService());
    sl.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(sl<LocalNotificationService>()),
    );

    // Initialize the notification service so timezone data and plugin are ready
    await sl<LocalNotificationService>().init();

    // Notification use cases
    sl.registerLazySingleton(() => ScheduleNotificationUseCase(sl<NotificationRepository>()));
    sl.registerLazySingleton(() => RequestPermissionUseCase(sl<NotificationRepository>()));
    sl.registerLazySingleton(() => CancelNotificationUseCase(sl<NotificationRepository>()));

    ///////////////////////// Repositories /////////////////////////////
    ///////////////////////////////////////////////////////////////////

    // Register TaskRepository
    sl.registerLazySingleton<TaskRepository>(
      () => TaskRepositoryImpl(sl<TaskLocalDataSource>()),
    );

    // Register CategoryRepository
    sl.registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(sl<CategoryLocalDataSource>()),
    );

    // Register PlanRepository
    sl.registerLazySingleton<PlanRepository>(
      () => PlanRepositoryImpl(sl<HivePlanLocalDataSource>()),
    );

    ///////////////////////// Use Cases - Tasks /////////////////////////////
    ////////////////////////////////////////////////////////////////////////

    sl.registerLazySingleton(() => AddTaskUseCase(sl<TaskRepository>()));
    sl.registerLazySingleton(() => GetAllTasksUseCase(sl<TaskRepository>()));
    sl.registerLazySingleton(() => DeleteTaskUseCase(sl<TaskRepository>()));
    sl.registerLazySingleton(() => UpdateTaskUseCase(sl<TaskRepository>()));
    sl.registerLazySingleton(
        () => GetTasksByStatusUseCase(sl<TaskRepository>()));
    sl.registerLazySingleton(
        () => GetTasksByPriorityUseCase(sl<TaskRepository>()));
    sl.registerLazySingleton(
        () => UpdateTaskStatusUseCase(sl<TaskRepository>()));
    sl.registerLazySingleton(() => GetTasksByDateUseCase(sl<TaskRepository>()));
    sl.registerLazySingleton(() => FilterTasksUseCase(sl<TaskRepository>()));
    sl.registerLazySingleton(
        () => GetTasksByPlanIdUseCase(sl<TaskRepository>()));

    ///////////////////////// Use Cases - Categories /////////////////////////////
    //////////////////////////////////////////////////////////////////////////////

    sl.registerLazySingleton(
        () => AddCategoryUseCase(sl<CategoryRepository>()));
    sl.registerLazySingleton(
        () => GetAllCategoriesUseCase(sl<CategoryRepository>()));
    sl.registerLazySingleton(
        () => DeleteCategoryUseCase(sl<CategoryRepository>()));

    ///////////////////////// Use Cases - Plans /////////////////////////////
    /////////////////////////////////////////////////////////////////////////

    sl.registerLazySingleton(() => GetAllPlansUseCase(sl<PlanRepository>()));
    sl.registerLazySingleton(() => DeletePlanUseCase(sl<PlanRepository>()));
    sl.registerLazySingleton(
        () => GetPlansByCategoryUseCase(sl<PlanRepository>()));
    sl.registerLazySingleton(() => AddPlanUseCase(sl<PlanRepository>()));
    sl.registerLazySingleton(() => UpdatePlanUseCase(sl<PlanRepository>()));
    sl.registerLazySingleton(
        () => GetPlansByStatusUseCase(sl<PlanRepository>()));
    sl.registerLazySingleton(
        () => UpdatePlanStatusUseCase(sl<PlanRepository>()));
    // Plan task use cases
    sl.registerLazySingleton(() => GetAllTasksPlanUseCase(sl<PlanRepository>()));
    sl.registerLazySingleton(() => AddTaskPlanUseCase(sl<PlanRepository>()));
    sl.registerLazySingleton(() => DeleteTaskAtPlanUseCase(sl<PlanRepository>()));
    sl.registerLazySingleton(() => UpdateTaskStatusPlanUseCase(sl<PlanRepository>()));

    // Home usecases
    sl.registerLazySingleton(() => ComputeWeeklyProgressUsecase());
    sl.registerLazySingleton(() => UpdateDailyProgressUsecase());

    ///////////////////////// Blocs / Cubits /////////////////////////////
    /////////////////////////////////////////////////////////////////////

    // Register TaskBloc
    sl.registerFactory(() => TaskBloc(
          getAllTasksUseCase: sl<GetAllTasksUseCase>(),
          addTaskUseCase: sl<AddTaskUseCase>(),
          updateTaskUseCase: sl<UpdateTaskUseCase>(),
          deleteTaskUseCase: sl<DeleteTaskUseCase>(),
          getTasksByStatusUseCase: sl<GetTasksByStatusUseCase>(),
          getTasksByPriorityUseCase: sl<GetTasksByPriorityUseCase>(),
          updateTaskStatusUseCase: sl<UpdateTaskStatusUseCase>(),
          getTasksByDateUseCase: sl<GetTasksByDateUseCase>(),
          filterTasksUseCase: sl<FilterTasksUseCase>(),
          getTasksByPlanIdUseCase: sl<GetTasksByPlanIdUseCase>(),
        ));

    // Register CategoryBloc
    sl.registerFactory(() => CategoryBloc(
          addCategoryUseCase: sl<AddCategoryUseCase>(),
          getAllCategoriesUseCase: sl<GetAllCategoriesUseCase>(),
          deleteCategoryUseCase: sl<DeleteCategoryUseCase>(),
        ));

    // Register PlanBloc
    sl.registerFactory(() => PlanBloc(
        getAllPlansUseCase: sl<GetAllPlansUseCase>(),
        addPlanUseCase: sl<AddPlanUseCase>(),
        updatePlanUseCase: sl<UpdatePlanUseCase>(),
        deletePlanUseCase: sl<DeletePlanUseCase>(),
        getPlansByCategoryUseCase: sl<GetPlansByCategoryUseCase>(),
        getPlansByStatusUseCase: sl<GetPlansByStatusUseCase>(),
        updatePlanStatusUseCase: sl<UpdatePlanStatusUseCase>(),
        getAllTasksPlanUseCase: sl<GetAllTasksPlanUseCase>(),
        addTaskPlanUseCase: sl<AddTaskPlanUseCase>(),
        deleteTaskAtPlanUseCase: sl<DeleteTaskAtPlanUseCase>(),
        updateTaskStatusPlanUseCase: sl<UpdateTaskStatusPlanUseCase>(),
      ));
  } catch (e) {
    /*if (kDebugMode) {
      debugPrint("Error during DI initialization: $e");
    }
    if (kDebugMode) {
      debugPrint(stackTrace.toString());
    }*/
  }
}
