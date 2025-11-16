import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/plan_entity.dart';

class PlanDetailsDates extends StatelessWidget {
  final PlanDetails plan;
  const PlanDetailsDates({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.event, color: colorScheme.secondary, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    l10n.planStartDate,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                plan.startDate,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Divider(thickness: 1, height: 16, color: Colors.black12),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.flag, color: Colors.redAccent.shade400, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    l10n.planEndDate,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Text(
                plan.endDate,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Divider(thickness: 1, height: 16, color: Colors.black12),
            ],
          ),
        ),
      ],
    );
  }
}
