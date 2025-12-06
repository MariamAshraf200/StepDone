import 'package:StepDone/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String description;
  final String operation;
  final IconData icon;
  final Color color;
  final VoidCallback onConfirmed;
  final VoidCallback onCanceled;
  final Widget? content; // optional custom content (e.g., TextField)

  const CustomDialog({
    super.key,
    required this.title,
    required this.description,
    required this.operation,
    required this.icon,
    required this.color,
    required this.onConfirmed,
    required this.onCanceled,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 12,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon section with subtle animation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: color.withAlpha((0.2 * 255).round()),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 40.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title with bold styling
            Text(
              title,
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Either show the provided content widget or the description text
            if (content != null) ...[
              content!,
              const SizedBox(height: 24),
            ] else ...[
              Text(
                description,
                style: TextStyle(
                  fontSize: 16.0,
                  height: 1.6,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],

            // Action buttons with elevated and balanced designs
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: ElevatedButton(
                    onPressed: onCanceled,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.grey.shade800,
                      backgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                    ),
                    child: Text(
                      context.l10n.cancel,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Confirm button
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirmed,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      operation,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
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