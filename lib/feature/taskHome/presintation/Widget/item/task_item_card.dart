import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../injection_imports.dart';
import '../../../../../l10n/l10n_extension.dart';



class TaskItemCard extends StatelessWidget {
  final TaskDetails task;

  const TaskItemCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    // Auto-mark as missed
    if (task.shouldBeMissed(DateTime.now()) && !task.isMissed) {
      context.read<TaskBloc>().add(
        UpdateTaskStatusEvent(
          task.id,
          TaskStatus.missed,
        ),
      );
    }

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.horizontal,
      background: _buildEditBackground(),
      secondaryBackground: _buildDeleteBackground(),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _showUpdateDialog(context, task);
        } else {
          _showDeleteDialog(context, task);
        }
        return false;
      },
      child: _buildContent(context),
    );
  }

  // ---------------- Swipe Backgrounds ----------------
  Widget _buildEditBackground() => Container(
    color: Colors.blueAccent,
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: const Icon(Icons.edit, color: Colors.white, size: 28),
  );

  Widget _buildDeleteBackground() => Container(
    color: Colors.redAccent,
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: const Icon(Icons.delete, color: Colors.white, size: 28),
  );

  // ---------------- Main Content ----------------
  Widget _buildContent(BuildContext context) {
    final TaskPriority priorityEnum = TaskPriorityExtension.fromString(task.priority);
    final Color priorityColor = priorityEnum.toPriorityColor(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline stripe + dot
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: priorityColor,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 55,
                color: priorityColor.withAlpha(100),
                margin: const EdgeInsets.only(top: 4),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Task info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Priority + Category + Status
                Row(
                  children: [
                    // Left side takes remaining space and wraps its children
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _buildPriorityChip(context, priorityColor, priorityEnum),
                          if (task.category.isNotEmpty) _buildCategoryChip(context, task.category),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Show notification icon when task.notifications enabled
                    if (task.notification) ...[
                      Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: Icon(
                          Icons.notifications_active,
                          size: 20,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                    // Status icon keeps fixed space to avoid being pushed out
                    _buildStatusIcon(context),
                  ],
                ),
                const SizedBox(height: 6),

                // Title
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                // Description
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 6),

                // Date & Time — use Wrap so items can wrap to the next line instead of overflowing
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (task.date.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          // constrain the date text so it can ellipsize on very small widths
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.55,
                            ),
                            child: Text(
                              DateFormatUtil.formatFullDate(task.date, locale: Localizations.localeOf(context).toString()),
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),

                    if (task.time.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            task.time,
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),

                    if (task.endTime.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('-', style: TextStyle(fontSize: 13, color: Colors.grey)),
                          const SizedBox(width: 4),
                          Text(
                            task.endTime,
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Chips ----------------
  Widget _buildPriorityChip(BuildContext context, Color color, TaskPriority priorityEnum) => Container(
    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
    decoration: BoxDecoration(
      color: color.withAlpha(30),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      priorityEnum.toPriorityLabel(context),
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _buildCategoryChip(BuildContext context, String category) => Container(
    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      // Treat 'general' as the canonical key (case-insensitive) and show localized label
      category.toLowerCase() == 'general' ? context.l10n.general : category,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  // ---------------- Status ----------------
  Widget _buildStatusIcon(BuildContext context) {
    return GestureDetector(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
        child: _statusIcon(),
      ),
      onTap: () => _toggleStatus(context),
    );
  }

  Widget _statusIcon() {
    if (task.isCompleted) {
      return SvgPicture.asset(
        AppAssets.rightCheckBox,
        width: 30,
        height: 30,
        key: const ValueKey('completed'),
      );
    } else if (task.isMissed) {
      return Image.asset(
        AppAssets.missedIcon,
        width: 30,
        height: 30,
        key: const ValueKey('missed'),
      );
    } else if (task.isPending) {
      return Image.asset(
        AppAssets.pendingClockIcon,
        width: 30,
        height: 30,
        key: const ValueKey('pending'),
      );
    }
    return Container(
      key: const ValueKey('notCompleted'),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: const Icon(Icons.check, size: 18, color: Colors.grey),
    );
  }

  // ---------------- Events ----------------
  void _toggleStatus(BuildContext context) {
    if (task.isMissed) return _showErrorDialog(context);

    final newStatus = task.isCompleted ? TaskStatus.pending : TaskStatus.done;

    context.read<TaskBloc>().add(UpdateTaskStatusEvent(
      task.id,
      newStatus,
    ));

    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.taskMarkedPrefix} ${_statusLabel(newStatus, context)}'),
        duration: const Duration(seconds: 1),
        backgroundColor: newStatus == TaskStatus.done ? Colors.green : Colors.orange,
      ),
    );
  }

  String _statusLabel(TaskStatus status, BuildContext context) {
    final l10n = context.l10n;
    switch (status) {
      case TaskStatus.done:
        return l10n.statusDone;
      case TaskStatus.pending:
        return l10n.statusPending;
      case TaskStatus.missed:
        return l10n.statusMissed;
      case TaskStatus.toDo:
        return l10n.statusToDo;
      }
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.taskNotEditable),
        content: Text(context.l10n.taskNotEditable),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, TaskDetails task) {
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        title: context.l10n.updateTask,
        description: context.l10n.updateTaskDescription,
        icon: Icons.update,
        operation: context.l10n.updateOperation,
        color: Colors.blue,
        onConfirmed: () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UpdateTaskScreen(task: task)),
          );
        },
        onCanceled: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TaskDetails task) {
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        title: context.l10n.deleteTask,
        description: context.l10n.deleteTaskDescription,
        icon: Icons.delete_forever,
        operation: context.l10n.deleteOperation,
        color: Colors.red,
        onConfirmed: () {
          context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
          Navigator.of(context).pop();
        },
        onCanceled: () => Navigator.of(context).pop(),
      ),
    );
  }
}
