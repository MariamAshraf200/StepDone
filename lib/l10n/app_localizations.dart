import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// Tooltip text for closing the screen
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Title for the theme color picker
  ///
  /// In en, this message translates to:
  /// **'Choose theme color'**
  String get chooseThemeColor;

  /// Palette name: purple
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get palettePurple;

  /// Palette name: blue
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get paletteBlue;

  /// Palette name: green
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get paletteGreen;

  /// Palette name: red
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get paletteRed;

  /// Palette name: mix
  ///
  /// In en, this message translates to:
  /// **'Mix'**
  String get paletteMix;

  /// Label for the FAB to add a reminder
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminder;

  /// Title for creating a reminder
  ///
  /// In en, this message translates to:
  /// **'Create Reminder'**
  String get createReminder;

  /// Message shown when there are no reminders yet
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get noRemindersYet;

  /// Helper text shown on empty reminders screen
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add one'**
  String get tapPlusToAddOne;

  /// Title for the reminders dashboard header
  ///
  /// In en, this message translates to:
  /// **'Reminders Dashboard'**
  String get remindersDashboardTitle;

  /// Returns a localized summary for the number of active reminders.
  ///
  /// Example (en): `2 active reminders`
  String remindersCount(int count);

  /// Label for the reminder title field
  ///
  /// In en, this message translates to:
  /// **'Reminder title'**
  String get reminderTitle;

  /// Button label shown to pick date and time
  ///
  /// In en, this message translates to:
  /// **'Pick date & time'**
  String get pickDateTime;

  /// FilterChip label for daily repetition
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// FilterChip label for every-N-days repetition
  ///
  /// In en, this message translates to:
  /// **'Every N days'**
  String get everyNDays;

  /// Label for the 'N' input field
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get nLabel;

  /// Confirm button label in the add reminder sheet
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Validation message when required fields are empty
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get pleaseFillAllFields;

  /// Title for the Add Task screen
  ///
  /// In en, this message translates to:
  /// **'Create New Task'**
  String get createNewTask;

  /// Title for the Update Task screen
  ///
  /// In en, this message translates to:
  /// **'Update Task'**
  String get updateTask;

  /// Hint text for selecting task priority
  ///
  /// In en, this message translates to:
  /// **'Select Priority'**
  String get selectPriority;

  /// Hint text for selecting task status
  ///
  /// In en, this message translates to:
  /// **'Select Status'**
  String get selectStatus;

  /// Dropdown option to show all priorities
  ///
  /// In en, this message translates to:
  /// **'All Priorities'**
  String get allPriorities;

  /// Dropdown option to show all statuses
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get allStatuses;

  /// Label for high priority
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// Label for medium priority
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// Label for low priority
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// Message displayed when no filtered tasks are found
  ///
  /// In en, this message translates to:
  /// **'No tasks match the filters.'**
  String get noTasksMatchFilters;

  /// Label for the task title field
  ///
  /// In en, this message translates to:
  /// **'Task Title'**
  String get taskTitle;

  /// Label for the images section
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// Placeholder for adding task title
  ///
  /// In en, this message translates to:
  /// **'Add your task title'**
  String get addTaskTitle;

  /// Placeholder for updating task title
  ///
  /// In en, this message translates to:
  /// **'Update your task title'**
  String get updateTaskTitle;

  /// Validation message when title is empty
  ///
  /// In en, this message translates to:
  /// **'Task title is required'**
  String get taskTitleRequired;

  /// Label for description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Placeholder for adding description
  ///
  /// In en, this message translates to:
  /// **'Add your task description'**
  String get addTaskDescription;

  /// Placeholder for updating description
  ///
  /// In en, this message translates to:
  /// **'Update your task description'**
  String get updateTaskDescription;

  /// Label for task date field
  ///
  /// In en, this message translates to:
  /// **'Task Date'**
  String get taskDate;

  /// Date format placeholder
  ///
  /// In en, this message translates to:
  /// **'dd/mm/yyyy'**
  String get datePlaceholder;

  /// Label for add task button
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTaskButton;

  /// Label for update task button
  ///
  /// In en, this message translates to:
  /// **'Update Task'**
  String get updateTaskButton;

  /// Snackbar message when task added
  ///
  /// In en, this message translates to:
  /// **'Task added successfully!'**
  String get taskAdded;

  /// Snackbar message when task updated
  ///
  /// In en, this message translates to:
  /// **'Task updated successfully!'**
  String get taskUpdated;

  /// Placeholder for deleting task description
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this task?'**
  String get deleteTaskDescription;

  /// Message shown when a task can't be edited (completed or missed)
  ///
  /// In en, this message translates to:
  /// **'This task is already completed or missed and cannot be changed.'**
  String get taskNotEditable;


  /// Title for delete task dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get deleteTask;

  /// Label for update operation button
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateOperation;

  /// Label for delete operation button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteOperation;

  /// Prefix for task status change snackbar
  ///
  /// In en, this message translates to:
  /// **'Task marked as'**
  String get taskMarkedPrefix;

  /// Label for done status
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// Label for pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// Label for missed status
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get statusMissed;

  /// Label for to-do status
  ///
  /// In en, this message translates to:
  /// **'To Do'**
  String get statusToDo;

  /// Title for add subtask dialog
  ///
  /// In en, this message translates to:
  /// **'Add Subtask'**
  String get addSubtask;

  /// Hint text for entering a task title in dialogs
  ///
  /// In en, this message translates to:
  /// **'Enter task title...'**
  String get enterTaskTitle;

  /// Label for cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Label for save action
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Prefix used for error messages
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get errorPrefix;

  /// Message shown when no data is available
  ///
  /// In en, this message translates to:
  /// **'No data available.'**
  String get noDataAvailable;

  /// Header title for plans screen
  ///
  /// In en, this message translates to:
  /// **'My Plans'**
  String get myPlans;

  /// Header title used on the home screen for the user's tasks
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get myTasks;

  /// Section title for the user's plan area on the home screen
  ///
  /// In en, this message translates to:
  /// **'My Plan'**
  String get myPlan;

  /// Label for the 'See All' button
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// Bottom navigation label: Plan
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get bottomNavPlan;

  /// Bottom navigation label: Home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bottomNavHome;
  /// Hint text for selecting a category
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// Label for the 'All Categories' dropdown item
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// Message shown when no plans match filters
  ///
  /// In en, this message translates to:
  /// **'No plans match the filters.'**
  String get noPlansMatchFilters;

  /// Label for plan status 'Completed'
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get planCompleted;

  /// Label for plan status 'Not Completed'
  ///
  /// In en, this message translates to:
  /// **'Not Completed'**
  String get planNotCompleted;

  /// Title for delete plan dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Plan'**
  String get deletePlan;

  /// Placeholder for deleting plan description
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this plan?'**
  String get deletePlanDescription;

  /// Message shown when there is no data available
  ///
  /// In en, this message translates to:
  /// **'No plans available.'**
  String get noPlansAvailable;

  /// Message shown when unexpected state occurs
  ///
  /// In en, this message translates to:
  /// **'Unexpected state.'**
  String get unexpectedState;

  /// Informational message when end date cleared due to start date change
  ///
  /// In en, this message translates to:
  /// **'End date cleared because it was before the newly selected start date'**
  String get endDateCleared;

  /// Label for changing plan image
  ///
  /// In en, this message translates to:
  /// **'Change Plan Image'**
  String get changePlanImage;

  /// Label for picking plan image
  ///
  /// In en, this message translates to:
  /// **'Pick Plan Image'**
  String get pickPlanImage;

  /// Snackbar message when plan updated
  ///
  /// In en, this message translates to:
  /// **'Plan updated successfully!'**
  String get planUpdated;

  /// Snackbar message when plan added
  ///
  /// In en, this message translates to:
  /// **'Plan added successfully!'**
  String get planAdded;

  /// Label for try again action
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Label for adding a category
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// Label for a generic add action
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Label for 'Add New'
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// Message shown when no tasks found
  ///
  /// In en, this message translates to:
  /// **'No tasks found.'**
  String get noTasksFound;

  /// Label for plan title
  ///
  /// In en, this message translates to:
  /// **'Plan Title'**
  String get planTitle;

  /// Placeholder for adding plan title
  ///
  /// In en, this message translates to:
  /// **'Add your plan title'**
  String get addPlanTitle;

  /// Placeholder for updating plan title
  ///
  /// In en, this message translates to:
  /// **'Update your plan title'**
  String get updatePlanTitle;

  /// Validation message when plan title is empty
  ///
  /// In en, this message translates to:
  /// **'Plan title is required'**
  String get planTitleRequired;

  /// Placeholder for adding plan description
  ///
  /// In en, this message translates to:
  /// **'Add your plan description'**
  String get addPlanDescription;

  /// Placeholder for updating plan description
  ///
  /// In en, this message translates to:
  /// **'Update your plan description'**
  String get updatePlanDescription;

  /// Label for category header
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Input hint for category name
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// Default category name
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// Example/time format placeholder shown in time fields
  ///
  /// In en, this message translates to:
  /// **'hh:mm AM/PM'**
  String get timeFormat;

  /// Label for start time field
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// Label for end time field
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// Validation message when end time is before start time
  ///
  /// In en, this message translates to:
  /// **'End time cannot be before start time'**
  String get endBeforeStart;

  /// Validation hint when time field is empty
  ///
  /// In en, this message translates to:
  /// **'Enter the time'**
  String get enterTime;

  /// Welcome title on the auth screen
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// Subtitle on the auth screen
  ///
  /// In en, this message translates to:
  /// **'Sign in securely with your Google account to continue.'**
  String get signInSecurely;

  /// Label for continue with Google button
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Generic error headline
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Greeting word used before a user's name (e.g. "Hello John")
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// Label for toggling the app theme
  ///
  /// In en, this message translates to:
  /// **'Toggle theme'**
  String get toggleTheme;

  /// Label for logging out / signing out
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// Label for subtasks section
  ///
  /// In en, this message translates to:
  /// **'Subtasks'**
  String get subtasks;

  /// Message shown when there are no subtasks yet
  ///
  /// In en, this message translates to:
  /// **'No subtasks yet.'**
  String get noSubtasksYet;

  /// Constructed helper for validation error messages: "Enter the {field}"
  ///
  /// In en, this message translates to:
  /// **'Enter the {field}'**
  String enterField(String field);

  /// Label for plan start date field
  ///
  /// In en, this message translates to:
  /// **'Plan Start Date'**
  String get planStartDate;

  /// Label for plan end date field
  ///
  /// In en, this message translates to:
  /// **'Plan End Date'**
  String get planEndDate;

  /// Validation text for invalid end date
  ///
  /// In en, this message translates to:
  /// **'Invalid end date'**
  String get invalidEndDate;

  /// Validation text when end date is before start date
  ///
  /// In en, this message translates to:
  /// **'End date cannot be before start date'**
  String get endDateBeforeStartDate;

  /// Label for adding a plan
  ///
  /// In en, this message translates to:
  /// **'Add Plan'**
  String get addPlan;

  /// Label for updating a plan
  ///
  /// In en, this message translates to:
  /// **'Update Plan'**
  String get updatePlan;

  /// No description provided for @failedToLoadPlans.
  ///
  /// In en, this message translates to:
  /// **'Failed to load plans.'**
  String get failedToLoadPlans;

  /// No description provided for @noTime.
  ///
  /// In en, this message translates to:
  /// **'No time'**
  String get noTime;

  /// No description provided for @todaysProgress.
  ///
  /// In en, this message translates to:
  /// **'Today's Progress'**
  String get todaysProgress;

  /// Label for the localized word "Today"
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Label for the localized word "Yesterday"
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Label for the localized word "Tomorrow"
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @weeklyProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgressTitle;

  /// No description provided for @weeklyGoodEffortMessage.
  ///
  /// In en, this message translates to:
  /// **'Good effort this week!'**
  String get weeklyGoodEffortMessage;

  /// No description provided for @weeklyBackOnTrackMessage.
  ///
  /// In en, this message translates to:
  /// **'You are back on track this week!'**
  String get weeklyBackOnTrackMessage;

  /// No description provided for @weeklyBackOnTrackMessage.
  ///
  /// In en, this message translates to:
  /// **'You are back on track this week!'**
  String get complete;

  /// No description provided for @weeklyBestDayMessage.
  ///
  /// In en, this message translates to:
  /// **'Your best day was {bestDayName}'**
  String weeklyBestDayMessage(String bestDayName);

  /// No description provided for @dateFormat.
///
/// In en, this message translates to:
/// **'dd/MM/yyyy'**
String get dateFormat;

  /// Title of the application
  ///
  /// In en, this message translates to:
  /// **'Task Management App'**
  String get appTitle;

  /// Title used for small reminder dialogs and cards
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get title;

  /// Getter for enableNotification.
  /// This should return the localized string for enabling notifications.
  String get enableNotification;

  /// Label for Reminder
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
