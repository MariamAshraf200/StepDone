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

---

# The main Technologies & Packages/Plugins used in the App  
* **State Management:** Using [flutter_bloc](https://pub.dev/packages/flutter_bloc).  
* **Local Database:** [hive](https://pub.dev/packages/hive).  
* **Dependency Injection:** [get_it](https://pub.dev/packages/get_it).  
* **Architecture:** Clean Architecture following **Uncle Bob** principles.  
* **Other Plugins:**  
  * [uuid](https://pub.dev/packages/uuid) – for unique IDs.  
  * [intl](https://pub.dev/packages/intl) – for date formatting.  

---

# The App Architecture, Directory structure, And State Management  
* Using `Bloc` for State Management.  
* Using `get_it` for Dependency injection.  
* Applying `Clean Architecture` layered design.  

📌 Example Clean Architecture model used:  
![image](assets/images/flutter_clean_arch.png)  

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
└──feature
    ├──Home/
    ├──PlanHome/
    └──taskHome/
        
```
