import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/plan_entity.dart';
import '../widget/plan_form.dart';


class UpdatePlanScreen extends StatelessWidget {
  const UpdatePlanScreen({super.key, required this.plan});
  final PlanDetails plan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: l10n.close,
                    icon: Icon(
                      Icons.close,
                      size: 30,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Text(
                    l10n.updateTask,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ) ??
                        TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // The PlanForm fills the remaining space
            Expanded(
              child: PlanForm(
                isUpdate: true,
                initialPlan: plan,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
