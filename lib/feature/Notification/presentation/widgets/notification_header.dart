import 'package:StepDone/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';

class NotificationHeader extends StatelessWidget {
  final int count;
  final String? title;

  const NotificationHeader({Key? key, required this.count, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final headerTitle = title ?? context.l10n.remindersDashboardTitle;
    final headerSubtitle = context.l10n.remindersCount(count);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer,
            scheme.surfaceContainerHighest.withAlpha((0.6 * 255).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withAlpha((0.1 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: scheme.primary,
            child: Icon(Icons.alarm_rounded, color: scheme.onPrimary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headerTitle,
                  style: TextStyle(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  headerSubtitle,
                  style: TextStyle(
                    color: scheme.onPrimaryContainer.withAlpha((0.8 * 255).round()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
