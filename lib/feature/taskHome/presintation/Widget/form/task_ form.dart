import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/util/date_and_time/time_range_field.dart';
import '../../../../../injection_imports.dart';
import '../../../../../l10n/l10n_extension.dart';
import '../../../../notification/domain/entities/notification_entity.dart';
import '../../../../notification/domain/usecases/cancel_notification_usecase.dart';
import '../../../../notification/domain/usecases/schedule_notification_usecase.dart';
import '../../../../notification/domain/usecases/request_permission_usecase.dart';

enum TaskFormMode { add, update }

class TaskForm extends StatefulWidget {
  final TaskFormMode mode;
  final TaskDetails? task;
  final String? planId;

  const TaskForm({
    super.key,
    required this.mode,
    this.task,
    this.planId,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  DateTime? _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _selectedCategory;
  TaskPriority _selectedPriority = TaskPriority.medium;
  bool _notificationEnabled = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    if (widget.mode == TaskFormMode.update && widget.task != null) {
      _initializeFromTask(widget.task!);
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }

  void _initializeFromTask(TaskDetails task) {
    _titleController = TextEditingController(text: task.title);
    _descriptionController = TextEditingController(text: task.description);
    try {
    _date = DateFormatUtil.parseDate(task.date);
    } catch (_) {}
    _startTime = task.time.isNotEmpty ? TimeFormatUtil.parseFlexibleTime(task.time) : null;
    _endTime = task.endTime.isNotEmpty ? TimeFormatUtil.parseFlexibleTime(task.endTime) : null;
    _selectedCategory = task.category;
    _selectedPriority = TaskPriorityExtension.fromString(task.priority);
    _notificationEnabled = task.hasNotification;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: AppSpaces.calculatePaddingFromScreenWidth(context),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(height: 10),
            _buildTitleField(),
            _buildDescriptionField(),
            _buildDateField(),
            const SizedBox(height: 16),
            _buildTimeFields(),
            const SizedBox(height: 16),
            _buildCategorySelector(),
            const SizedBox(height: 16),
            _buildPrioritySelector(),
            const SizedBox(height: 16),
            _buildNotificationToggle(),
            const SizedBox(height: 16),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  // ---------------- Widgets ----------------

  Widget _buildTitleField() => CustomTextField(
    isRequired: true,
    outSideTitle: context.l10n.taskTitle,
    borderRadius: 10,
    labelText: widget.mode == TaskFormMode.add
        ? context.l10n.addTaskTitle
        : context.l10n.updateTaskTitle,
    controller: _titleController,
    maxLength: 42,
    validator: (value) =>
    (value.trim().isEmpty) ? context.l10n.taskTitleRequired : null,
  );

  Widget _buildDescriptionField() => CustomTextField(
    outSideTitle: context.l10n.description,
    labelText: widget.mode == TaskFormMode.add
        ? context.l10n.addTaskDescription
        : context.l10n.updateTaskDescription,
    controller: _descriptionController,
    maxLines: 3,
    canBeNull: true,
  );

  Widget _buildDateField() => DateFiled(
    onDateSelected: (selected) => setState(() => _date = selected),
    isRequired: true,
    outSideTitle: context.l10n.taskDate,
    labelText: context.l10n.datePlaceholder,
    suffixIcon: const Icon(Icons.date_range),
    initialDate: _date,
  );

  Widget _buildTimeFields() => TimeRangeField(
    startTime: _startTime,
    endTime: _endTime,
    onStartTimeChanged: (time) => setState(() => _startTime = time),
    onEndTimeChanged: (time) => setState(() => _endTime = time),
    canBeNull: true,
  );

  Widget _buildCategorySelector() => BlocBuilder<CategoryBloc, CategoryState>(
    builder: (context, state) {
      return CategorySelectorWithLogic(
        selectedCategory: _selectedCategory,
        onCategorySelected: (category) =>
            setState(() => _selectedCategory = category),
      );
    },
  );

  Widget _buildPrioritySelector() => PrioritySelectorWithLogic(
    selectedPriority: _selectedPriority,
    onPrioritySelected: (p) => setState(() => _selectedPriority = p),
  );

  Widget _buildNotificationToggle() => SwitchListTile(
    title: Text(context.l10n.enableNotifications),
    value: _notificationEnabled,
    onChanged: (value) => setState(() => _notificationEnabled = value),
  );

  Widget _buildSubmitButton() => LoadingElevatedButton(
    onPressed: _handleSubmit,
    buttonText: widget.mode == TaskFormMode.add
        ? context.l10n.addTaskButton
        : context.l10n.updateTaskButton,
    icon: Icon(widget.mode == TaskFormMode.add ? Icons.add : Icons.update),
    showLoading: false,
  );

  // ---------------- Logic ----------------

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final task = TaskDetails.fromFormData(
      title: _titleController.text,
      description: _descriptionController.text,
      date: _date,
      startTime: _startTime,
      endTime: _endTime,
      priority: _selectedPriority,
      category: _selectedCategory,
      planId: widget.planId,
      notification: _notificationEnabled,
      existingTask: widget.task,
      // avoid passing State.context into this method to prevent accidental use of
      // the context after the State may have been disposed while awaiting async work
      context: null,
    );

    // 🧩 Dispatch Task Add/Update
    if (widget.mode == TaskFormMode.add) {
      context.read<TaskBloc>().add(AddTaskEvent(task, planId: widget.planId));
    } else {
      context.read<TaskBloc>().add(UpdateTaskEvent(task));
    }

    // 🧠 Notification Logic
    await _handleNotification(task);

    // Only use context if the State is still mounted and not disposed
    if (!mounted || _isDisposed) return;
    Navigator.of(context).pop();
  }

  Future<void> _handleNotification(TaskDetails task) async {
    try {
      // Ensure permission
      final permissionUseCase = sl<RequestPermissionUseCase>();
      await permissionUseCase();
      if (!mounted || _isDisposed) return;

      final scheduleUseCase = sl<ScheduleNotificationUseCase>();
      final cancelUseCase = sl<CancelNotificationUseCase>();

      // Cancel old notification if needed
      if (widget.mode == TaskFormMode.update &&
          widget.task != null &&
          widget.task!.hasNotification) {
        await cancelUseCase(widget.task!.id.hashCode);
        if (!mounted || _isDisposed) return;
      }

      // Schedule or cancel
      if (task.hasNotification && task.notifyAt != null) {
        final notification = AppNotification(
          id: task.id.hashCode,
          title: task.title.isNotEmpty ? task.title : 'Reminder',
          body: task.description.isNotEmpty
              ? task.description
              : 'Task reminder',
          scheduledTime: task.notifyAt!,
        );
        final exact = await scheduleUseCase(notification);
        if (!mounted || _isDisposed) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(exact
                  ? '⏰ Exact notification scheduled'
                  : '⏰ Notification scheduled')),
        );
      } else if (widget.mode == TaskFormMode.update &&
          widget.task != null &&
          !task.hasNotification) {
        await cancelUseCase(task.id.hashCode);
        if (!mounted || _isDisposed) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🔕 Notification cancelled')),
        );
      }
    } catch (e) {
      debugPrint('Notification error: $e');
      if (!mounted || _isDisposed) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Failed to handle notifications')),
      );
    }
  }
}
