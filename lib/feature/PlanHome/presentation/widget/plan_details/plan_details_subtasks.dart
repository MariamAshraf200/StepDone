import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/plan_entity.dart';
import '../../../domain/entities/taskPlan.dart';
import '../../bloc/bloc.dart';
import '../../bloc/state.dart';


class PlanDetailsSubtasks extends StatelessWidget {
  final PlanDetails plan;
  final void Function(BuildContext) onAddTask;
  final Widget Function(BuildContext, TaskPlan) subTaskCardBuilder;
  const PlanDetailsSubtasks({super.key, required this.plan, required this.onAddTask, required this.subTaskCardBuilder});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.subtasks,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => onAddTask(context),
              icon: Icon(Icons.add, color: colorScheme.secondary),
              label: Text(
                l10n.addSubtask,
                style: TextStyle(color: colorScheme.secondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<PlanBloc, PlanState>(
          builder: (context, state) {
            if (state is TasksLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PlanAndTasksLoaded) {
              final tasks = state.tasks;
              if (tasks.isEmpty) {
                return Center(
                  child: Text(
                    l10n.noSubtasksYet,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }
              return Column(
                children: tasks.map((task) => subTaskCardBuilder(context, task)).toList(),
              );
            } else if (state is TaskError) {
              return Center(child: Text('${l10n.errorPrefix}${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
