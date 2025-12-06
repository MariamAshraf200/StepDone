import 'package:StepDone/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';

class TaskStatsCard extends StatelessWidget {
  final int doneTasks;
  final int totalTasks;
  final double completionPercentage;

  const TaskStatsCard({
    super.key,
    required this.doneTasks,
    required this.totalTasks,
    required this.completionPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 🔹 Left side
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.todaysProgress,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "$doneTasks / $totalTasks ${l10n.tasks}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // 🔹 Right side
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: completionPercentage,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(
                      completionPercentage < 0.5
                          ? colorScheme.secondary
                          : colorScheme.primary,
                    ),
                  ),
                ),
                Text(
                  "${(completionPercentage * 100).toInt()}%",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: completionPercentage < 0.5
                        ? colorScheme.inverseSurface
                        : colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
