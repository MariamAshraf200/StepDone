import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../../injection_imports.dart';
import '../../../../core/util/custom_builders/navigate_to_screen.dart';
import '../widget/plan_details/plan_image_section.dart';

class PlanDetailsScreen extends StatefulWidget {
  final String id;

  const PlanDetailsScreen({super.key, required this.id});

  @override
  State<PlanDetailsScreen> createState() => _PlanDetailsScreenState();
}

class _PlanDetailsScreenState extends State<PlanDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger loading of tasks and ensure plans are available in the bloc
    context.read<PlanBloc>().add(GetAllTasksPlanEvent(widget.id));
  }

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final l10n = AppLocalizations.of(context)!;
        return CustomDialog(
          title: l10n.addSubtask,
          description: '', // unused because we provide content
          operation: l10n.save,
          icon: Icons.add,
          color: colorScheme.primary,
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: l10n.enterTaskTitle,
              border: const OutlineInputBorder(),
            ),
          ),
          onCanceled: () => Navigator.pop(context),
          onConfirmed: () {
            if (controller.text.isNotEmpty) {
              final newTask = TaskPlan(
                id: const Uuid().v4(),
                text: controller.text.trim(),
                status: TaskPlanStatus.toDo,
              );
              context.read<PlanBloc>().add(
                    AddTaskToPlanEvent(planId: widget.id, task: newTask),
                  );
              Navigator.pop(context);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: BlocBuilder<PlanBloc, PlanState>(
                  builder: (context, state) {
                    if (state is TasksLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is PlanAndTasksLoaded) {
                      final matching = state.plans.where((p) => p.id == widget.id).toList();
                      if (matching.isEmpty) {
                        return Center(child: Text(l10n.noDataAvailable));
                      }
                      final currentPlan = matching.first;
                      final tasks = state.tasks;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PlanDetailsTitleDescription(plan: currentPlan),
                          const SizedBox(height: 16),

                          // ✅ Progress bar
                          PlanDetailsProgress(tasks: tasks),
                          const SizedBox(height: 24),

                          // ✅ Dates
                          PlanDetailsDates(plan: currentPlan),
                          const SizedBox(height: 24),

                          // Plan image section (extracted widget)
                          PlanImageSection(plan: currentPlan),
                          const SizedBox(height: 24),

                          // ✅ Subtasks
                          PlanDetailsSubtasks(
                            plan: currentPlan,
                            onAddTask: _showAddTaskDialog,
                            subTaskCardBuilder: (context, task) =>
                                PlanDetailsSubtaskCard(
                                  plan: currentPlan,
                                  task: task,
                                ),
                          ),
                        ],
                      );
                    } else if (state is TaskError) {
                      return Center(
                        child: Text('${l10n.errorPrefix}${state.message}',
                            style: const TextStyle(color: Colors.red)),
                      );
                    }
                    return Center(child: Text(l10n.noDataAvailable));
                  },
                ),
              ),
            ),
            PlanDetailsBottomButton(
              onEdit: () async {
                // Safely obtain the current plan from the bloc state before navigating
                final state = context.read<PlanBloc>().state;
                PlanDetails? currentPlan;
                if (state is PlanAndTasksLoaded) {
                  final matching = state.plans.where((p) => p.id == widget.id).toList();
                  if (matching.isNotEmpty) currentPlan = matching.first;
                } else if (state is PlanLoaded) {
                  try {
                    currentPlan = state.plans.firstWhere((p) => p.id == widget.id);
                  } catch (_) {
                    currentPlan = null;
                  }
                }

                if (currentPlan == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.failedToLoadPlans)),
                  );
                  return;
                }

                final updatedPlan = await navigateToScreenWithSlideTransition(
                  context,
                  UpdatePlanScreen(plan: currentPlan),
                );

                if (updatedPlan != null && updatedPlan is PlanDetails && mounted) {
                  context.read<PlanBloc>().add(UpdatePlanEvent(updatedPlan));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
