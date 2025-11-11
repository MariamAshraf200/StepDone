import 'package:flutter/material.dart';
import 'package:mapperapp/l10n/l10n_extension.dart';
import '../../../taskHome/domain/entity/taskEntity.dart';
import '../wedgit/plan_list.dart';
import '../wedgit/task_list.dart';

class HomeScreenForm extends StatelessWidget {
  final List<TaskDetails> tasks;

  const HomeScreenForm({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        _buildSectionTitle(context, l10n.myPlan),
        const SizedBox(height: 6),
        const PlanList(),
        const SizedBox(height: 12),
        _buildSectionTitle(context, l10n.myTasks),
        const SizedBox(height: 6),
        TaskList(tasks: tasks),
        const SizedBox(height: 12),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
