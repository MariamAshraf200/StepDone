import 'package:StepDone/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';
import '../../../../core/util/date_and_time/date_format_util.dart';
import '../../../../core/util/date_and_time/time_format_util.dart';
import '../../../PlanHome/domain/entities/taskPlan.dart';
import '../../../PlanHome/presentation/screen/plan_details.dart';

class PlanCardCombined extends StatelessWidget {
  final String title;
  final List<TaskPlan> tasks;
  final String? endDateRaw;
  final String? updatedTimeRaw;
  final String id;
  const PlanCardCombined({
    super.key,
    required this.title,
    required this.tasks,
    this.endDateRaw,
    this.updatedTimeRaw,
    required this.id,
  });

  double _calculateProgress(List<TaskPlan> tasks) {
    if (tasks.isEmpty) return 0.0;
    final completed =
        tasks.where((t) => t.status == TaskPlanStatus.done).length;
    return completed / tasks.length;
  }

  String? _formatEndDate(BuildContext context) {
    if (endDateRaw == null) return null;
    final raw = endDateRaw!.trim();
    if (raw.isEmpty) return null;
    try {
      final locale = Localizations.localeOf(context).toString();
      return DateFormatUtil.formatFullDateFromRaw(raw, locale: locale);
    } catch (_) {
      return raw;
    }
  }

  String? _formatTime(BuildContext context) {
    if (updatedTimeRaw == null) return null;
    final raw = updatedTimeRaw!.trim();
    if (raw.isEmpty) return null;
    return TimeFormatUtil.formatFlexibleTime(raw, context);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress(tasks);
    final formattedDate = _formatEndDate(context);
    final formattedTime = _formatTime(context);
    final endDisplay = formattedDate != null
        ? (formattedTime != null
            ? '$formattedDate • $formattedTime'
            : formattedDate)
        : null;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlanDetailsScreen(
              id: id,
            ),
          ),
        );
      },
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(width: 12),

              // Main content: title, small badges, subtasks preview, progress bar, end date
              Flexible(
                fit: FlexFit.loose,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Badges row: completed / total
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withAlpha((0.12 * 255).round()),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 14,
                                color: colorScheme.secondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                // use existing localization keys for status
                                '${tasks.where((t) => t.status == TaskPlanStatus.done).length}/${tasks.length} ${context.l10n.statusDone}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Small spacer or other chips could go here
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Linear progress bar moved under title/badges
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        color: colorScheme.secondary,
                        backgroundColor: Colors.grey[300],
                        minHeight: 5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Subtasks preview (show up to 3)
                    if (tasks.isNotEmpty) ...[
                      // Show up to 2 subtasks
                      for (var i = 0; i < tasks.length && i < 2; i++)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
                          child: Row(
                            children: [
                              Tooltip(
                                message: tasks[i].status == TaskPlanStatus.done
                                    ? context.l10n.statusDone
                                    : context.l10n.statusToDo,
                                 child: Icon(
                                   tasks[i].status == TaskPlanStatus.done
                                       ? Icons.check_circle
                                       : Icons.radio_button_unchecked,
                                   size: 16,
                                   color: tasks[i].status == TaskPlanStatus.done
                                       ? colorScheme.secondary
                                       : Colors.grey,
                                 ),
                               ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tasks[i].text,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: tasks[i].status == TaskPlanStatus.done
                                        ? Colors.grey[600]
                                        : Colors.grey[800],
                                    decoration: tasks[i].status == TaskPlanStatus.done
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    decorationThickness: 1.4,
                                  ),
                                   maxLines: 1,
                                   overflow: TextOverflow.ellipsis,
                                 ),
                               ),
                            ],
                          ),
                        ),

                      // If there are more than 2 subtasks, show a small indicator
                      if (tasks.length > 2)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            '+${tasks.length - 2} ${context.l10n.moreItems}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                      const SizedBox(height: 6),
                    ],

                    if (endDisplay != null)
                      Flexible(
                        child: Text(
                         endDisplay,
                         style: const TextStyle(
                           fontSize: 12,
                           color: Colors.grey,
                         ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      ),
                   ],
                 ),
               ),

             ],
           ),
         ),
       ),
     );
   }
 }
