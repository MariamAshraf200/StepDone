import 'package:StepDone/l10n/l10n_extension.dart';

import '../../../../../injection_imports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/taskBloc/state.dart' as taskState;

class TaskTrack extends StatefulWidget {
  const TaskTrack({super.key});

  @override
  State<TaskTrack> createState() => _TaskTrackState();
}

class _TaskTrackState extends State<TaskTrack> {
  late String selectedDate;
  String? selectedPriority;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedDate = DateFormatUtil.getCurrentDateFormatted();

    final taskBloc = context.read<TaskBloc>();
    selectedPriority = taskBloc.selectedPriority?.toTaskPriorityString();
    selectedStatus = taskBloc.selectedStatus?.toTaskStatusString();

    _triggerFilterEvent();
  }

  void _triggerFilterEvent() {
    context.read<TaskBloc>().add(
          FilterTasksEvent(
            date: selectedDate,
            priority: selectedPriority != null
                ? TaskPriorityExtension.fromString(selectedPriority)
                : null,
            status: selectedStatus != null
                ? TaskStatusExtension.fromString(selectedStatus)
                : null,
          ),
        );
  }

  void _updateDate(String newDate) {
    setState(() => selectedDate = newDate);
    _triggerFilterEvent();
  }

  void _updatePriority(String? priority) {
    setState(() => selectedPriority = priority);
    _triggerFilterEvent();
  }

  void _updateStatus(String? status) {
    setState(() => selectedStatus = status);
    _triggerFilterEvent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomCard(
        margin: const EdgeInsets.symmetric(vertical: 0.0),
        padding: const EdgeInsets.all(8),
        elevation: 0.0,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: [

            const SizedBox(height: 10),
            TaskDateSelector(
              selectedDate: selectedDate,
              onDateSelected: _updateDate,
            ),
            const SizedBox(height: 16),
            TaskFilters(
              selectedPriority: selectedPriority,
              selectedStatus: selectedStatus,
              onPriorityChanged: _updatePriority,
              onStatusChanged: _updateStatus,
            ),
            const SizedBox(height: 16),
            const TaskListSection(),
          ],
        ),
      ),
      // Floating action button that navigates to AddTask screen
      floatingActionButton: CustomFAB(context: context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class TaskDateSelector extends StatelessWidget {
  final String selectedDate;
  final ValueChanged<String> onDateSelected; // changed to String

  const TaskDateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Convert the existing `selectedDate` string to a DateTime for the
    // refactored `DataFormat` widget. We fall back to today if parsing fails.
    DateTime parsed;
    try {
      parsed = DateFormatUtil.parseDate(selectedDate);
    } catch (_) {
      parsed = DateTime.now();
    }

    return DataFormat(
      selectedDate: parsed,
      onDateSelected: (date) {
        // format DateTime → String before passing back to the rest of the screen
        final formatted = DateFormatUtil.formatDate(date);
        onDateSelected(formatted);
      },
    );
  }
}

class TaskFilters extends StatelessWidget {
  final String? selectedPriority;
  final String? selectedStatus;
  final ValueChanged<String?> onPriorityChanged;
  final ValueChanged<String?> onStatusChanged;

  const TaskFilters({
    super.key,
    required this.selectedPriority,
    required this.selectedStatus,
    required this.onPriorityChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _FilterDropdown<String>(
            icon: Icon(Icons.filter_list, color: colorScheme.primary),
            value: selectedPriority,
            hint: context.l10n.selectPriority,
            items: [
              ...TaskPriority.values.map((p) => DropdownMenuItem(
                  value: p.toTaskPriorityString(),
                  child: Text(p.toPriorityLabel(context),style: TextStyle(color:colorScheme.primary ),))),
              DropdownMenuItem(
                  value: null, child: Text(context.l10n.allPriorities,style: TextStyle(color:colorScheme.primary ),)),
            ],
            onChanged: onPriorityChanged,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _FilterDropdown<String>(
            icon: Icon(Icons.task_alt, color: colorScheme.primary),
            value: selectedStatus,
            hint: context.l10n.selectStatus,
            items: [
              ...TaskStatus.values.map((s) => DropdownMenuItem(
                  value: s.toTaskStatusString(),
                  child: Text(s.localized(context),style:TextStyle(color: colorScheme.primary) ,))),
              DropdownMenuItem(
                  value: null, child: Text(context.l10n.allStatuses,style:TextStyle(color: colorScheme.primary))),
            ],
            onChanged: onStatusChanged,
          ),
        ),
      ],
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  final Widget icon;
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _FilterDropdown({
    required this.icon,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // subtle shadow using theme onSurface with low opacity
        boxShadow: [BoxShadow(color: colorScheme.onSurface.withAlpha((0.06 * 255).round()), blurRadius: 5)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<T>(
              value: value,
              hint: Text(
                hint,
                style: TextStyle(color: colorScheme.onSurface),
              ),
              isExpanded: true,
              underline: const SizedBox(),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class TaskListSection extends StatelessWidget {
  const TaskListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final messageStyle = TextStyle(fontSize: 18, color: colorScheme.onSurface);
    return Expanded(
      child: BlocBuilder<TaskBloc, taskState.TaskState>(
        builder: (context, state) {
          if (state is taskState.TaskLoading) {
            return Center(child: CircularProgressIndicator(color: colorScheme.primary));
          } else if (state is taskState.TaskLoaded) {
            if (state.tasks.isEmpty) {
              return Center(
                  child: Text(context.l10n.noTasksMatchFilters,
                      style: messageStyle));
            }
            return TaskItems(tasks: state.tasks);
          } else if (state is taskState.TaskError) {
            return Center(
                child: Text(state.message, style: messageStyle));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
