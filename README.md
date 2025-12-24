# StepDone App  

## License  
This project is licensed under the MIT License © 2025  [Mariam Ashraf](https://github.com/MariamAshraf200)- see the [LICENSE](./LICENSE).  

---

## A Flutter project is mainly used for  
* **Task Feature:**  
  * Add, update, and delete tasks.  
  * Mark tasks as completed or not completed.  
  * Organize and track tasks with simple daily management.  

* **Plan Feature:**  
  * Create plans that contain a group of tasks.  
  * Add subtasks, update their status, or remove them.  
  * Automatically track progress of plans based on tasks’ completion.  
  * Store plans locally using **Hive** for persistence.  

* **Authentication (Google)**
  * Sign in with Google: users can authenticate using their Google account to unlock personalized experiences.  
  * Account management: sign out and switch accounts. (If you enable backend sync, authentication can be used to associate local plans/tasks with a user account.)

* **Notification Feature**
  * Local reminders: schedule local notifications to remind users about tasks or plans at a specific date/time.
  * Recurring reminders & quick actions: support for repeating reminders, and actionable notifications (open app, snooze) where platform supports it.

---

# The main Technologies & Packages/Plugins used in the App  
* **State Management:** Using [flutter_bloc](https://pub.dev/packages/flutter_bloc).  
* **Local Database:** [hive](https://pub.dev/packages/hive).  
* **Dependency Injection:** [get_it](https://pub.dev/packages/get_it).  
* **Architecture:** Clean Architecture following **Uncle Bob** principles.  
* **Other Plugins:**  
  * [uuid](https://pub.dev/packages/uuid) – for unique IDs.  
  * [intl](https://pub.dev/packages/intl) – for date formatting.  
  * [google_sign_in](https://pub.dev/packages/google_sign_in) – Google Sign-In integration for authentication.  
  * [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) – Local notifications for scheduling and displaying reminders.  
  * [flutter_timezone](https://pub.dev/packages/flutter_timezone) – Timezone handling for scheduled notifications (recommended).  

---

# Authentication — Quick setup notes (Google Sign-In)

- Add `google_sign_in` to `pubspec.yaml` and follow the plugin docs for platform setup (Android: OAuth client / SHA-1; iOS: URL schemes).
- Use the app's `AuthBloc`/use-cases for sign-in/sign-out; provide a clear UI button and handle sign-out cleanup.

---

# Notifications — Quick setup notes (Local notifications)

- Uses `flutter_local_notifications` + `flutter_timezone` (and `tz`) for timezone-aware local scheduling.
- Add the packages to `pubspec.yaml`, call `LocalNotificationService.init()` in `main.dart`, and request runtime permission on Android 13+/iOS before posting notifications.
- Use helpers like `LocalNotificationService.scheduleOneTime(...)` and `scheduleRepeat(...)` to schedule reminders.

---

# The App Architecture, Directory structure, And State Management  
* Using `Bloc` for State Management.  
* Using `get_it` for Dependency injection.  
* Applying `Clean Architecture` layered design.  

📌 Example Clean Architecture model used:  

## Directory Structure  

```
lib
│   app_bootstrapper.dart
│   dispose_bloc.dart
│   global_bloc.dart
│   injection_container.dart
│   injection_imports.dart
│   main.dart
│
├──core
│   ├──constants/
│   ├──context_extensions.dart
│   ├──custom_color.dart
│   ├──failure.dart
│   ├──hive_services.dart
│   └──util/
│       ├──custom_builders/
│       ├──date_format_util.dart
│       ├──functions/
│       ├──time_format_util.dart
│       └──widgets/
│
└──features
    ├──Authentication/
    ├──Home/
    ├──PlanHome/
    └──taskHome/
        
```
