import 'package:flutter/material.dart';
import 'package:mapperapp/l10n/l10n_extension.dart';
import '../../../feature/PlanHome/presentation/screen/addPlan.dart';
import '../../../feature/taskHome/presintation/screen/add_task_screen.dart';

class CustomFAB extends StatefulWidget {
  final BuildContext context;

  const CustomFAB({super.key, required this.context});

  @override
  State<CustomFAB> createState() => _CustomFABState();
}

class _CustomFABState extends State<CustomFAB>
    with SingleTickerProviderStateMixin {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final isArabic = Directionality.of(context) == TextDirection.rtl;

    return Stack(
      alignment: isArabic ? Alignment.bottomLeft : Alignment.bottomRight,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: isOpen
              ? Padding(
                  padding: isArabic
                      ? const EdgeInsets.only(bottom: 80, left: 16)
                      : const EdgeInsets.only(bottom: 80, right: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildActionButton(
                        icon: Icons.task,
                        label: l10n.addTaskButton,
                        background: colorScheme.primary,
                        textColor: colorScheme.onPrimary,
                        isArabic: isArabic,
                        onTap: _addNewTask,
                      ),
                      const SizedBox(height: 10),
                      _buildActionButton(
                        icon: Icons.event_note,
                        label: l10n.addPlan,
                        background: colorScheme.secondary,
                        textColor: colorScheme.onSecondary,
                        isArabic: isArabic,
                        onTap: _addNewPlan,
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // FAB
        Padding(
          padding: isArabic
              ? const EdgeInsets.only(left: 16.0, bottom: 16.0)
              : const EdgeInsets.only(right: 16.0, bottom: 16.0),
          child: FloatingActionButton(
            backgroundColor: colorScheme.primary,
            elevation: 8,
            onPressed: () => setState(() => isOpen = !isOpen),
            shape: const CircleBorder(),
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 250),
              turns: isOpen ? 0.125 : 0.0, // + to ×
              child: const Icon(Icons.add, size: 30, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color background,
    required Color textColor,
    required bool isArabic,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() => isOpen = false);
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(38),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addNewTask() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskScreen()),
    );
  }

  void _addNewPlan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPlanScreen()),
    );
  }
}

