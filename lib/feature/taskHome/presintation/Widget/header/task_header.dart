import 'package:flutter/material.dart';
import '../../../../../core/util/date_and_time/date_format_util.dart';
import '../../screen/add_task_screen.dart';

class TaskHeader extends StatelessWidget {
  final String selectedDate;
  final ValueChanged<String> onDatePicked;

  const TaskHeader({
    super.key,
    required this.selectedDate,
    required this.onDatePicked,
  });

  void _showDatePicker(BuildContext context) async {
    final initialDate = DateFormatUtil.parseDate(selectedDate);
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      onDatePicked(DateFormatUtil.formatDate(pickedDate));
    }
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
      ),
      child: IconButton(
        icon: Icon(icon, size: 22),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final formattedDate = DateFormatUtil.formatFullDate(selectedDate, locale: locale);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Centered full date
          GestureDetector(
            onTap: () => _showDatePicker(context),
            child: Text(
              formattedDate, // localized full date
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Add button with circle border
          _circleIconButton(
            icon: Icons.add,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTaskScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
