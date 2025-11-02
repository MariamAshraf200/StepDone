import 'package:flutter/material.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/schedule_notification_usecase.dart';
import '../../domain/usecases/request_permission_usecase.dart';
import '../../../../injection_imports.dart';
import '../../data/datasource/local_notification_service.dart';
import 'package:intl/intl.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  List<TaskDetails> notifiableTasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifiableTasks();
  }

  Future<void> _loadNotifiableTasks() async {
    try {
      final getAll = sl<GetAllTasksUseCase>();
      final List<TaskDetails> all = await getAll();
      final now = DateTime.now();
      // Keep only tasks that have notifications scheduled in the future
      final filtered = all
          .where((t) => t.hasNotification && t.notifyAt != null && t.notifyAt!.isAfter(now))
          .toList();
      if (!mounted) return;
      setState(() {
        notifiableTasks = filtered;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      debugPrint('Failed to load tasks: $e');
    }
  }

  Future<void> _showIntervalSheetAndSchedule(TaskDetails t) async {
    final selection = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Repeat Interval',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Send once (immediately)'),
                  onTap: () => Navigator.pop(ctx, 0),
                ),
                for (var h in [3, 6, 9, 12])
                  ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: Text('Repeat every $h hours'),
                    onTap: () => Navigator.pop(ctx, h),
                  ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selection == null) return;

    await sl<RequestPermissionUseCase>()();
    if (!mounted) return;

    final scheduledTime =
        t.notifyAt ?? DateTime.now().add(const Duration(seconds: 1));

    try {
      if (selection == 0) {
        await sl<LocalNotificationService>().scheduleNotification(
          id: t.id.hashCode,
          title: t.title.isNotEmpty ? t.title : 'Reminder',
          body: t.description.isNotEmpty ? t.description : 'Task reminder',
          time: scheduledTime,
          occurrences: 1,
          intervalSeconds: 0,
          startImmediately: true,
        );
      } else {
        final int intervalSeconds = selection * 3600;
        final int occurrences = ((24 ~/ selection) * 7).clamp(1, 1000);
        Future(() async {
          await sl<LocalNotificationService>().scheduleNotification(
            id: t.id.hashCode,
            title: t.title.isNotEmpty ? t.title : 'Reminder',
            body: t.description.isNotEmpty ? t.description : 'Task reminder',
            time: scheduledTime,
            occurrences: occurrences,
            intervalSeconds: intervalSeconds,
            startImmediately:
                scheduledTime.isBefore(DateTime.now().add(const Duration(seconds: 2))),
          );
        });
      }

      if (!mounted) return;
      final msg = (selection == 0)
          ? 'Scheduled ${t.title} (once)'
          : 'Scheduled ${t.title} every $selection hour(s)';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      debugPrint('Failed to schedule repeated notifications for task ${t.id}: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to schedule repeated notifications')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, dd MMM yyyy – hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Settings"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : notifiableTasks.isEmpty
                ? const Center(
                    child: Text('No tasks with notifications found'),
                  )
                : ListView.separated(
                    itemCount: notifiableTasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final t = notifiableTasks[idx];

                      // tasks shown here are already filtered to future notifications
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Card(
                          key: ValueKey(t.id),
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Vertical accent bar
                                Container(
                                  width: 6,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withAlpha(46), // muted primary
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                      topRight: Radius.circular(6),
                                      bottomRight: Radius.circular(6),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Title and status row
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              t.title.isNotEmpty ? t.title : '(No title)',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // Time
                                      Row(
                                        children: [
                                          Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                                          const SizedBox(width: 6),
                                          Text(
                                            t.notifyAt != null
                                                ? dateFormat.format(t.notifyAt!)
                                                : 'No notify time',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),

                                      if (t.description.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          t.description,
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                              height: 1.3),
                                        ),
                                      ],

                                      const SizedBox(height: 10),

                                      // Action buttons row
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              _ActionButton(
                                                icon: Icons.notifications_active_outlined,
                                                label: "Schedule",
                                                color: Theme.of(context).colorScheme.primary,
                                                onTap: () async {
                                                  await sl<RequestPermissionUseCase>()();
                                                  if (!mounted) return;
                                                  final appNotif = AppNotification(
                                                    id: t.id.hashCode,
                                                    title: t.title.isNotEmpty
                                                        ? t.title
                                                        : 'Reminder',
                                                    body: t.description.isNotEmpty
                                                        ? t.description
                                                        : 'Task reminder',
                                                    scheduledTime: t.notifyAt ??
                                                        DateTime.now().add(const Duration(seconds: 1)),
                                                  );
                                                  await sl<ScheduleNotificationUseCase>()
                                                      .call(appNotif);
                                                  if (!mounted) return;
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(const SnackBar(
                                                          content: Text('Scheduled task reminder')));
                                                },
                                              ),
                                              const SizedBox(width: 8),
                                              _ActionButton(
                                                icon: Icons.repeat,
                                                label: "Repeat",
                                                color: Theme.of(context).colorScheme.secondary,
                                                onTap: () => _showIntervalSheetAndSchedule(t),
                                              ),
                                              const SizedBox(width: 8),
                                              _ActionButton(
                                                icon: Icons.cancel_outlined,
                                                label: "Cancel",
                                                color: Theme.of(context).colorScheme.error,
                                                onTap: () async {
                                                  try {
                                                    // cancel system scheduled notification
                                                    await sl<LocalNotificationService>()
                                                        .cancel(t.id.hashCode);

                                                    // update task to disable notification and clear notify time
                                                    final updatedTask = t.copyWith(
                                                      hasNotification: false,
                                                      notifyAt: null,
                                                    );

                                                    await sl<UpdateTaskUseCase>().call(updatedTask);

                                                    if (!mounted) return;
                                                    setState(() {
                                                      notifiableTasks.removeAt(idx);
                                                    });

                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(const SnackBar(
                                                            content: Text('Cancelled and removed reminder')));
                                                  } catch (e) {
                                                    debugPrint('Failed to cancel reminders or update task ${t.id}: $e');
                                                    if (!mounted) return;
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(const SnackBar(
                                                            content: Text('Failed to cancel reminders')));
                                                  }
                                                },
                                              ),
                                            ],
                                          ),

                                          // optional small info icon or overflow
                                          IconButton(
                                            onPressed: () {
                                              // Could show more details or edit screen later
                                            },
                                            icon: Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ));
                      },
                    ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            width: 68,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(
              color: color.withAlpha(20), // ~0.08 opacity
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color.withAlpha(230), size: 18), // ~0.9 opacity
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color.withAlpha(230), // ~0.9 opacity
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
