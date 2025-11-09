import 'package:flutter/material.dart';
import 'package:mapperapp/l10n/l10n_extension.dart';

class NotificationEmpty extends StatelessWidget {
  const NotificationEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 72, color: scheme.outlineVariant.withAlpha((0.5 * 255).round())),
          const SizedBox(height: 12),
          Text(
            context.l10n.noRemindersYet,
            style: TextStyle(
              fontSize: 16,
              color: scheme.onSurface.withAlpha((0.7 * 255).round()),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.tapPlusToAddOne,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
