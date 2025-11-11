import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapperapp/l10n/l10n_extension.dart';
import '../../../PlanHome/presentation/bloc/bloc.dart';
import '../../../PlanHome/presentation/bloc/state.dart';
import '../../../PlanHome/domain/entities/taskPlan.dart';
import 'plan_card.dart';

class PlanList extends StatelessWidget {
  const PlanList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlanBloc, PlanState>(
      builder: (context, state) {
        if (state is PlanLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is PlanLoaded || state is PlanAndTasksLoaded) {
          final plans = state is PlanLoaded ? state.plans : (state as PlanAndTasksLoaded).plans;

          if (plans.isEmpty) {
            return Center(
              child: Text(
                context.l10n.noPlansAvailable,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Choose a comfortable card width depending on available space
                final maxWidth = constraints.maxWidth;
                final cardWidth = (maxWidth > 600) ? 420.0 : (maxWidth * 0.78).clamp(260.0, 420.0);

                return SizedBox(
                  height: 220, // sufficient height for the card content
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: plans.length,
                    padding: const EdgeInsets.only(right: 16.0),
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      final tasks = plan.tasks.cast<TaskPlan>();

                      return SizedBox(
                        width: cardWidth,
                        child: PlanCardCombined(
                          id: plan.id,
                          title: plan.title,
                          tasks: tasks,
                          endDateRaw: plan.endDate,
                          updatedTimeRaw: plan.updatedTime,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        } else if (state is PlanError) {
          return Center(
            child: Text(
              context.l10n.failedToLoadPlans,
              style: const TextStyle(fontSize: 16),
            ),
          );
        } else {
          return Center(
            child: Text(
              context.l10n.somethingWentWrong,
              style: const TextStyle(fontSize: 16),
            ),
          );
        }
      },
    );
  }
}
