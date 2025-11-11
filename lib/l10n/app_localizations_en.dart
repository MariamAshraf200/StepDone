// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get close => 'Close';

  @override
  String get chooseThemeColor => 'Choose theme color';

  @override
  String get palettePurple => 'Purple';

  @override
  String get paletteBlue => 'Blue';

  @override
  String get paletteGreen => 'Green';

  @override
  String get paletteRed => 'Red';

  @override
  String get paletteMix => 'Mix';

  @override
  String get addReminder => 'Add Reminder';

  @override
  String get createReminder => 'Create Reminder';

  @override
  String get noRemindersYet => 'No reminders yet';

  @override
  String get tapPlusToAddOne => 'Tap the + button to add one';

  @override
  String get remindersDashboardTitle => 'Reminders Dashboard';

  @override
  String remindersCount(int count) {
    if (count == 0) return 'No active reminders';
    if (count == 1) return '1 active reminder';
    return '\$count active reminders';
  }

  @override
  String get reminderTitle => 'Reminder title';

  @override
  String get pickDateTime => 'Pick date & time';

  @override
  String get daily => 'Daily';

  @override
  String get everyNDays => 'Every N days';

  @override
  String get nLabel => 'N';

  @override
  String get confirm => 'Confirm';

  @override
  String get pleaseFillAllFields => 'Please fill all fields';

  @override
  String get createNewTask => 'Create New Task';

  @override
  String get updateTask => 'Update Task';

  @override
  String get selectPriority => 'Select Priority';

  @override
  String get selectStatus => 'Select Status';

  @override
  String get allPriorities => 'All Priorities';

  @override
  String get allStatuses => 'All Statuses';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String get noTasksMatchFilters => 'No tasks match the filters.';

  @override
  String get taskTitle => 'Task Title';

  @override
  String get addTaskTitle => 'Add your task title';

  @override
  String get updateTaskTitle => 'Update your task title';

  @override
  String get taskTitleRequired => 'Task title is required';

  @override
  String get description => 'Description';

  @override
  String get addTaskDescription => 'Add your task description';

  @override
  String get updateTaskDescription => 'Update your task description';

  @override
  String get taskDate => 'Task Date';

  @override
  String get datePlaceholder => 'dd/mm/yyyy';

  @override
  String get addTaskButton => 'Add Task';

  @override
  String get updateTaskButton => 'Update Task';

  @override
  String get taskAdded => 'Task added successfully!';

  @override
  String get taskUpdated => 'Task updated successfully!';

  @override
  String get deleteTaskDescription => 'Are you sure you want to delete this task?';

  @override
  String get taskNotEditable => 'This task is already completed or missed and cannot be changed.';

  @override
  String get deleteTask => 'Delete Task';

  @override
  String get updateOperation => 'Update';

  @override
  String get deleteOperation => 'Delete';

  @override
  String get taskMarkedPrefix => 'Task marked as';

  @override
  String get statusDone => 'Done';

  @override
  String get statusMissed => 'Missed';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusToDo => 'To Do';

  @override
  String get addSubtask => 'Add Subtask';

  @override
  String get enterTaskTitle => 'Enter task title...';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get errorPrefix => 'Error: ';

  @override
  String get noDataAvailable => 'No data available.';

  @override
  String get myPlans => 'My Plans';

  @override
  String get myTasks => 'My Tasks';

  @override
  String get myPlan => 'My Plan';

  @override
  String get seeAll => 'See All';

  @override
  String get bottomNavPlan => 'Plan';

  @override
  String get bottomNavHome => 'Home';


  @override
  String get selectCategory => 'Select Category';

  @override
  String get allCategories => 'All Categories';

  @override
  String get noPlansMatchFilters => 'No plans match the filters.';

  @override
  String get planCompleted => 'Completed';

  @override
  String get planNotCompleted => 'Not Completed';

  @override
  String get deletePlan => 'Delete Plan';

  @override
  String get deletePlanDescription => 'Are you sure you want to delete this plan?';

  @override
  String get noPlansAvailable => 'No plans available.';

  @override
  String get unexpectedState => 'Unexpected state.';

  @override
  String get endDateCleared => 'End date cleared because it was before the newly selected start date';

  @override
  String get changePlanImage => 'Change Plan Image';

  @override
  String get images => 'Images';

  @override
  String get pickPlanImage => 'Pick Plan Image';

  @override
  String get planUpdated => 'Plan updated successfully!';

  @override
  String get planAdded => 'Plan added successfully!';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get addCategory => 'Add Category';

  @override
  String get add => 'Add';

  @override
  String get addNew => 'Add New';

  @override
  String get noTasksFound => 'No tasks found.';

  @override
  String get planTitle => 'Plan Title';

  @override
  String get addPlanTitle => 'Add your plan title';

  @override
  String get updatePlanTitle => 'Update your plan title';

  @override
  String get planTitleRequired => 'Plan title is required';

  @override
  String get addPlanDescription => 'Add your plan description';

  @override
  String get updatePlanDescription => 'Update your plan description';

  @override
  String get category => 'Category';

  @override
  String get categoryName => 'Category name';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get signInSecurely => 'Sign in securely with your Google account to continue.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get hello => 'Hello';

  @override
  String get toggleTheme => 'Toggle theme';

  @override
  String get logout => 'Log out';

  @override
  String get subtasks => 'Subtasks';

  @override
  String get noSubtasksYet => 'No subtasks yet.';

  @override
  String get planStartDate => 'Plan Start Date';

  @override
  String get planEndDate => 'Plan End Date';

  @override
  String get invalidEndDate => 'Invalid end date';

  @override
  String get endDateBeforeStartDate => 'End date cannot be before start date';

  @override
  String get addPlan => 'Add Plan';

  @override
  String get updatePlan => 'Update Plan';

  @override
  String get failedToLoadPlans => 'Failed to load plans. Please try again later.';

  @override
  String get noTime => 'No time';

  @override
  String get todaysProgress => "Today's Progress";

  @override
  String get tasks => 'Tasks';

  @override
  String get weeklyProgressTitle => '📊 Weekly Progress Analysis';

  @override
  String get title => 'Reminder';

  @override
  String weeklyBestDayMessage(String bestDayName) => '🔥 Excellent consistency! Best day: $bestDayName';

  @override
  String get weeklyGoodEffortMessage => '💪 Good effort! Keep it up.';

  @override
  String get weeklyBackOnTrackMessage => "🚀 Let's get back on track next week!";

  @override
  String get complete => 'complete';

  @override
  String get general => 'General';

  @override
  String get timeFormat => 'hh:mm AM/PM';

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';

  @override
  String get endBeforeStart => 'End time cannot be before start time';

  @override
  String get enterTime => 'Enter the time';

  @override
  String enterField(String field) => 'Enter the $field';

  @override
  String get dateFormat => 'dd/MM/yyyy';

  // Localized short words for relative dates
  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get appTitle => 'Task Tracker';
}
