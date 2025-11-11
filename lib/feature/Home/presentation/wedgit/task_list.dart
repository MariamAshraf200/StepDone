import 'package:flutter/material.dart';
import 'package:mapperapp/feature/taskHome/domain/entity/taskEntity.dart';
import 'package:mapperapp/feature/taskHome/presintation/Widget/item/task_item_card.dart';
import 'package:mapperapp/l10n/app_localizations.dart';

class TaskList extends StatelessWidget {

  final List<TaskDetails> tasks;

  const TaskList({super.key, required this.tasks});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (tasks.isEmpty) {
      return Center(child: Text(l10n.noTasksFound));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: tasks.map((task) {
            return TaskItemCard(task: task);
          }).toList(),
        ),
      ),
    );
  }
}
